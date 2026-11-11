import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../core/pulse_api.dart';
import 'kiosk_client.dart';

/// One-time activation of this device as the company time clock: the code HR generated in the App
/// and a local administrator PIN that unlocks leaving the time clock mode.
class KioskActivationView extends StatefulWidget {
  const KioskActivationView({
    super.key,
    required this.client,
    required this.onActivated,
    required this.onCancel,
  });

  final KioskClient client;
  final void Function(KioskProfile profile) onActivated;
  final VoidCallback onCancel;

  @override
  State<KioskActivationView> createState() => _KioskActivationViewState();
}

class _KioskActivationViewState extends State<KioskActivationView> {
  final _form = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _error;

  AppLocalizations get l => AppLocalizations.of(context)!;

  @override
  void dispose() {
    _code.dispose();
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String _failure(PulseFailure failure) => switch (failure.code) {
    'PULSE_KIOSK_ACTIVATION_INVALID' => l.kioskCodeInvalid,
    'PULSE_DEVICE_KEY_REJECTED' ||
    'PULSE_KIOSK_SIGNATURE_INVALID' => l.kioskKeyRejected,
    'PULSE_KIOSK_CLOCK_SKEW' => l.kioskClockSkew,
    'PULSE_MODULE_UNAVAILABLE' => l.moduleUnavailable,
    'PULSE_KIOSK_INVALID' => l.kioskRevoked,
    'networkError' => l.networkError,
    _ => l.requestError,
  };

  Future<void> _activate() async {
    if (_busy || !(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final profile = await widget.client.activate(_code.text, _pin.text);
      if (mounted) widget.onActivated(profile);
    } on PulseFailure catch (failure) {
      if (mounted) setState(() => _error = _failure(failure));
    } catch (_) {
      if (mounted) setState(() => _error = l.requestError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      key: const Key('kioskActivation'),
      appBar: AppBar(
        title: Text(l.kioskActivationTitle),
        leading: IconButton(
          tooltip: l.back,
          onPressed: _busy ? null : widget.onCancel,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(l.kioskActivationHelp),
                  const SizedBox(height: 20),
                  TextFormField(
                    key: const Key('kioskCode'),
                    controller: _code,
                    autofocus: true,
                    textCapitalization: TextCapitalization.characters,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: l.kioskActivationCode,
                      hintText: 'XXXX-XXXX',
                    ),
                    validator: (value) =>
                        normalizeKioskCode(value ?? '') == null
                        ? l.kioskCodeInvalid
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('kioskAdminPin'),
                    controller: _pin,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(labelText: l.kioskAdminPin),
                    validator: (value) =>
                        RegExp(r'^\d{4,8}$').hasMatch(value ?? '')
                        ? null
                        : l.kioskAdminPinInvalid,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('kioskAdminPinConfirm'),
                    controller: _confirm,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: l.kioskAdminPinConfirm,
                    ),
                    validator: (value) =>
                        value != _pin.text ? l.kioskPinMismatch : null,
                    onFieldSubmitted: (_) => _activate(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      key: const Key('kioskActivationError'),
                      style: TextStyle(color: scheme.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('kioskActivate'),
                    onPressed: _busy ? null : _activate,
                    child: Text(l.kioskActivate),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.kioskPinFixHint,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
