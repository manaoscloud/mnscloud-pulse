import 'package:flutter/foundation.dart';

import 'app_build_info.dart';
import 'runtime_version.dart';

/// API base of every Pulse call (same origin `/api/v1` on the web build).
const pulseApiBaseUrl = String.fromEnvironment(
  'PULSE_PUBLIC_API_BASE_URL',
  defaultValue: '/api/v1',
);

/// [pulseApiBaseUrl] without trailing slashes.
String normalizedApiBase([String? base]) =>
    (base ?? pulseApiBaseUrl).trim().replaceAll(RegExp(r'/+$'), '');

/// Policy app name of Pulse in `GET /public/clients/<app>/policy`.
const clientPolicyApp = 'pulse';

/// API code of a refused installed app below the minimum of its platform (HTTP 426).
const clientVersionUnsupportedCode = 'CLIENT_VERSION_UNSUPPORTED';

/// Platform sent in `X-Mns-Client-Platform`: `web` on the web build, otherwise the installed
/// platform (`android`, `ios`, `windows`, `macos`, `linux`).
String clientPlatformName() => kIsWeb
    ? 'web'
    : switch (defaultTargetPlatform) {
        TargetPlatform.android => 'android',
        TargetPlatform.iOS => 'ios',
        TargetPlatform.windows => 'windows',
        TargetPlatform.macOS => 'macos',
        TargetPlatform.linux => 'linux',
        _ => 'web',
      };

/// Identity headers carried by every API call of the app.
Map<String, String> clientHeaders({String? platform}) => {
  'X-Mns-Client':
      '${appBuildInfo.product}/${normalizeVersion(appBuildInfo.version)}',
  'X-Mns-Client-Platform': platform ?? clientPlatformName(),
};

/// Set when any API answer is 426 `CLIENT_VERSION_UNSUPPORTED`: the running installed app is no
/// longer accepted and must be updated (the version cannot change while it runs).
final ValueNotifier<bool> clientVersionRejected = ValueNotifier<bool>(false);

/// Records an API answer; true when it refused this app version.
bool noteClientVersionAnswer(int status, Object? code) {
  if (status != 426 || code != clientVersionUnsupportedCode) return false;
  clientVersionRejected.value = true;
  return true;
}
