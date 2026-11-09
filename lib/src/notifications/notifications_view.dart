import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../core/pulse_api.dart';
import '../pwa/pwa.dart';
import '../requests/requests_view.dart' show requestTypeLabel;

/// Language of push texts: the app language, as the API knows it.
String pushLocale(Locale locale) => switch (locale.languageCode) {
  'en' => 'en-US',
  'es' => 'es-ES',
  _ => 'pt-BR',
};

/// Bell of the app bar: unread count of the inbox, refreshed every minute and on [refresh].
class NotificationsButton extends StatefulWidget {
  const NotificationsButton({
    super.key,
    required this.api,
    required this.onOpenRequest,
    required this.onSessionEnded,
    this.refresh,
  });

  final PulseApi api;
  final void Function(String? requestUUID) onOpenRequest;
  final void Function(String code) onSessionEnded;
  final Listenable? refresh;

  @override
  State<NotificationsButton> createState() => _NotificationsButtonState();
}

class _NotificationsButtonState extends State<NotificationsButton> {
  int _unread = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    unawaited(_count());
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _count());
    widget.refresh?.addListener(_count);
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.refresh?.removeListener(_count);
    super.dispose();
  }

  Future<void> _count() async {
    try {
      final page = await widget.api.notifications(limit: 1);
      if (mounted) {
        setState(() => _unread = (page['unread'] as num?)?.toInt() ?? 0);
      }
    } on PulseFailure catch (failure) {
      if (failure.sessionEnded) widget.onSessionEnded(failure.code);
    } catch (_) {
      // Offline: the badge keeps its last value.
    }
  }

  Future<void> _open() async {
    final request = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => NotificationsSheet(
        api: widget.api,
        onSessionEnded: widget.onSessionEnded,
      ),
    );
    unawaited(_count());
    if (request != null) widget.onOpenRequest(request.isEmpty ? null : request);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return IconButton(
      key: const Key('notifications'),
      tooltip: l.notificationsTitle,
      onPressed: _open,
      icon: Badge(
        isLabelVisible: _unread > 0,
        label: Text(_unread > 99 ? '99+' : '$_unread'),
        child: Icon(
          _unread > 0 ? Icons.notifications : Icons.notifications_outlined,
        ),
      ),
    );
  }
}

/// Inbox plus the device settings: Web Push on this browser and mark reminders. Pops the request
/// to open ('' for the requests tab), or null.
class NotificationsSheet extends StatefulWidget {
  const NotificationsSheet({
    super.key,
    required this.api,
    required this.onSessionEnded,
  });

  final PulseApi api;
  final void Function(String code) onSessionEnded;

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  List<Map<String, dynamic>>? _items;
  Map<String, dynamic>? _preferences;
  String _permission = pwaPushPermission();
  bool _pushed = false;
  bool _busy = false;
  String? _error;

