import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../core/file_opener.dart';
import '../core/ids.dart';
import '../core/pulse_api.dart';
import '../requests/requests_view.dart' show requestFailureText;

typedef PickedFile = (List<int>, String);
typedef FileOpener = Future<bool> Function(List<int>, String, String);
typedef RangePicker = Future<DateTimeRange?> Function(BuildContext, DateTime);

const _maxFileBytes = 10 * 1024 * 1024;

String _two(int value) => value.toString().padLeft(2, '0');
String _day(DateTime date) =>
    '${date.year}-${_two(date.month)}-${_two(date.day)}';

String _showDay(BuildContext context, Object? value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return '—';
  return MaterialLocalizations.of(context).formatCompactDate(date.toLocal());
}

String _showMonth(BuildContext context, Object? competence) {
  final raw = competence?.toString() ?? '';
  final date = DateTime.tryParse('$raw-01');
  if (date == null) return raw;
  return MaterialLocalizations.of(context).formatMonthYear(date);
}

String documentKindLabel(AppLocalizations l, String kind) => switch (kind) {
  'warning' => l.docKindWarning,
  'payslip' => l.docKindPayslip,
  'employee' => l.docKindEmployee,
  _ => l.docKindDocument,
};

IconData _kindIcon(String kind) => switch (kind) {
  'warning' => Icons.gavel_outlined,
  'payslip' => Icons.receipt_long_outlined,
  'employee' => Icons.upload_file_outlined,
  _ => Icons.description_outlined,
};

/// Documents, payslips, company notices and the vacation balance of the employee. HR publishes
/// documents and asks for acknowledgement (the file must be opened first); the employee also sends
/// documents to HR and requests vacation within the balance.
class DocumentsView extends StatefulWidget {
  const DocumentsView({
    super.key,
    required this.api,
    required this.onSessionEnded,
    this.pickFile,
    this.openFile,
    this.pickRange,
  });

  final PulseApi api;
  final void Function(String code) onSessionEnded;

  /// Test seams: file picker, file viewer and date range picker.
  final Future<PickedFile?> Function()? pickFile;
  final FileOpener? openFile;
  final RangePicker? pickRange;

  @override
  State<DocumentsView> createState() => _DocumentsViewState();
}

