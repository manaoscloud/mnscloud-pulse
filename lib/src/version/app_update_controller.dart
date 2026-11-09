import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app_build_info.dart';
import 'client_identity.dart';
import 'client_policy.dart';
import 'runtime_version.dart';
import 'runtime_version_fetcher_stub.dart'
    if (dart.library.js_interop) 'runtime_version_fetcher_web.dart'
    as platform;

typedef DeployedVersionReader = Future<RuntimeReleaseInfo?> Function();

/// Reads the minimum accepted version of the installed platform (null: none or unknown).
typedef ClientMinimumReader = Future<String?> Function();

/// Detects that a newer Pulse release went live while the app stays open.
///
/// Web: it reads the release `build.json` on start, every ~5 minutes while the
/// page is visible and when the page becomes visible again, and accepts a
/// different version only after two reads agree [confirmDelay] apart. It never
/// reloads by itself: the UI shows a calm notice and the user updates when
/// convenient.
///
/// Installed apps update through their store: the controller reads the public
/// client policy on start, every [policyInterval] and on return to the
/// foreground, and only a running version below the minimum of its platform
/// (or an API answer 426 `CLIENT_VERSION_UNSUPPORTED`) shows a notice, always
/// critical. A failed read shows nothing (fail open).
class AppUpdateController extends ChangeNotifier {
  AppUpdateController({
    DeployedVersionReader? reader,
    ClientMinimumReader? minimumReader,
    String? runningVersion,
    DateTime Function()? clock,
    bool? web,
    String? clientPlatform,
    ValueListenable<bool>? rejection,
  }) : _reader =
           reader ??
           (() => platform.fetchLatestRuntimeRelease(appBuildInfo.product)),
       isWeb = web ?? kIsWeb,
       clientPlatform = clientPlatform ?? clientPlatformName(),
       _rejection = rejection ?? clientVersionRejected,
       runningVersion = normalizeVersion(
         runningVersion ?? appBuildInfo.version,
       ),
       _clock = clock ?? DateTime.now {
    final target = this.clientPlatform;
    _minimumReader =
        minimumReader ?? (() => fetchClientMinimum(platform: target));
  }

  static const pollInterval = Duration(minutes: 5);
  static const minCheckGap = Duration(minutes: 1);
  static const confirmDelay = Duration(seconds: 45);
  static const snoozeDuration = Duration(hours: 4);
  static const _snoozeKey = 'mnscloud_pulse_update_snooze';
  static const policyInterval = Duration(hours: 6);

  final DeployedVersionReader _reader;
  late final ClientMinimumReader _minimumReader;
  final ValueListenable<bool> _rejection;

  /// Web build (build.json notice); false on installed apps (client policy).
  final bool isWeb;

  /// Installed platform whose minimum applies (`android`, `ios`, ...).
  final String clientPlatform;
  final DateTime Function() _clock;
  final String runningVersion;

  RuntimeReleaseInfo? _deployed;
  ({String version, DateTime seenAt})? _candidate;
  ({String version, DateTime until})? _snooze;
  DateTime? _lastCheckAt;
  Future<void>? _inFlight;
  Timer? _pollTimer;
  Timer? _confirmTimer;
  bool _started = false;
  bool _disposed = false;
  String? _minimum;
  bool _rejected = false;
  Future<void>? _policyInFlight;
  Timer? _policyTimer;
  AppLifecycleListener? _lifecycle;

  /// Minimum accepted version of [clientPlatform] from the last successful policy read.
  String? get minimumVersion => _minimum;

  RuntimeReleaseInfo? get deployed => _deployed;

  bool get updateAvailable {
    final version = _deployed?.version;
    return version != null && version != runningVersion;
  }

  /// The running bundle is below the release `minimumVersion`: the notice
  /// cannot be postponed (it still never reloads by itself).
  bool get critical {
    if (!isWeb) {
      final minimum = _minimum;
      return _rejected ||
          (minimum != null && compareSemver(runningVersion, minimum) < 0);
    }
    final minimum = _deployed?.minimumVersion;
    return minimum != null &&
        updateAvailable &&
        compareSemver(runningVersion, minimum) < 0;
  }

  bool get noticeVisible {
    if (!isWeb) return critical;
    if (!updateAvailable) return false;
    if (critical) return true;
    final snooze = _snooze;
    return snooze == null ||
        snooze.version != _deployed!.version ||
        !snooze.until.isAfter(_clock());
  }

