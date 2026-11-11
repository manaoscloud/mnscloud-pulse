import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../core/pulse_api.dart';
import 'receipt_print.dart';

/// Comprovante de Registro de Ponto do Trabalhador (Portaria MTP 671/2021 art. 79) as the API
/// returns it; on a shared time clock the employee document comes masked.
class PunchReceipt {
  const PunchReceipt({
    required this.title,
    required this.punchUUID,
    required this.typeLabel,
    required this.occurredAtText,
    required this.employerName,
    required this.employeeName,
    required this.collector,
    this.nsr,
    this.hash,
    this.employerDocument,
    this.employeeDocument,
    this.offline = false,
    this.emailAllowed = false,
  });

  factory PunchReceipt.fromJson(Map<String, dynamic> json) => PunchReceipt(
    title:
        json['Title']?.toString() ??
        'Comprovante de Registro de Ponto do Trabalhador',
    punchUUID: json['TimePunchUUID']?.toString() ?? '',
    nsr: json['NSR']?.toString(),
    hash: json['Hash']?.toString(),
    typeLabel: json['TypeLabel']?.toString() ?? '',
    occurredAtText: json['OccurredAtText']?.toString() ?? '',
    offline: json['Offline'] == true,
    employerName: json['EmployerName']?.toString() ?? '',
    employerDocument: json['EmployerDocument']?.toString(),
    employeeName: json['EmployeeName']?.toString() ?? '',
    employeeDocument: json['EmployeeDocument']?.toString(),
    collector: json['Collector']?.toString() ?? '',
    emailAllowed: json['EmailAllowed'] == true,
  );

  final String title;
  final String punchUUID;
  final String? nsr;
  final String? hash;
  final String typeLabel;
  final String occurredAtText;
  final bool offline;
  final String employerName;
  final String? employerDocument;
  final String employeeName;
  final String? employeeDocument;
  final String collector;
  final bool emailAllowed;
}

String _escape(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

/// Printable page (A4 or 80 mm thermal paper) with the fields of art. 79.
String receiptHtml(PunchReceipt r) {
  String row(String label, String? value) => value == null || value.isEmpty
      ? ''
      : '<tr><th>${_escape(label)}</th><td>${_escape(value)}</td></tr>';
  return '''<!doctype html><html lang="pt-BR"><head><meta charset="utf-8">
<title>${_escape(r.title)}</title>
<style>
@page { margin: 8mm; }
body { font: 12px/1.4 Arial, Helvetica, sans-serif; color: #000; max-width: 80mm; margin: 0 auto; }
h1 { font-size: 14px; margin: 0 0 8px; text-align: center; }
table { width: 100%; border-collapse: collapse; }
th, td { text-align: left; vertical-align: top; padding: 3px 0; border-bottom: 1px dashed #999; }
th { width: 40%; padding-right: 6px; }
td.hash { word-break: break-all; font-family: monospace; font-size: 10px; }
p { font-size: 10px; margin-top: 8px; }
</style></head><body>
<h1>${_escape(r.title)}</h1>
<table>
${row('Empregador', r.employerName)}
${row('CNPJ/CPF do empregador', r.employerDocument)}
${row('Trabalhador', r.employeeName)}
${row('CPF do trabalhador', r.employeeDocument)}
${row('Marcação', r.typeLabel)}
${row('Data e hora', r.occurredAtText)}
${row('NSR', r.nsr)}
${row('Coletor', r.collector)}
<tr><th>Código de verificação (SHA-256)</th><td class="hash">${_escape(r.hash ?? '—')}</td></tr>
</table>
${r.offline ? '<p>Marcação feita sem conexão: hora do aparelho corrigida pela hora oficial.</p>' : ''}
</body></html>''';
}

/// Print and e-mail of one receipt. [load] reads it, [email] sends it and answers the masked
/// recipient. Shown under the receipt on the time clock and in the personal Pulse.
class ReceiptActions extends StatefulWidget {
  const ReceiptActions({
    super.key,
    required this.load,
    required this.email,
    this.emailVisible = true,
    this.printer = printReceiptHtml,
    this.printAvailable,
    this.onActivity,
  });

  /// Called on every tap (the time clock keeps the receipt on screen meanwhile).
  final VoidCallback? onActivity;

  final Future<PunchReceipt> Function() load;
  final Future<String?> Function() email;
  final bool emailVisible;
  final Future<void> Function(String html) printer;

  /// Replaced only by tests; the platform decides otherwise.
  final bool? printAvailable;

  @override
  State<ReceiptActions> createState() => _ReceiptActionsState();
}

class _ReceiptActionsState extends State<ReceiptActions> {
  bool _busy = false;
  String? _message;
  bool _error = false;

  AppLocalizations get l => AppLocalizations.of(context)!;

  String _failure(PulseFailure failure) => switch (failure.code) {
    'PULSE_RECEIPT_NO_EMAIL' => l.receiptNoEmail,
    'PULSE_RECEIPT_EMAIL_DISABLED' => l.receiptEmailDisabled,
    'PULSE_RATE_LIMITED' => l.receiptEmailLimit,
    'networkError' => l.networkError,
    _ => l.receiptFailed,
  };

  Future<void> _run(Future<String?> Function() task) async {
    if (_busy) return;
    widget.onActivity?.call();
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final message = await task();
      if (mounted) {
        setState(() {
          _message = message;
          _error = false;
        });
      }
    } on PulseFailure catch (failure) {
      if (mounted) {
        setState(() {
          _message = _failure(failure);
          _error = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _message = l.receiptFailed;
          _error = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _print() async {
    await widget.printer(receiptHtml(await widget.load()));
    return null;
  }

  Future<String?> _email() async {
    final recipient = await widget.email();
    return l.receiptEmailSent(recipient ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canPrint = widget.printAvailable ?? receiptPrintAvailable;
    if (!canPrint && !widget.emailVisible) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            if (canPrint)
              OutlinedButton.icon(
                key: const Key('receiptPrint'),
                onPressed: _busy ? null : () => _run(_print),
                icon: const Icon(Icons.print_outlined),
                label: Text(l.receiptPrint),
              ),
            if (widget.emailVisible)
              OutlinedButton.icon(
                key: const Key('receiptEmail'),
                onPressed: _busy ? null : () => _run(_email),
                icon: const Icon(Icons.mail_outline),
                label: Text(l.receiptEmail),
              ),
          ],
        ),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _message!,
              key: const Key('receiptMessage'),
              textAlign: TextAlign.center,
              style: TextStyle(color: _error ? scheme.error : scheme.primary),
            ),
          ),
      ],
    );
  }
}