class _DocumentsViewState extends State<DocumentsView> {
  List<Map<String, dynamic>>? _documents;
  List<Map<String, dynamic>>? _notices;
  Map<String, dynamic>? _vacation;
  String? _error;
  bool _loading = false;
  bool _busy = false;
  bool _visible = false;

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
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait<Object>([
        widget.api.listDocuments(),
        widget.api.listNotices(),
        widget.api.vacation(),
      ]);
      if (!mounted) return;
      setState(() {
        _documents = results[0] as List<Map<String, dynamic>>;
        _notices = results[1] as List<Map<String, dynamic>>;
        _vacation = results[2] as Map<String, dynamic>;
      });
    } on PulseFailure catch (failure) {
      if (!mounted || _ended(failure)) return;
      setState(
        () => _error = failure.code == 'networkError'
            ? l.networkError
            : l.docError,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _say(String text) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(text)));
  }

  String _failureText(PulseFailure failure) {
    if (failure.code == 'networkError') return l.networkError;
    if (failure.status == 503) return l.docStorageUnavailable;
    final message = failure.message ?? '';
    if (message.contains('Open the document')) return l.docOpenFirst;
    if (failure.fields.contains('file')) return l.docFileInvalid;
    return l.docError;
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } on PulseFailure catch (failure) {
      if (mounted && !_ended(failure)) _say(_failureText(failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open(Map<String, dynamic> item) => _run(() async {
    final uuid = item['DocumentUUID'].toString();
    final (bytes, contentType) = await widget.api.downloadDocument(uuid);
    final opener = widget.openFile ?? openPrivateFile;
    final name = item['FileName']?.toString() ?? 'documento';
    if (!await opener(bytes, contentType, name)) _say(l.docOpenFailed);
    final documents = await widget.api.listDocuments();
    if (mounted) setState(() => _documents = documents);
  });

  Future<bool> _confirmAck(String title, String? text) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        key: const Key('ackDialog'),
        title: Text(l.docAckTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(dialog).textTheme.titleMedium),
              if (text != null && text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(text),
              ],
              const SizedBox(height: 16),
              Text(l.docAckStatement),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            key: const Key('confirmAck'),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l.docAcknowledge),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _acknowledge(Map<String, dynamic> item) async {
    if (item['HasFile'] == true && item['ViewedAt'] == null) {
      _say(l.docOpenFirst);
      return;
    }
    final title = item['Title']?.toString() ?? '';
    if (!await _confirmAck(title, item['Description']?.toString())) return;
    await _run(() async {
      await widget.api.acknowledgeDocument(item['DocumentUUID'].toString());
      final documents = await widget.api.listDocuments();
      if (!mounted) return;
      setState(() => _documents = documents);
      _say(l.docAckDone);
    });
  }

  Future<void> _openNotice(Map<String, dynamic> notice, bool expanded) async {
    if (!expanded || notice['ReadAt'] != null) return;
    try {
      final read = await widget.api.markNotice(notice['NoticeUUID'].toString());
      if (!mounted) return;
      setState(
        () => notice['ReadAt'] =
            read['ReadAt'] ?? DateTime.now().toIso8601String(),
      );
    } on PulseFailure catch (failure) {
      if (mounted) _ended(failure);
    }
  }

  Future<void> _acknowledgeNotice(Map<String, dynamic> notice) async {
    final title = notice['Title']?.toString() ?? '';
    if (!await _confirmAck(title, notice['Body']?.toString())) return;
    await _run(() async {
      final read = await widget.api.markNotice(
        notice['NoticeUUID'].toString(),
        acknowledge: true,
      );
      if (!mounted) return;
      setState(() {
        notice['ReadAt'] ??= read['ReadAt'];
        notice['AcknowledgedAt'] = read['AcknowledgedAt'];
      });
      _say(l.docAckDone);
    });
  }

  Future<PickedFile?> _pick() async {
    final picker = widget.pickFile;
    if (picker != null) return picker();
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg', 'webp'],
    );
    final file = files.singleOrNull;
    if (file == null) return null;
    if ((await file.length() ?? 0) > _maxFileBytes) {
      return (const <int>[], file.name);
    }
    return ((await file.readAsBytes()).toList(), file.name);
  }

  Future<void> _send() async {
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => _SendDocumentDialog(api: widget.api, pick: _pick),
    );
    if (sent != true || !mounted) return;
    _say(l.docSent);
    try {
      final documents = await widget.api.listDocuments();
      if (mounted) setState(() => _documents = documents);
    } on PulseFailure catch (failure) {
      if (mounted) _ended(failure);
    }
  }

  Future<void> _requestVacation() async {
    final balance = _vacation ?? const {};
    final requestable = (balance['requestableDays'] as num?)?.toInt() ?? 0;
    final today = DateTime.now();
    final range =
        await (widget.pickRange ??
            (context, from) => showDateRangePicker(
              context: context,
              firstDate: from,
              lastDate: from.add(const Duration(days: 730)),
            ))(context, DateTime(today.year, today.month, today.day));
    if (range == null || !mounted) return;
    final days = range.end.difference(range.start).inDays + 1;
    if (days > requestable) {
      _say(l.vacationExceeds);
      return;
    }
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) =>
          _VacationDialog(api: widget.api, range: range, days: days),
    );
    if (sent != true || !mounted) return;
    _say(l.vacationSent);
    try {
      final vacation = await widget.api.vacation();
      if (mounted) setState(() => _vacation = vacation);
    } on PulseFailure catch (failure) {
      if (mounted) _ended(failure);
    }
  }

  Widget _state(Map<String, dynamic> item) {
    final scheme = Theme.of(context).colorScheme;
    final state = item['State']?.toString() ?? '';
    final (text, color) = switch (state) {
      'pending' => (l.docStatePending, scheme.error),
      'acknowledged' => (
        l.docStateAcknowledged(_showDay(context, item['AcknowledgedAt'])),
        scheme.primary,
      ),
      'viewed' => (l.docStateViewed, scheme.onSurfaceVariant),
      'received' => (l.docStateReceived, scheme.onSurfaceVariant),
      'reviewed' => (l.docStateReviewed, scheme.primary),
      _ => (l.docStateSent, scheme.primary),
    };
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium
          ?.copyWith(color: color, fontWeight: FontWeight.w600),
    );
  }

  Widget _documentCard(Map<String, dynamic> item) {
    final uuid = item['DocumentUUID'].toString();
    final kind = item['Kind']?.toString() ?? 'document';
    final payslip = kind == 'payslip';
    final description = item['Description']?.toString();
    final canAck =
        item['RequiresAck'] == true &&
        item['AcknowledgedAt'] == null &&
        kind != 'employee';
    return Card(
      key: Key('doc-$uuid'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_kindIcon(kind)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['Title']?.toString() ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        payslip
                            ? l.docCompetence(
                                _showMonth(context, item['Competence']),
                              )
                            : '${documentKindLabel(l, kind)} · ${_showDay(context, item['DateCreated'])}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      _state(item),
                    ],
                  ),
                ),
              ],
            ),
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(description),
            ],
            if (item['HasFile'] == true || canAck) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (item['HasFile'] == true)
                    OutlinedButton.icon(
                      key: Key('doc-open-$uuid'),
                      onPressed: _busy ? null : () => _open(item),
                      icon: const Icon(Icons.open_in_new),
                      label: Text(l.docOpen),
                    ),
                  if (canAck)
                    FilledButton.icon(
                      key: Key('doc-ack-$uuid'),
                      onPressed: _busy ? null : () => _acknowledge(item),
                      icon: const Icon(Icons.task_alt),
                      label: Text(l.docAcknowledge),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _list(List<Widget> children, String empty, {Widget? header}) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ?header,
          if (children.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(empty, textAlign: TextAlign.center),
            ),
          ...children,
        ],
      ),
    );
  }

  Widget _documentsTab() {
    final items = (_documents ?? const [])
        .where((d) => d['Kind'] != 'payslip')
        .map(_documentCard)
        .toList();
    return _list(
      items,
      l.docsEmpty,
      header: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: OutlinedButton.icon(
          key: const Key('sendDocumentOpen'),
          onPressed: _busy ? null : _send,
          icon: const Icon(Icons.upload_file),
          label: Text(l.docSend),
        ),
      ),
    );
  }

  Widget _payslipsTab() => _list(
    (_documents ?? const [])
        .where((d) => d['Kind'] == 'payslip')
        .map(_documentCard)
        .toList(),
    l.payslipsEmpty,
  );

  Widget _noticesTab() {
    final scheme = Theme.of(context).colorScheme;
    return _list([
      for (final notice in _notices ?? const <Map<String, dynamic>>[])
        Card(
          key: Key('notice-${notice['NoticeUUID']}'),
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            onExpansionChanged: (open) => _openNotice(notice, open),
            leading: Icon(
              notice['ReadAt'] == null
                  ? Icons.mark_email_unread_outlined
                  : Icons.drafts_outlined,
              color: notice['ReadAt'] == null ? scheme.primary : null,
            ),
            title: Text(notice['Title']?.toString() ?? ''),
            subtitle: Text(
              '${_showDay(context, notice['PublishAt'])} · '
              '${notice['ReadAt'] == null ? l.noticeNew : l.noticeRead}',
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notice['Body']?.toString() ?? ''),
              if (notice['RequiresAck'] == true) ...[
                const SizedBox(height: 12),
                if (notice['AcknowledgedAt'] != null)
                  Text(
                    l.docStateAcknowledged(
                      _showDay(context, notice['AcknowledgedAt']),
                    ),
                    style: TextStyle(color: scheme.primary),
                  )
                else ...[
                  Text(l.noticeAckRequired),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    key: Key('notice-ack-${notice['NoticeUUID']}'),
                    onPressed: _busy ? null : () => _acknowledgeNotice(notice),
                    icon: const Icon(Icons.task_alt),
                    label: Text(l.docAcknowledge),
                  ),
                ],
              ],
            ],
          ),
        ),
    ], l.noticesEmpty);
  }

  String _periodStatus(String status) => switch (status) {
    'available' => l.vacationAvailableStatus,
    'used' => l.vacationUsedStatus,
    'overdue' => l.vacationOverdueStatus,
    _ => l.vacationAccruingStatus,
  };

  Widget _vacationTab() {
    final v = _vacation ?? const <String, dynamic>{};
    final theme = Theme.of(context);
    final periods = (v['periods'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList()
        .reversed
        .toList();
    final hired = v['hireDate'] != null;
    final requestable = (v['requestableDays'] as num?)?.toInt() ?? 0;
    final deadline = periods.reversed
        .where((p) => ((p['remainingDays'] as num?) ?? 0) > 0)
        .map((p) => p['deadline'])
        .firstOrNull;
    Widget figure(String label, Object? value, Key key) => Expanded(
      child: Column(
        children: [
          Text(
            '${value ?? 0}',
            key: key,
            style: theme.textTheme.headlineMedium,
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
    return _list([
      if (!hired)
        Text(l.vacationNoHireDate, key: const Key('vacationNoHireDate'))
      else ...[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    figure(
                      l.vacationAvailable,
                      v['availableDays'],
                      const Key('vacationAvailable'),
                    ),
                    figure(
                      l.vacationPendingDays,
                      v['pendingDays'],
                      const Key('vacationPending'),
                    ),
                    figure(
                      l.vacationAccruing,
                      v['accruingDays'],
                      const Key('vacationAccruing'),
                    ),
                  ],
                ),
                if (deadline != null) ...[
                  const SizedBox(height: 12),
                  Text(l.vacationDeadline(_showDay(context, deadline))),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  key: const Key('vacationRequest'),
                  onPressed: _busy || requestable <= 0
                      ? null
                      : _requestVacation,
                  icon: const Icon(Icons.beach_access),
                  label: Text(l.vacationRequest),
                ),
                if (requestable <= 0) ...[
                  const SizedBox(height: 8),
                  Text(l.vacationNothing, textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(l.vacationPeriods, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final p in periods)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              l.vacationPeriodRange(
                _showDay(context, p['start']),
                _showDay(context, p['end']),
              ),
            ),
            subtitle: Text(
              l.vacationPeriodUsage(
                (p['takenDays'] as num?)?.toInt() ?? 0,
                (p['entitledDays'] as num?)?.toInt() ?? 0,
              ),
            ),
            trailing: Text(_periodStatus(p['status']?.toString() ?? '')),
          ),
      ],
    ], '');
  }

  @override
  Widget build(BuildContext context) {
    final body = _documents == null
        ? Center(
            child: _error == null
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _loading ? null : _load,
                        child: Text(l.retry),
                      ),
                    ],
                  ),
          )
        : TabBarView(
            children: [
              _documentsTab(),
              _payslipsTab(),
              _noticesTab(),
              _vacationTab(),
            ],
          );
    final pending = (_documents ?? const [])
        .where((d) => d['State'] == 'pending')
        .length;
    final unread = (_notices ?? const [])
        .where((n) => n['ReadAt'] == null)
        .length;
    Widget tab(String label, int count, Key key) => Tab(
      key: key,
      child: count > 0
          ? Badge(label: Text('$count'), child: Text(label))
          : Text(label),
    );
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            tabs: [
              tab(
                l.docsTabDocuments,
                (_documents ?? const [])
                    .where(
                      (d) => d['State'] == 'pending' && d['Kind'] != 'payslip',
                    )
                    .length,
                const Key('tabDocuments'),
              ),
              tab(
                l.docsTabPayslips,
                pending -
                    (_documents ?? const [])
                        .where(
                          (d) =>
                              d['State'] == 'pending' && d['Kind'] != 'payslip',
                        )
                        .length,
                const Key('tabPayslips'),
              ),
              tab(l.docsTabNotices, unread, const Key('tabNotices')),
              tab(l.docsTabVacation, 0, const Key('tabVacation')),
            ],
          ),
          if (_loading && _documents != null) const LinearProgressIndicator(),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _SendDocumentDialog extends StatefulWidget {
  const _SendDocumentDialog({required this.api, required this.pick});

  final PulseApi api;
  final Future<PickedFile?> Function() pick;

  @override
  State<_SendDocumentDialog> createState() => _SendDocumentDialogState();
}

class _SendDocumentDialogState extends State<_SendDocumentDialog> {
  final _title = TextEditingController();
  final _note = TextEditingController();
  final _uuid = uuidV4();
  PickedFile? _file;
  String? _error;
  bool _sending = false;

  AppLocalizations get l => AppLocalizations.of(context)!;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final picked = await widget.pick();
    if (picked == null || !mounted) return;
    if (picked.$1.isEmpty || picked.$1.length > _maxFileBytes) {
      setState(() => _error = l.docFileInvalid);
      return;
    }
    setState(() {
      _file = picked;
      _error = null;
    });
  }

  Future<void> _send() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = l.required);
      return;
    }
    if (_file == null) {
      setState(() => _error = l.docFileInvalid);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.api.sendDocument(
        _uuid,
        title,
        _note.text.trim(),
        _file!.$1,
        _file!.$2,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on PulseFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = failure.code == 'networkError'
            ? l.networkError
            : failure.status == 503
            ? l.docStorageUnavailable
            : failure.fields.contains('file')
            ? l.docFileInvalid
            : l.docError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('sendDocumentDialog'),
      title: Text(l.docSend),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('sendTitle'),
              controller: _title,
              maxLength: 200,
              decoration: InputDecoration(
                labelText: l.docSendTitle,
                hintText: l.docSendTitleHint,
              ),
            ),
            TextField(
              key: const Key('sendNote'),
              controller: _note,
              maxLength: 1000,
              maxLines: 3,
              decoration: InputDecoration(labelText: l.docSendNote),
            ),
            OutlinedButton.icon(
              key: const Key('sendPick'),
              onPressed: _sending ? null : _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(_file?.$2 ?? l.docPickFile),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.of(context).pop(false),
          child: Text(l.cancel),
        ),
        FilledButton(
          key: const Key('sendDocument'),
          onPressed: _sending ? null : _send,
          child: _sending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l.requestSend),
        ),
      ],
    );
  }
}