  /// Starts background detection: build.json on the web build, the client
  /// policy on installed apps (they update through their store).
  void start() {
    if (_started) return;
    _started = true;
    if (!isWeb) {
      _startPolicy();
      return;
    }
    _snooze = _readSnooze();
    platform.listenPageVisible(() => unawaited(check()));
    _schedulePoll();
    unawaited(check(force: true));
  }

  Future<void> check({bool force = false}) {
    final pending = _inFlight;
    if (pending != null) return pending;
    final now = _clock();
    final last = _lastCheckAt;
    if (!force && last != null && now.difference(last) < minCheckGap) {
      return Future.value();
    }
    _lastCheckAt = now;
    final future = _reader()
        .then((build) {
          if (build?.version != null && !_disposed) observe(build!, _clock());
        })
        .catchError((Object _) {})
        .whenComplete(() => _inFlight = null);
    _inFlight = future;
    return future;
  }

  /// Feeds one `build.json` read into the confirmation state.
  @visibleForTesting
  void observe(RuntimeReleaseInfo build, DateTime at) {
    final version = normalizeVersion(build.version);
    if (version.isEmpty) return;
    final current = _deployed;
    if (version == (current?.version ?? runningVersion)) {
      _candidate = null;
      _confirmTimer?.cancel();
      if (current == null || current.minimumVersion != build.minimumVersion) {
        _deployed = RuntimeReleaseInfo(
          version: version,
          buildRef: build.buildRef,
          minimumVersion: build.minimumVersion,
        );
        notifyListeners();
      }
      return;
    }
    final candidate = _candidate;
    if (candidate != null && candidate.version == version) {
      if (at.difference(candidate.seenAt) >= confirmDelay) {
        _candidate = null;
        _confirmTimer?.cancel();
        _deployed = RuntimeReleaseInfo(
          version: version,
          buildRef: build.buildRef,
          minimumVersion: build.minimumVersion,
        );
        notifyListeners();
      }
      return;
    }
    _candidate = (version: version, seenAt: at);
    _confirmTimer?.cancel();
    if (_started) {
      _confirmTimer = Timer(confirmDelay, () => unawaited(check(force: true)));
    }
  }

  /// "Later": hide the notice for this version for a few hours.
  void postpone() {
    final version = _deployed?.version;
    if (version == null) return;
    _snooze = (version: version, until: _clock().add(snoozeDuration));
    platform.writeUpdateSnooze(
      _snoozeKey,
      jsonEncode({
        'version': version,
        'until': _snooze!.until.millisecondsSinceEpoch,
      }),
    );
    notifyListeners();
  }

  void reloadNow() => platform.reloadPage();

  void _startPolicy() {
    _rejection.addListener(_onRejection);
    _onRejection();
    _policyTimer = Timer.periodic(
      policyInterval,
      (_) => unawaited(checkPolicy()),
    );
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(checkPolicy()));
    unawaited(checkPolicy());
  }

  void _onRejection() {
    if (!_rejection.value || _rejected || _disposed) return;
    markUnsupported();
  }

  /// An API answer refused this app version: the notice turns critical.
  void markUnsupported() {
    if (_rejected) return;
    _rejected = true;
    notifyListeners();
  }

  /// Reads the minimum of [clientPlatform]; no minimum or a failed read (null)
  /// shows nothing (fail open).
  Future<void> checkPolicy() {
    final pending = _policyInFlight;
    if (pending != null) return pending;
    final future = _minimumReader()
        .then((minimum) {
          if (_disposed) return;
          final version = normalizeVersion(minimum);
          final next = isReleaseVersion(version) ? version : null;
          if (next == _minimum) return;
          _minimum = next;
          notifyListeners();
        }, onError: (Object _) {})
        .whenComplete(() => _policyInFlight = null);
    _policyInFlight = future;
    return future;
  }

  void _schedulePoll() {
    final jitter = Duration(seconds: Random().nextInt(60) - 30);
    _pollTimer = Timer(pollInterval + jitter, () {
      if (platform.isPageVisible()) unawaited(check());
      if (!_disposed) _schedulePoll();
    });
  }

  ({String version, DateTime until})? _readSnooze() {
    try {
      final raw = platform.readUpdateSnooze(_snoozeKey);
      if (raw == null) return null;
      final value = jsonDecode(raw);
      if (value is! Map) return null;
      final version = value['version'];
      final until = value['until'];
      if (version is! String || until is! int) return null;
      return (
        version: version,
        until: DateTime.fromMillisecondsSinceEpoch(until),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _pollTimer?.cancel();
    _policyTimer?.cancel();
    _lifecycle?.dispose();
    _rejection.removeListener(_onRejection);
    _confirmTimer?.cancel();
    super.dispose();
  }
}