  AppLocalizations get l => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  bool _ended(PulseFailure failure) {
    if (!failure.sessionEnded) return false;
    Navigator.of(context).pop();
    widget.onSessionEnded(failure.code);
    return true;
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        widget.api.notifications(),
        widget.api.preferences(),
        pwaCurrentPush(),
      ]);
      if (!mounted) return;
      final page = results[0] as Map<String, dynamic>;
      setState(() {
        _items = ((page['items'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
        _preferences = results[1] as Map<String, dynamic>;
        _pushed = results[2] != null;
        _permission = pwaPushPermission();
        _error = null;
      });
    } on PulseFailure catch (failure) {
      if (_ended(failure) || !mounted) return;
      setState(() => _error = failure.code);
    }
  }

  /// Subscribes this browser (asks permission on the first time) and registers it in the API.
  Future<bool> _enablePush() async {
    final key = await widget.api.pushKey();
    final raw = key.isEmpty ? null : await pwaSubscribePush(key);
    if (!mounted) return false;
    if (raw == null) {
      setState(() => _permission = pwaPushPermission());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _permission == 'denied' ? l.pushDenied : l.pushUnavailable,
          ),
        ),
      );
      return false;
    }
    await widget.api.subscribePush(
      jsonDecode(raw) as Map<String, dynamic>,
      pushLocale(Localizations.localeOf(context)),
    );
    return true;
  }

  Future<void> _togglePush(bool on) async {
    setState(() => _busy = true);
    try {
      if (on) {
        await _enablePush();
      } else {
        final endpoint = await pwaUnsubscribePush();
        if (endpoint != null) await widget.api.unsubscribePush(endpoint);
      }
    } on PulseFailure catch (failure) {
      if (_ended(failure)) return;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    await _load();
  }

  Future<void> _toggleReminders(bool on) async {
    setState(() => _busy = true);
    try {
      // Reminders arrive by push: turning them on also enables push on this browser.
      if (on && !_pushed && !await _enablePush()) return;
      final preferences = await widget.api.setReminders(on);
      if (mounted) setState(() => _preferences = preferences);
    } on PulseFailure catch (failure) {
      if (_ended(failure)) return;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    await _load();
  }

  Future<void> _open(Map<String, dynamic> item) async {
    final uuid = item['NotificationUUID']?.toString();
    try {
      if (uuid != null && item['Read'] != true) {
        await widget.api.readNotifications(uuid);
      }
    } on PulseFailure catch (failure) {
      if (_ended(failure)) return;
    }
    if (mounted) {
      Navigator.of(context).pop(item['RequestUUID']?.toString() ?? '');
    }
  }

  Future<void> _readAll() async {
    try {
      await widget.api.readNotifications();
    } on PulseFailure catch (failure) {
      if (_ended(failure)) return;
    }
    await _load();
  }

  String _title(Map<String, dynamic> item) {
    if (item['Type'] == 'request_message') return l.notificationMessage;
    return item['RequestStatus'] == 'approved'
        ? l.notificationApproved
        : l.notificationRejected;
  }

  String _subtitle(Map<String, dynamic> item) {
    final type = requestTypeLabel(l, item['RequestType']?.toString() ?? '');
    final date = DateTime.tryParse(item['RequestDate']?.toString() ?? '');
    if (date == null) return type;
    final day = MaterialLocalizations.of(context).formatShortDate(date);
    return '$type · $day';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = _items;
    final preferences = _preferences;
    final supported = _permission != 'unsupported';
    final remindersAvailable = preferences?['RemindersAvailable'] == true;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.notificationsTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if ((items ?? const []).any((item) => item['Read'] != true))
                  TextButton(
                    key: const Key('readAll'),
                    onPressed: _readAll,
                    child: Text(l.notificationsReadAll),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    key: const Key('pushSwitch'),
                    secondary: const Icon(Icons.phonelink_ring_outlined),
                    title: Text(l.pushTitle),
                    subtitle: Text(
                      !supported
                          ? l.pushUnsupported
                          : _permission == 'denied'
                          ? l.pushDenied
                          : l.pushText,
                    ),
                    value: _pushed,
                    onChanged: !supported || _busy || preferences == null
                        ? null
                        : _togglePush,
                  ),
                  SwitchListTile(
                    key: const Key('remindersSwitch'),
                    secondary: const Icon(Icons.alarm),
                    title: Text(l.remindersTitle),
                    subtitle: Text(
                      remindersAvailable ? l.remindersText : l.remindersOff,
                    ),
                    value: preferences?['MarkReminders'] == true,
                    onChanged: !supported || !remindersAvailable || _busy
                        ? null
                        : _toggleReminders,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (items == null && _error == null)
              const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      _error == 'networkError'
                          ? l.networkError
                          : l.notificationsError,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.error),
                    ),
                    TextButton(onPressed: _load, child: Text(l.retry)),
                  ],
                ),
              ),
            if (items != null && items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(l.notificationsEmpty, textAlign: TextAlign.center),
              ),
            for (final item in items ?? const <Map<String, dynamic>>[])
              ListTile(
                key: ValueKey('notification-${item['NotificationUUID']}'),
                leading: Icon(
                  item['Type'] == 'request_message'
                      ? Icons.chat_bubble_outline
                      : item['RequestStatus'] == 'approved'
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                ),
                title: Text(
                  _title(item),
                  style: TextStyle(
                    fontWeight: item['Read'] == true
                        ? FontWeight.normal
                        : FontWeight.w600,
                  ),
                ),
                subtitle: Text(_subtitle(item)),
                trailing: item['Read'] == true
                    ? null
                    : Icon(Icons.circle, size: 10, color: scheme.primary),
                onTap: () => _open(item),
              ),
          ],
        ),
      ),
    );
  }
}