class _VacationDialog extends StatefulWidget {
  const _VacationDialog({
    required this.api,
    required this.range,
    required this.days,
  });

  final PulseApi api;
  final DateTimeRange range;
  final int days;

  @override
  State<_VacationDialog> createState() => _VacationDialogState();
}

class _VacationDialogState extends State<_VacationDialog> {
  final _reason = TextEditingController();
  final _uuid = uuidV4();
  String? _error;
  bool _sending = false;

  AppLocalizations get l => AppLocalizations.of(context)!;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final note = _reason.text.trim();
      await widget.api.createRequest({
        'uuid': _uuid,
        'type': 'absence',
        'absenceType': 'vacation',
        'date': _day(widget.range.start),
        'endDate': _day(widget.range.end),
        'reason': note.isEmpty ? l.absenceVacation : note,
      });
      if (mounted) Navigator.of(context).pop(true);
    } on PulseFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = (failure.message ?? '').contains('available balance')
            ? l.vacationExceeds
            : requestFailureText(l, failure);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    return AlertDialog(
      key: const Key('vacationDialog'),
      title: Text(l.vacationRequest),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.vacationPeriodRange(
                material.formatCompactDate(widget.range.start),
                material.formatCompactDate(widget.range.end),
              ),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(l.vacationDays(widget.days)),
            const SizedBox(height: 12),
            TextField(
              key: const Key('vacationReason'),
              controller: _reason,
              maxLength: 1000,
              maxLines: 3,
              decoration: InputDecoration(labelText: l.vacationReason),
            ),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.of(context).pop(false),
          child: Text(l.cancel),
        ),
        FilledButton(
          key: const Key('vacationSend'),
          onPressed: _sending ? null : _send,
          child: Text(l.requestSend),
        ),
      ],
    );
  }
}
