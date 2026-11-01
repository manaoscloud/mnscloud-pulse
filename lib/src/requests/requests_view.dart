import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../core/ids.dart';
import '../core/pulse_api.dart';
import '../core/server_clock.dart';
import '../punch/punch_labels.dart';

const requestTypes = ['missing_punch', 'punch_contest', 'absence'];
const absenceTypes = ['medical_certificate', 'justified', 'day_off', 'leave'];

String requestTypeLabel(AppLocalizations l, String type) => switch (type) {
  'missing_punch' => l.requestMissingPunch,
  'punch_contest' => l.requestPunchContest,
  'absence' => l.requestAbsence,
  _ => type,
};

String absenceTypeLabel(AppLocalizations l, String type) => switch (type) {
  'medical_certificate' => l.absenceMedicalCertificate,
  'justified' => l.absenceJustified,
  'day_off' => l.absenceDayOff,
  'leave' => l.absenceLeave,
  _ => type,
};

String requestStatusLabel(AppLocalizations l, String status) =>
    switch (status) {
      'pending' => l.requestPending,
      'approved' => l.requestApproved,
      'rejected' => l.requestRejected,
      'cancelled' => l.requestCancelled,
      _ => status,
    };

/// Translated reason of a refused request; the server text is English and never shown as is.
String requestFailureText(AppLocalizations l, PulseFailure failure) {
  if (failure.code == 'networkError') return l.networkError;
  final message = failure.message ?? '';
  if (failure.fields.contains('file')) return l.requestFileInvalid;
  if (message.contains('pending request')) return l.requestDuplicate;
  if (message.contains('open timesheet period')) return l.requestPeriodClosed;
  if (message.contains('overlaps')) return l.requestOverlap;
  if (message.contains('already disregarded')) return l.requestAlreadyTreated;
  if (message.contains('outside the day') || message.contains('future')) {
    return l.requestFutureTime;
  }
  if (message.contains('already decided')) return l.requestAlreadyDecided;
  return l.requestError;
}

String _two(int value) => value.toString().padLeft(2, '0');
String _day(DateTime date) =>
    '${date.year}-${_two(date.month)}-${_two(date.day)}';

String _showDay(BuildContext context, String? value) {
  final date = DateTime.tryParse(value ?? '');
  if (date == null) return '—';
  return MaterialLocalizations.of(context).formatCompactDate(date);
}

String _showInstant(BuildContext context, Object? value) {
  final at = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (at == null) return '—';
  final material = MaterialLocalizations.of(context);
  return '${material.formatShortMonthDay(at)} ${_two(at.hour)}:${_two(at.minute)}';
}

/// Requests of the employee: forgotten marks, punch contests and absences with a certificate.
/// HR or the department responsible decides; the employee sees the outcome and the note.
class RequestsView extends StatefulWidget {
  const RequestsView({
    super.key,
    required this.api,
    required this.clock,
    required this.onSessionEnded,
  });

  final PulseApi api;
  final ServerClock clock;
  final void Function(String code) onSessionEnded;

