import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Only a language preference is persisted; credentials and sessions never enter this store.
final accessLocale = ValueNotifier<Locale?>(null);
Future<void> loadAccessLocale() async {
  try {
    final value = (await SharedPreferences.getInstance()).getString(
      'pulse.language',
    );
    accessLocale.value = parseAccessLocale(value);
  } catch (_) {
    /* System language remains available when storage is denied. */
  }
}

Locale? parseAccessLocale(String? value) => switch (value) {
  'pt-BR' => const Locale('pt', 'BR'),
  'es-ES' => const Locale('es', 'ES'),
  'en-US' => const Locale('en', 'US'),
  _ => null,
};
Future<void> setAccessLocale(String value) async {
  accessLocale.value = parseAccessLocale(value);
  try {
    await (await SharedPreferences.getInstance()).setString(
      'pulse.language',
      value,
    );
  } catch (_) {}
}
