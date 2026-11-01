import 'dart:convert';

import 'package:http/http.dart' as http;

import 'client_identity.dart';
import 'runtime_version.dart';

/// Reads the minimum version accepted for [platform] from the public client policy
/// (`GET <apiBase>/public/clients/pulse/policy`). Null when there is none, when no absolute API
/// base is known yet or when the endpoint fails (fail open).
Future<String?> fetchClientMinimum({
  required String platform,
  http.Client? client,
  String? baseUrl,
}) async {
  final base = normalizedApiBase(baseUrl);
  final uri = Uri.tryParse('$base/public/clients/$clientPolicyApp/policy');
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
  final http.Client http0 = client ?? http.Client();
  try {
    final response = await http0
        .get(uri, headers: clientHeaders(platform: platform))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return null;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) return null;
    if (data['app'] != null && data['app'] != clientPolicyApp) return null;
    final minimum = data['minimum'];
    if (minimum is! Map<String, dynamic>) return null;
    final version = normalizeVersion(minimum[platform]?.toString());
    return isReleaseVersion(version) ? version : null;
  } catch (_) {
    return null;
  } finally {
    if (client == null) http0.close();
  }
}
