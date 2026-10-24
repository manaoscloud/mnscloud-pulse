import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mnscloud_pulse/main.dart';
import 'package:mnscloud_pulse/src/brand/brand.dart';

void main() {
  tearDown(() => pulseBrand.value = null);

  test('the Pulse brand comes from the theme context of the host', () async {
    late Uri asked;
    final client = MockClient((request) async {
      asked = request.url;
      return http.Response(
        jsonEncode({
          'data': {
            'context': {
              'PageTitle': 'Loja Centro Ponto',
              'LogoUrl': 'https://cdn.example.com/logo.png',
              'FaviconUrl': 'http://insecure.example/favicon.png',
              'PrimaryColor': '#7c3aed',
            },
          },
        }),
        200,
      );
    });
    await loadPulseBrand(client: client);
    expect(asked.path, endsWith('/public/theme/context'));
    expect(asked.queryParameters['app'], 'pulse');
    final brand = pulseBrand.value!;
    expect(brand.title, 'Loja Centro Ponto');
    expect(brand.logoUrl, 'https://cdn.example.com/logo.png');
    expect(brand.faviconUrl, isNull);
    expect(brand.primaryColor, const Color(0xFF7C3AED));
  });

  test('no theme or a failing API keeps the defaults', () async {
    await loadPulseBrand(
      client: MockClient(
        (_) async => http.Response('{"data":{"context":null}}', 200),
      ),
    );
    expect(pulseBrand.value, isNull);
    await loadPulseBrand(
      client: MockClient((_) async => http.Response('oops', 500)),
    );
    expect(pulseBrand.value, isNull);
  });

  testWidgets('title and header follow the brand', (tester) async {
    await tester.pumpWidget(const PulseApp());
    await tester.pumpAndSettle();
    expect(find.text('MNSCloud Pulse'), findsOneWidget);
    pulseBrand.value = const Brand(title: 'Loja Centro Ponto');
    await tester.pumpAndSettle();
    expect(find.text('Loja Centro Ponto'), findsOneWidget);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).title,
      'Loja Centro Ponto',
    );
  });
}
