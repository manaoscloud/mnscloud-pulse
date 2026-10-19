import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'brand_dom.dart';

/// Brand of the host for Pulse (Settings › Themes › Pulse tab of the tenant domain); every field
/// the Pulse tab leaves empty comes from the App brand. Null fields keep the MNSCloud defaults.
class Brand {
  const Brand({this.title, this.logoUrl, this.faviconUrl, this.primaryColor});

  final String? title;
  final String? logoUrl;
  final String? faviconUrl;
  final Color? primaryColor;

  /// Body of `GET /public/theme/context?app=pulse`: `{ data: { context: {...} | null } }`.
  static Brand? fromResponse(dynamic body) {
    final data = body is Map ? body['data'] : null;
    final context = data is Map ? data['context'] : null;
    if (context is! Map) return null;
    String? text(Object? value) {
      final result = value?.toString().trim();
      return result == null || result.isEmpty ? null : result;
    }

    return Brand(
      title: text(context['PageTitle']),
      logoUrl: safeImageUrl(text(context['LogoUrl'])),
      faviconUrl: safeImageUrl(text(context['FaviconUrl'])),
      primaryColor: parseHexColor(text(context['PrimaryColor'])),
    );
  }

  /// Only images uploaded to the theme (same origin) or https addresses are shown.
  static String? safeImageUrl(String? url) {
    if (url == null) return null;
    if (RegExp(r'^/api/v1/public/theme/assets/[0-9a-f]{32}$').hasMatch(url)) {
      return url;
    }
    final uri = Uri.tryParse(url);
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty
        ? url
        : null;
  }

  static Color? parseHexColor(String? value) {
    final match = RegExp(r'^#([0-9a-fA-F]{6})$').firstMatch(value ?? '');
    return match == null
        ? null
        : Color(0xFF000000 | int.parse(match.group(1)!, radix: 16));
  }
}

/// Brand of the current host; null keeps the MNSCloud Pulse defaults.
final ValueNotifier<Brand?> pulseBrand = ValueNotifier<Brand?>(null);

const _apiBaseUrl = String.fromEnvironment(
  'PULSE_PUBLIC_API_BASE_URL',
  defaultValue: '/api/v1',
);

/// Loads the Pulse brand of the domain. Never blocks or fails Pulse.
Future<void> loadPulseBrand({http.Client? client}) async {
  final base = _apiBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
  final http.Client http0 = client ?? http.Client();
  try {
    final response = await http0
        .get(Uri.parse('$base/public/theme/context?app=pulse'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) return;
    final brand = Brand.fromResponse(jsonDecode(response.body));
    if (brand == null) return;
    final favicon = brand.faviconUrl;
    if (favicon != null) applyFavicon(favicon);
    pulseBrand.value = brand;
  } catch (_) {
    // No brand: the MNSCloud defaults stay.
  } finally {
    if (client == null) http0.close();
  }
}
