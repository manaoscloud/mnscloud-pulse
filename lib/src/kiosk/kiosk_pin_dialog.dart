import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../core/pulse_api.dart';

/// Same rule as the API: 4 to 6 digits, not one repeated digit, not an ascending or descending run.
bool validKioskPin(String pin) {
  if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) return false;
  final digits = pin.split('').map(int.parse).toList();
  if (digits.every((d) => d == digits.first)) return false;
  final step = digits[1] - digits[0];
  if (step == 1 || step == -1) {
    var run = true;
    for (var i = 1; i < digits.length; i++) {
      if (digits[i] - digits[i - 1] != step) run = false;
    }
    if (run) return false;
  }
  return true;
}

/// The signed-in employee sets the personal PIN used on the company time clocks.
Future<void> showKioskPinDialog(BuildContext context, PulseApi api) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => _KioskPinDialog(api: api),
  );
  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.kioskPinSaved)),
    );
  }
}

class _KioskPinDialog extends StatefulWidget {
  const _KioskPinDialog({required this.api});
  final PulseApi api;

  @override
  State<_KioskPinDialog> createState() => _KioskPinDialogState();
}

class _KioskPinDialogState extends State<_KioskPinDialog> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _error;

  AppLocalizations get l => AppLocalizations.of(context)!;

  @override
  void dispose() {
    _password.dispose();
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy || !(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.api.setKioskPin(_password.text, _pin.text);
      if (mounted) Navigator.of(context).pop(true);
    } on PulseFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = switch (failure.code) {
          'PULSE_INVALID_PASSWORD' => l.invalidPassword,
          'PULSE_KIOSK_PIN_INVALID' => l.kioskPinInvalid,
          'networkError' => l.networkError,
          _ => l.requestError,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration field(String label) => InputDecoration(labelText: label);
    return AlertDialog(
      key: const Key('kioskPinDialog'),
      title: Text(l.kioskPinMenu),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.kioskPinHelp),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('kioskPinPassword'),
                controller: _password,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                decoration: field(l.kioskPinCurrentPassword),
                validator: (v) => (v ?? '').isEmpty ? l.required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('kioskPinNew'),
                controller: _pin,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: field(l.kioskPinNew),
                validator: (v) =>
                    validKioskPin(v ?? '') ? null : l.kioskPinInvalid,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('kioskPinConfirm'),
                controller: _confirm,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: field(l.kioskPinConfirm),
                validator: (v) => v != _pin.text ? l.kioskPinMismatch : null,
                onFieldSubmitted: (_) => _save(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  key: const Key('kioskPinError'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: Text(l.cancel),
        ),
        FilledButton(
          key: const Key('kioskPinSave'),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: _busy ? null : _save,
          child: Text(l.kioskPinSave),
        ),
      ],
    );
  }
}