  @override
  State<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends State<RequestsView> {
  List<Map<String, dynamic>>? _items;
  String? _error;
  bool _loading = false;
  bool _visible = false;
  int _request = 0;

  AppLocalizations get l => AppLocalizations.of(context)!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible && !_visible) {
      Future.microtask(() {
        if (mounted) unawaited(_load());
      });
    }
    _visible = visible;
  }

  bool _ended(PulseFailure failure) {
    if (!failure.sessionEnded) return false;
    widget.onSessionEnded(failure.code);
    return true;
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await widget.api.listRequests();
      if (!mounted || request != _request) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } on PulseFailure catch (failure) {
      if (_ended(failure) || !mounted || request != _request) return;
      setState(() {
        _error = failure.code;
        _loading = false;
      });
    }
  }

  Future<void> _new() async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => RequestForm(
        api: widget.api,
        clock: widget.clock,
        onSessionEnded: widget.onSessionEnded,
      ),
    );
    if (sent == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.requestSent)));
      unawaited(_load());
    }
  }

  Future<void> _cancel(Map<String, dynamic> item) async {
    final uuid = item['RequestUUID']?.toString();
    if (uuid == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.requestCancelTitle),
        content: Text(l.requestCancelText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.back),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.requestCancelAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.api.cancelRequest(uuid);
    } on PulseFailure catch (failure) {
      if (_ended(failure) || !mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(requestFailureText(l, failure))));
    }
    if (mounted) unawaited(_load());
  }

  String _detail(Map<String, dynamic> item) {
    final type = item['Type']?.toString() ?? '';
    if (type == 'missing_punch') {
      return '${punchLabel(l, item['PunchType']?.toString() ?? '')} · ${_showInstant(context, item['OccurredAt'])}';
    }
    if (type == 'punch_contest') {
      return '${punchLabel(l, item['ContestedPunchType']?.toString() ?? '')} · ${_showInstant(context, item['ContestedOccurredAt'])}';
    }
    final start = _showDay(context, item['Date']?.toString());
    final end = item['EndDate']?.toString();
    final range = end != null && end != item['Date']?.toString()
        ? '$start – ${_showDay(context, end)}'
        : start;
    return '${absenceTypeLabel(l, item['AbsenceType']?.toString() ?? '')} · $range';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = _items;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.navRequests,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              FilledButton.icon(
                key: const Key('newRequest'),
                onPressed: _new,
                icon: const Icon(Icons.add),
                label: Text(l.requestNew),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading && items == null) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(
                    _error == 'networkError' ? l.networkError : l.requestError,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.error),
                  ),
                  TextButton(onPressed: _load, child: Text(l.retry)),
                ],
              ),
            ),
          if (items != null && items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(l.requestEmpty, textAlign: TextAlign.center),
            ),
          for (final item in items ?? const <Map<String, dynamic>>[])
            Card(
              key: ValueKey('request-${item['RequestUUID']}'),
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            requestTypeLabel(l, item['Type']?.toString() ?? ''),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        _StatusChip(status: item['Status']?.toString() ?? ''),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(_detail(item)),
                    if ((item['Reason']?.toString() ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          item['Reason'].toString(),
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    if ((item['AttachmentFileName']?.toString() ?? '')
                        .isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.attach_file, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item['AttachmentFileName'].toString(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if ((item['DecisionNote']?.toString() ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          l.requestAnswer(item['DecisionNote'].toString()),
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    if (item['Status'] == 'pending')
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _cancel(item),
                          child: Text(l.requestCancelAction),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      'approved' => (scheme.primaryContainer, scheme.onPrimaryContainer),
      'rejected' => (scheme.errorContainer, scheme.onErrorContainer),
      'pending' => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      _ => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        requestStatusLabel(l, status),
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// New request. The request and attachment UUIDs are generated once per form, so a retry after a
/// network failure records each of them exactly once.
class RequestForm extends StatefulWidget {
  const RequestForm({
    super.key,
    required this.api,
    required this.clock,
    required this.onSessionEnded,
    this.pickFile,
  });

  final PulseApi api;
  final ServerClock clock;
  final void Function(String code) onSessionEnded;

  /// Test seam: returns (bytes, name) of a certificate; defaults to the platform file picker.
  final Future<(List<int>, String)?> Function()? pickFile;

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  final _requestUUID = uuidV4();
  final _attachmentUUID = uuidV4();
  final _reason = TextEditingController();
  String _type = 'missing_punch';
  late DateTime _date = _today;
  late DateTime _endDate = _today;
  TimeOfDay? _time;
  String _punchType = 'clock_out';
  String _absenceType = 'medical_certificate';
  String? _punchUUID;
  List<Map<String, dynamic>>? _punches;
  (List<int>, String)? _file;
  String? _uploaded;
  String? _error;
  bool _sending = false;

  AppLocalizations get l => AppLocalizations.of(context)!;

  DateTime get _today {
    final now = widget.clock.nowUtc().toLocal();
    return DateTime(now.year, now.month, now.day);
  }

  /// The open timesheet period: from the first day of the previous month.
  DateTime get _firstDay => DateTime(_today.year, _today.month - 1);

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _loadPunches() async {
    try {
      final items = await widget.api.listPunches(limit: 40);
      if (mounted) setState(() => _punches = items);
    } on PulseFailure catch (failure) {
      if (failure.sessionEnded) widget.onSessionEnded(failure.code);
      if (mounted) setState(() => _punches = const []);
    }
  }

  Future<DateTime?> _pickDate(DateTime initial, {DateTime? last}) =>
      showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: _firstDay,
        lastDate: last ?? _today.add(const Duration(days: 366)),
      );

  Future<void> _pickCertificate() async {
    final picker = widget.pickFile;
    final picked = picker != null
        ? await picker()
        : await () async {
            final files = await FilePicker.pickFiles(
              type: FileType.custom,
              allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg', 'webp'],
            );
            final file = files.singleOrNull;
            if (file == null) return null;
            if ((await file.length() ?? 0) > 10 * 1024 * 1024) {
              return (const <int>[], file.name);
            }
            return ((await file.readAsBytes()).toList(), file.name);
          }();
    if (picked == null || !mounted) return;
    if (picked.$1.isEmpty || picked.$1.length > 10 * 1024 * 1024) {
      setState(() => _error = l.requestFileInvalid);
      return;
    }
    setState(() {
      _file = picked;
      _uploaded = null;
      _error = null;
    });
  }

  String? _validate() {
    if (_reason.text.trim().isEmpty) return l.requestReasonRequired;
    if (_type == 'missing_punch' && _time == null) return l.requestTimeRequired;
    if (_type == 'punch_contest' && _punchUUID == null) {
      return l.requestPunchRequired;
    }
    if (_type == 'absence' && _endDate.isBefore(_date)) {
      return l.requestEndBeforeStart;
    }
    return null;
  }

  Future<void> _send() async {
    final invalid = _validate();
    if (invalid != null) {
      setState(() => _error = invalid);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final file = _file;
      if (_type == 'absence' && file != null && _uploaded == null) {
        _uploaded = await widget.api.uploadAttachment(
          _attachmentUUID,
          file.$1,
          file.$2,
        );
      }
      await widget.api.createRequest({
        'uuid': _requestUUID,
        'type': _type,
        'reason': _reason.text.trim(),
        if (_type == 'missing_punch') ...{
          'date': _day(_date),
          'time': '${_two(_time!.hour)}:${_two(_time!.minute)}',
          'punchType': _punchType,
        },
        if (_type == 'punch_contest') 'punchUUID': _punchUUID,
        if (_type == 'absence') ...{
          'date': _day(_date),
          'endDate': _day(_endDate),
          'absenceType': _absenceType,
          'attachmentUUID': ?_uploaded,
        },
      });
      if (mounted) Navigator.pop(context, true);
    } on PulseFailure catch (failure) {
      if (failure.sessionEnded) {
        widget.onSessionEnded(failure.code);
        if (mounted) Navigator.pop(context, false);
        return;
      }
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = failure.status == 500 && _uploaded == null && _file != null
            ? l.requestAttachmentUnavailable
            : requestFailureText(l, failure);
      });
    }
  }

  Widget _dateTile(
    String label,
    DateTime value,
    ValueChanged<DateTime> onPicked, {
    DateTime? last,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event),
      title: Text(label),
      subtitle: Text(MaterialLocalizations.of(context).formatMediumDate(value)),
      onTap: _sending
          ? null
          : () async {
              final picked = await _pickDate(value, last: last);
              if (picked != null) setState(() => onPicked(picked));
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.requestNew, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: [
                for (final type in requestTypes)
                  ButtonSegment(
                    value: type,
                    label: Text(requestTypeLabel(l, type)),
                  ),
              ],
              selected: {_type},
              onSelectionChanged: _sending
                  ? null
                  : (selection) {
                      setState(() {
                        _type = selection.first;
                        _error = null;
                      });
                      if (_type == 'punch_contest' && _punches == null) {
                        unawaited(_loadPunches());
                      }
                    },
            ),
            const SizedBox(height: 12),
            if (_type == 'missing_punch') ...[
              _dateTile(l.requestDate, _date, (d) => _date = d, last: _today),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: Text(l.requestTime),
                subtitle: Text(_time == null ? '—' : _time!.format(context)),
                onTap: _sending
                    ? null
                    : () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _time ?? TimeOfDay.now(),
                        );
                        if (picked != null) setState(() => _time = picked);
                      },
              ),
              DropdownButtonFormField<String>(
                initialValue: _punchType,
                decoration: InputDecoration(labelText: l.requestMark),
                items: [
                  for (final type in punchTypes)
                    DropdownMenuItem(
                      value: type,
                      child: Text(punchLabel(l, type)),
                    ),
                ],
                onChanged: _sending
                    ? null
                    : (value) => setState(() => _punchType = value!),
              ),
            ],
            if (_type == 'punch_contest') ...[
              Text(l.requestChoosePunch),
              if (_punches == null) const LinearProgressIndicator(),
              if (_punches != null && _punches!.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(l.requestNoPunches),
                ),
              RadioGroup<String>(
                groupValue: _punchUUID,
                onChanged: (value) {
                  if (!_sending) setState(() => _punchUUID = value);
                },
                child: Column(
                  children: [
                    for (final punch
                        in _punches ?? const <Map<String, dynamic>>[])
                      RadioListTile<String>(
                        value: punch['TimePunchUUID']?.toString() ?? '',
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          punchLabel(l, punch['Type']?.toString() ?? ''),
                        ),
                        subtitle: Text(
                          _showInstant(context, punch['OccurredAt']),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (_type == 'absence') ...[
              DropdownButtonFormField<String>(
                initialValue: _absenceType,
                decoration: InputDecoration(labelText: l.requestAbsenceType),
                items: [
                  for (final type in absenceTypes)
                    DropdownMenuItem(
                      value: type,
                      child: Text(absenceTypeLabel(l, type)),
                    ),
                ],
                onChanged: _sending
                    ? null
                    : (value) => setState(() => _absenceType = value!),
              ),
              _dateTile(l.requestStartDate, _date, (d) {
                _date = d;
                if (_endDate.isBefore(d)) _endDate = d;
              }),
              _dateTile(l.requestEndDate, _endDate, (d) => _endDate = d),
              OutlinedButton.icon(
                key: const Key('pickCertificate'),
                onPressed: _sending ? null : _pickCertificate,
                icon: const Icon(Icons.attach_file),
                label: Text(_file?.$2 ?? l.requestAttachCertificate),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l.requestCertificateHint,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              key: const Key('requestReason'),
              controller: _reason,
              enabled: !_sending,
              maxLength: 1000,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(labelText: l.requestReason),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!, style: TextStyle(color: scheme.error)),
              ),
            FilledButton(
              key: const Key('sendRequest'),
              onPressed: _sending ? null : _send,
              child: _sending
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l.requestSend),
            ),
          ],
        ),
      ),
    );
  }
}
