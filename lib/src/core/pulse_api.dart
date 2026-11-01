import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../version/client_identity.dart';

/// Public failure of a Pulse call: the API code (`PULSE_*`), `networkError` or `requestError`.
class PulseFailure implements Exception {
  const PulseFailure(
    this.code, {
    this.status,
    this.message,
    this.fields = const [],
  });
  final String code;
  final int? status;

  /// Server text of a refused field (`VALIDATION_FAILED`), mapped to a translation by the view.
  final String? message;
  final List<String> fields;

  /// The offline grant of this device no longer holds (revoked, expired, replayed, unknown):
  /// queued marks wait for a session instead.
  bool get deviceRefused => code.startsWith('PULSE_DEVICE_');

  bool get sessionEnded =>
      code == 'PULSE_SESSION_INVALID' ||
      code == 'PULSE_ACCESS_DENIED' ||
      code == 'PULSE_MODULE_UNAVAILABLE';

  /// This installed app version is no longer accepted (HTTP 426): nothing local is dropped, the
  /// app waits for an update.
  bool get versionUnsupported => code == clientVersionUnsupportedCode;

  @override
  String toString() => 'PulseFailure($code)';
}

/// Signed-in employee as returned by the API (never stored on the device).
class PulseAccount {
  const PulseAccount({
    required this.timeClockAccountUUID,
    required this.loginCode,
    required this.mustChangePassword,
    this.employeeName,
    this.companyName,
    this.hrAccountName,
  });

  factory PulseAccount.fromJson(Map<String, dynamic> json) => PulseAccount(
    timeClockAccountUUID: json['timeClockAccountUUID']?.toString() ?? '',
    loginCode: json['loginCode']?.toString() ?? '',
    mustChangePassword: json['mustChangePassword'] == true,
    employeeName: json['employeeName']?.toString(),
    companyName: json['companyName']?.toString(),
    hrAccountName: json['hrAccountName']?.toString(),
  );

  final String timeClockAccountUUID;
  final String loginCode;
  final bool mustChangePassword;
  final String? employeeName;
  final String? companyName;

  /// Customer HR account (resale) of the time clock account; null for the reseller's own HR.
  final String? hrAccountName;

  PulseAccount passwordChanged() => PulseAccount(
    timeClockAccountUUID: timeClockAccountUUID,
    loginCode: loginCode,
    mustChangePassword: false,
    employeeName: employeeName,
    companyName: companyName,
    hrAccountName: hrAccountName,
  );
}

/// Keeps the native refresh token between launches (platform secure storage). The web never
/// sees its refresh token: it is the HttpOnly cookie set by the API.
abstract class RefreshTokenStore {
  Future<String?> read();
  Future<void> write(String? token);
}

/// Pulse API client. The session is a short-lived access token in memory plus a rotating refresh
/// token: on the web it lives only in the HttpOnly cookie set by the API (same origin), on native
/// builds in the platform secure storage ([refreshStore]).
class PulseApi {
  PulseApi({this._client, String? baseUrl, this.refreshStore})
    : _base = normalizedApiBase(baseUrl);

  final http.Client? _client;
  final String _base;
  String? _accessToken;
  String? _refreshToken;
  Future<bool>? _refreshing;

  /// Called with the server time of every session answer, to measure the clock offset.
  void Function(DateTime serverTime)? onServerTime;

  /// Called with the account of every session answer (sign-in, refresh, restore), so the offline
  /// grant of this device is renewed whenever a session is live.
  void Function(PulseAccount account)? onSession;

  final RefreshTokenStore? refreshStore;

  String? _accountUUID;

  /// Account of the live session (null when signed out).
  String? get accountUUID => _accessToken == null ? null : _accountUUID;

  /// True when the last refresh failed for lack of connection (not because the session ended).
  bool lastRefreshOffline = false;

  bool get signedIn => _accessToken != null;
  String get clientKind => kIsWeb ? 'web' : 'native';

  String get platform => _platform;

