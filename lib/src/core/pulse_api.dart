import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Public failure of a Pulse call: the API code (`PULSE_*`), `networkError` or `requestError`.
class PulseFailure implements Exception {
  const PulseFailure(this.code, {this.status});
  final String code;
  final int? status;

  bool get sessionEnded =>
      code == 'PULSE_SESSION_INVALID' ||
      code == 'PULSE_ACCESS_DENIED' ||
      code == 'PULSE_MODULE_UNAVAILABLE';

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
  });

  factory PulseAccount.fromJson(Map<String, dynamic> json) => PulseAccount(
    timeClockAccountUUID: json['timeClockAccountUUID']?.toString() ?? '',
    loginCode: json['loginCode']?.toString() ?? '',
    mustChangePassword: json['mustChangePassword'] == true,
    employeeName: json['employeeName']?.toString(),
    companyName: json['companyName']?.toString(),
  );

  final String timeClockAccountUUID;
  final String loginCode;
  final bool mustChangePassword;
  final String? employeeName;
  final String? companyName;

  PulseAccount passwordChanged() => PulseAccount(
    timeClockAccountUUID: timeClockAccountUUID,
    loginCode: loginCode,
    mustChangePassword: false,
    employeeName: employeeName,
    companyName: companyName,
  );
}

/// Pulse API client. The session is a short-lived access token in memory plus a rotating refresh
/// token: on the web it lives only in the HttpOnly cookie set by the API (same origin), on native
/// builds it stays in memory until secure storage ships with the store apps.
class PulseApi {
  PulseApi({this._client, String? baseUrl})
    : _base = (baseUrl ?? _defaultBase).trim().replaceAll(RegExp(r'/+$'), '');

  static const _defaultBase = String.fromEnvironment(
    'PULSE_PUBLIC_API_BASE_URL',
    defaultValue: '/api/v1',
  );

  final http.Client? _client;
  final String _base;
  String? _accessToken;
  String? _refreshToken;
  Future<bool>? _refreshing;

  /// Called with the server time of every session answer, to measure the clock offset.
  void Function(DateTime serverTime)? onServerTime;

  bool get signedIn => _accessToken != null;
  String get clientKind => kIsWeb ? 'web' : 'native';

  String get _platform => kIsWeb
      ? 'web'
      : switch (defaultTargetPlatform) {
          TargetPlatform.android => 'android',
          TargetPlatform.iOS => 'ios',
          TargetPlatform.windows => 'windows',
          TargetPlatform.macOS => 'macos',
          TargetPlatform.linux => 'linux',
          _ => 'web',
        };

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final request = http.Request(method, Uri.parse('$_base$path'));
    request.headers['content-type'] = 'application/json';
    if (auth && _accessToken != null) {
      request.headers['authorization'] = 'Bearer $_accessToken';
    }
    if (body != null) request.body = jsonEncode(body);
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
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final code = data['code'];
      throw PulseFailure(
        code is String && code.isNotEmpty
            ? code
            : response.statusCode == 429
            ? 'PULSE_RATE_LIMITED'
            : 'requestError',
        status: response.statusCode,
      );
    }
    return data;
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
    if (refresh is String && refresh.isNotEmpty) _refreshToken = refresh;
    final serverTime = DateTime.tryParse(data['serverTime']?.toString() ?? '');
    if (serverTime != null) onServerTime?.call(serverTime);
    final account = data['account'];
    return PulseAccount.fromJson(
      account is Map<String, dynamic> ? account : const {},
    );
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
        if (failure.code != 'networkError') {
          _accessToken = null;
          _refreshToken = null;
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

  Future<List<Map<String, dynamic>>> listPunches({int limit = 30}) async {
    final data = await call('GET', '/pulse/punches?limit=$limit');
    final items = (data['data'] as Map<String, dynamic>?)?['items'];
    return items is List
        ? items.whereType<Map<String, dynamic>>().toList()
        : const [];
  }
}