  String get _platform => clientPlatformName();

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? rawBody,
    Map<String, String>? headers,
    bool auth = true,
  }) async {
    final request = http.Request(method, Uri.parse('$_base$path'));
    request.headers['content-type'] = 'application/json';
    request.headers.addAll(clientHeaders(platform: _platform));
    if (headers != null) request.headers.addAll(headers);
    if (auth && _accessToken != null) {
      request.headers['authorization'] = 'Bearer $_accessToken';
    }
    if (rawBody != null) {
      request.body = rawBody;
    } else if (body != null) {
      request.body = jsonEncode(body);
    }
    late http.Response response;
    try {
      final streamed = await (_client?.send(request) ?? request.send()).timeout(
        const Duration(seconds: 20),
      );
      response = await http.Response.fromStream(streamed);
    } catch (_) {
      throw const PulseFailure('networkError');
    }
    Map<String, dynamic> data = {};
    try {
      final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {}
    return _checked(response.statusCode, data);
  }

  static Map<String, dynamic> _checked(int status, Map<String, dynamic> data) {
    if (status < 200 || status >= 300) {
      final code = data['code'];
      noteClientVersionAnswer(status, code);
      final fields = data['fields'];
      throw PulseFailure(
        code is String && code.isNotEmpty
            ? code
            : status == 429
            ? 'PULSE_RATE_LIMITED'
            : 'requestError',
        status: status,
        message: data['error']?.toString(),
        fields: fields is List
            ? fields.map((f) => f.toString()).toList()
            : const [],
      );
    }
    return data;
  }

  /// One file field (multipart) with plain fields; refreshed and repeated once like [call].
  Future<Map<String, dynamic>> _upload(
    String path,
    Map<String, String> fields,
    List<int> bytes,
    String fileName,
  ) async {
    Future<Map<String, dynamic>> send() async {
      final request = http.MultipartRequest('POST', Uri.parse('$_base$path'));
      request.headers.addAll(clientHeaders(platform: _platform));
      if (_accessToken != null) {
        request.headers['authorization'] = 'Bearer $_accessToken';
      }
      request.fields.addAll(fields);
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );
      late http.Response response;
      try {
        final streamed = await (_client?.send(request) ?? request.send())
            .timeout(const Duration(seconds: 60));
        response = await http.Response.fromStream(streamed);
      } catch (_) {
        throw const PulseFailure('networkError');
      }
      Map<String, dynamic> data = {};
      try {
        final decoded = response.body.isEmpty
            ? null
            : jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) data = decoded;
      } catch (_) {}
      return _checked(response.statusCode, data);
    }

    try {
      return await send();
    } on PulseFailure catch (failure) {
      if (failure.code != 'PULSE_SESSION_INVALID' || !await refresh()) rethrow;
      return await send();
    }
  }

  /// Authenticated call; an expired access token is refreshed once and the call repeated.
  Future<Map<String, dynamic>> call(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      return await _send(method, path, body: body);
    } on PulseFailure catch (failure) {
      if (failure.code != 'PULSE_SESSION_INVALID' || !await refresh()) rethrow;
      return await _send(method, path, body: body);
    }
  }

  PulseAccount _accept(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is! Map<String, dynamic> || data['accessToken'] is! String) {
      throw const PulseFailure('requestError');
    }
    _accessToken = data['accessToken'] as String;
    final refresh = data['refreshToken'];
    if (refresh is String && refresh.isNotEmpty) {
      _refreshToken = refresh;
      unawaited(refreshStore?.write(refresh));
    }
    final serverTime = DateTime.tryParse(data['serverTime']?.toString() ?? '');
    if (serverTime != null) onServerTime?.call(serverTime);
    final raw = data['account'];
    final account = PulseAccount.fromJson(
      raw is Map<String, dynamic> ? raw : const {},
    );
    _accountUUID = account.timeClockAccountUUID;
    onSession?.call(account);
    return account;
  }

  Future<PulseAccount> signIn(String loginCode, String password) async =>
      _accept(
        await _send(
          'POST',
          '/pulse/auth/signin',
          auth: false,
          body: {
            'loginCode': loginCode,
            'password': password,
            'clientKind': clientKind,
            'platform': _platform,
          },
        ),
      );

  PulseAccount? _restored;

  /// Rotates the refresh token (cookie on the web). False when there is no live session.
  Future<bool> refresh() {
    return _refreshing ??= () async {
      try {
        if (!kIsWeb) _refreshToken ??= await refreshStore?.read();
        lastRefreshOffline = false;
        _restored = _accept(
          await _send(
            'POST',
            '/pulse/auth/refresh',
            auth: false,
            body: {
              'clientKind': clientKind,
              'platform': _platform,
              if (_refreshToken != null) 'refreshToken': _refreshToken,
            },
          ),
        );
        return true;
      } on PulseFailure catch (failure) {
        if (failure.code == 'networkError') {
          lastRefreshOffline = true;
        } else if (!failure.versionUnsupported) {
          // A refused app version keeps the session for after the update.
          _accessToken = null;
          _refreshToken = null;
          unawaited(refreshStore?.write(null));
        }
        return false;
      } finally {
        _refreshing = null;
      }
    }();
  }

  /// Reopens the session kept by the HttpOnly cookie (web reload) without typing the password.
  Future<PulseAccount?> restore() async => await refresh() ? _restored : null;

  Future<void> signOut() async {
    try {
      if (_accessToken != null) await _send('POST', '/pulse/auth/signout');
    } catch (_) {
      // The local session ends anyway; the server session expires by itself.
    } finally {
      _accessToken = null;
      _refreshToken = null;
      _accountUUID = null;
      unawaited(refreshStore?.write(null));
    }
  }

  Future<void> changePassword(String current, String next) async {
    await call(
      'POST',
      '/pulse/auth/change-password',
      body: {'currentPassword': current, 'newPassword': next},
    );
  }

  Future<DateTime?> serverTime() async {
    try {
      final data = await _send('GET', '/pulse/time', auth: false);
      return DateTime.tryParse(
        (data['data'] as Map<String, dynamic>?)?['serverTime']?.toString() ??
            '',
      );
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> createPunch(Map<String, dynamic> body) async {
    final data = await call('POST', '/pulse/punches', body: body);
    final item = (data['data'] as Map<String, dynamic>?)?['item'];
    return item is Map<String, dynamic> ? item : const {};
  }

  /// Registers or renews the offline grant of this device key (live session required).
  Future<Map<String, dynamic>> registerDevice(Map<String, dynamic> body) async {
    final data = await call('POST', '/pulse/devices', body: body);
    final item = (data['data'] as Map<String, dynamic>?)?['item'];
    if (item is! Map<String, dynamic>) throw const PulseFailure('requestError');
    return item;
  }

  /// A queued mark signed by this device, sent without a session: [rawBody] is exactly the signed
  /// body and [headers] carry the device, time, counter and signature.
  Future<Map<String, dynamic>> createDevicePunch(
    String rawBody,
    Map<String, String> headers,
  ) async {
    final data = await _send(
      'POST',
      '/pulse/device/punches',
      rawBody: rawBody,
      headers: headers,
      auth: false,
    );
    final item = (data['data'] as Map<String, dynamic>?)?['item'];
    return item is Map<String, dynamic> ? item : const {};
  }

  Future<List<Map<String, dynamic>>> listPunches({int limit = 30}) async {
    final data = await call('GET', '/pulse/punches?limit=$limit');
    final items = (data['data'] as Map<String, dynamic>?)?['items'];
    return items is List
        ? items.whereType<Map<String, dynamic>>().toList()
        : const [];
  }

  /// Today of the employee: expected shift, marks and live worked minutes (results only, never
  /// the rules behind them).
  Future<Map<String, dynamic>> today() async {
    final data = await call('GET', '/pulse/today');
    final body = data['data'];
    if (body is! Map<String, dynamic> || body['date'] is! String) {
      throw const PulseFailure('requestError');
    }
    return body;
  }

  /// Monthly timesheet (`month` is YYYY-MM): consolidated days with their marks and the totals.
  Future<Map<String, dynamic>> timesheet(String month) async {
    final data = await call('GET', '/pulse/timesheet?month=$month');
    final body = data['data'];
    if (body is! Map<String, dynamic>) throw const PulseFailure('requestError');
    return body;
  }

  /// Own requests (missing mark, punch contest, absence) with their outcome, newest first.
  Future<List<Map<String, dynamic>>> listRequests({int limit = 50}) async {
    final data = await call('GET', '/pulse/requests?limit=$limit');
    final items = (data['data'] as Map<String, dynamic>?)?['items'];
    return items is List
        ? items.whereType<Map<String, dynamic>>().toList()
        : const [];
  }

  /// Sends a request; [body] carries the client `uuid`, so a retry returns the stored one.
  Future<void> createRequest(Map<String, dynamic> body) async {
    await call('POST', '/pulse/requests', body: body);
  }

  Future<void> cancelRequest(String uuid) async {
    await call('POST', '/pulse/requests/$uuid/cancel');
  }

  /// Uploads a medical certificate before the absence request; returns its UUID.
  Future<String> uploadAttachment(
    String attachmentUUID,
    List<int> bytes,
    String fileName,
  ) async {
    final data = await _upload(
      '/pulse/attachments',
      {'attachmentUUID': attachmentUUID},
      bytes,
      fileName,
    );
    final item = (data['data'] as Map<String, dynamic>?)?['item'];
    final uuid = item is Map<String, dynamic>
        ? item['AttachmentUUID']?.toString()
        : null;
    if (uuid == null || uuid.isEmpty) throw const PulseFailure('requestError');
    return uuid;
  }
}
