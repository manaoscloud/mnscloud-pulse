import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'src/brand/brand.dart';
import 'src/access/access_shell.dart';
import 'src/access/access_preferences.dart';
import 'src/core/pulse_api.dart';
import 'src/core/punch_queue.dart';
import 'src/core/server_clock.dart';
import 'src/offline/device_grant.dart';
import 'src/offline/device_lock.dart';
import 'src/offline/punch_sync.dart';
import 'src/offline/secret_vault.dart';
import 'src/pwa/pwa.dart';
import 'src/punch/punch_workspace.dart';
import 'src/pwa/install_app_button.dart';
import 'src/notifications/notifications_view.dart';
import 'src/requests/requests_view.dart';
import 'src/timesheet/timesheet_view.dart';
import 'l10n/app_localizations.dart';
import 'src/version/app_update_overlay.dart';

void main() {
  runApp(const PulseApp());
  loadPulseBrand();
  loadAccessLocale();
}

class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: accessLocale,
      builder: (context, locale, _) => ValueListenableBuilder<Brand?>(
        valueListenable: pulseBrand,
        builder: (context, brand, _) {
          final seed = brand?.primaryColor ?? const Color(0xff1264ed);
          ThemeData theme(Brightness brightness) {
            final scheme = ColorScheme.fromSeed(
              seedColor: seed,
              brightness: brightness,
            );
            return ThemeData(
              colorScheme: scheme,
              useMaterial3: true,
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
              ),
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  backgroundColor: seed,
                  foregroundColor: seed.computeLuminance() > .179
                      ? Colors.black
                      : Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            );
          }

          return MaterialApp(
            title: brand?.title ?? 'MNSCloud Pulse',
            debugShowCheckedModeBanner: false,
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: theme(Brightness.light),
            darkTheme: theme(Brightness.dark),
            themeMode: switch (brand?.login['appearance']) {
              'light' => ThemeMode.light,
              'dark' => ThemeMode.dark,
              _ => ThemeMode.system,
            },
            builder: (context, child) =>
                AppUpdateOverlay(child: child ?? const SizedBox.shrink()),
            home: const PulseShell(),
          );
        },
      ),
    );
  }
}

class PulseShell extends StatefulWidget {
  const PulseShell({super.key, this.client, this.restoreSession = true});
  final http.Client? client;

  /// Reopens the session kept by the refresh cookie when the page loads (web reload).
  final bool restoreSession;

  @override
  State<PulseShell> createState() => _PulseShellState();
}

/// Native refresh token in the platform secure storage (the web keeps it in the HttpOnly cookie).
class _VaultRefreshStore implements RefreshTokenStore {
  _VaultRefreshStore(this.vault);
  final SecretVault vault;
  static const _key = 'pulse.refresh';

  @override
  Future<String?> read() => vault.read(_key);

  @override
  Future<void> write(String? token) =>
      token == null ? vault.delete(_key) : vault.write(_key, token);
}

class _PulseShellState extends State<PulseShell> {
  final SecretVault _vault = SecretVault.instance;
  late final PulseApi _api =
      PulseApi(
          client: widget.client,
          refreshStore: kIsWeb ? null : _VaultRefreshStore(_vault),
        )
        ..onServerTime = _clock.accept
        ..onSession = _sessionOpened;
  final _clock = ServerClock();
  late final DeviceGrants _grants = DeviceGrants(
    api: _api,
    clock: _clock,
    vault: _vault,
  );
  late final PunchSync _sync = PunchSync(
    api: _api,
    grants: _grants,
    source: kIsWeb ? 'web' : 'mobile',
  );
  Timer? _syncTimer;
  AppLifecycleListener? _lifecycle;

  /// Opened without connection for the employee who did not sign out on this device: marks are
  /// kept encrypted and sent by the device grant (or the session, once it is back).
  bool _offlineEntry = false;
  static const _profileKey = 'pulse.offline.profile';

  final _loginCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _loginForm = GlobalKey<FormState>();
  final _passwordForm = GlobalKey<FormState>();
  final _codeFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _showPassword = false;
  bool _messageError = false;
  AppLocalizations get l => AppLocalizations.of(context)!;
  PulseAccount? _account;
  bool _restoring = false;
  bool _loading = false;
  String? _message;

  /// Signed-in tab: 0 home (punch), 1 timesheet, 2 requests. Tabs are built on their first visit.
  int _tab = 0;
  bool _timesheetOpened = false;
  bool _requestsOpened = false;

  /// Request whose conversation a notification asked to open.
  final _focusRequest = ValueNotifier<String?>(null);

  /// Requests tab, optionally opening one request (notification, push click, `?tab=requests`).
  void _openRequests([String? requestUUID]) {
    if (!mounted) return;
    setState(() {
      _tab = 2;
      _requestsOpened = true;
    });
    if (requestUUID != null) _focusRequest.value = requestUUID;
  }

  @override
  void initState() {
    super.initState();
    pulseBrand.addListener(_brandChanged);
    if (widget.restoreSession) _restore();
    _syncTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(_syncAll()),
    );
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(_syncAll()));
    // A push notification of a request opens the requests tab (link or click with the app open).
    if (Uri.base.queryParameters['tab'] == 'requests') {
      _tab = 2;
      _requestsOpened = true;
    }
    pwaOnNotificationClick((url) {
      if (url.contains('tab=requests')) _openRequests();
    });
    onBrowserOnline(() => unawaited(_syncAll()));
  }

  /// Sends what every account of this device still has queued, and keeps the grant of the live
  /// session renewed.
  Future<void> _syncAll() async {
    try {
      final account = _api.accountUUID;
      if (account != null) await _grants.ensure(account);
      await _sync.flushAll();
    } catch (_) {
      // Storage or network unavailable: the next tick tries again.
    }
  }

  void _sessionOpened(PulseAccount account) {
    if (account.mustChangePassword) return;
    unawaited(_grants.ensure(account.timeClockAccountUUID));
    unawaited(
      _vault.write(
        _profileKey,
        jsonEncode({
          'timeClockAccountUUID': account.timeClockAccountUUID,
          'loginCode': account.loginCode,
          'employeeName': account.employeeName,
          'companyName': account.companyName,
          'hrAccountName': account.hrAccountName,
        }),
      ),
    );
    unawaited(pwaPersistStorage());
    if (_offlineEntry && mounted) {
      setState(() {
        _offlineEntry = false;
        _account = account;
      });
    }
  }

  /// The employee of this device who did not sign out (kept only in secure storage).
  Future<PulseAccount?> _offlineProfile() async {
    try {
      final raw = await _vault.read(_profileKey);
      if (raw == null) return null;
      final account = PulseAccount.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      return account.timeClockAccountUUID.isEmpty ? null : account;
    } catch (_) {
      return null;
    }
  }

  void _brandChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    pulseBrand.removeListener(_brandChanged);
    _syncTimer?.cancel();
    _lifecycle?.dispose();
    _sync.dispose();
    _confirmPasswordController.dispose();
    _codeFocus.dispose();
    _passwordFocus.dispose();
    _loginCodeController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _clock.dispose();
    _focusRequest.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    setState(() => _restoring = true);
    final account = await _api.restore();
    final offline = account == null && _api.lastRefreshOffline
        ? await _offlineProfile()
        : null;
    if (!mounted) return;
    setState(() {
      _restoring = false;
      // A session still waiting for the first password change is not reopened: the temporary
      // password is needed again to change it.
      _account = account?.mustChangePassword == true
          ? null
          : account ?? offline;
      _offlineEntry = account == null && offline != null;
    });
    unawaited(_syncAll());
  }

  Future<void> _run(Future<void> Function() task) async {
    setState(() {
      _loading = true;
      _message = null;
      _messageError = false;
    });
    try {
      await task();
    } on PulseFailure catch (failure) {
      if (mounted) {
        setState(() {
          _messageError = true;
          _message = failure.code;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _messageError = true;
          _message = 'requestError';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signIn() async {
    if (_loading) return;
    if (!(_loginForm.currentState?.validate() ?? false)) {
      if (_loginCodeController.text.trim().isEmpty) {
        _codeFocus.requestFocus();
      } else {
        _passwordFocus.requestFocus();
      }
      return;
    }
    await _run(() async {
      final account = await _api.signIn(
        _loginCodeController.text.trim(),
        _passwordController.text,
      );
      setState(() {
        _account = account;
        _message = 'signedIn';
        if (!account.mustChangePassword) _passwordController.clear();
      });
    });
  }

  Future<void> _changePassword() async {
    if (_loading || !(_passwordForm.currentState?.validate() ?? false)) return;
    await _run(() async {
      await _api.changePassword(
        _passwordController.text,
        _newPasswordController.text,
      );
      setState(() {
        _account = _account?.passwordChanged();
        _passwordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _message = 'passwordChanged';
      });
    });
  }

  Future<void> _signOut() async {
    final account = _account;
    if (account != null && !account.mustChangePassword) {
      // Whatever can still go now goes before leaving.
      await _sync.flush(account.timeClockAccountUUID);
      final pending = await PunchQueue(account.timeClockAccountUUID).load();
      if (pending.isNotEmpty && mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l.pendingSignOutTitle),
            content: Text(l.pendingSignOutHelp),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l.signOutAnyway),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
      }
    }
    await _vault.delete(_profileKey);
    await _api.signOut();
    if (!mounted) return;
    setState(() {
      _offlineEntry = false;
      _account = null;
      _tab = 0;
      _timesheetOpened = false;
      _passwordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _message = 'signedOut';
      _messageError = false;
    });
  }

  void _sessionEnded(String code) {
    if (!mounted) return;
    setState(() {
      _offlineEntry = false;
      _account = null;
      _tab = 0;
      _timesheetOpened = false;
      _message = code;
      _messageError = true;
    });
  }

  String message(String key) => switch (key) {
    'PULSE_INVALID_CREDENTIALS' || 'invalidCredentials' => l.invalidCredentials,
    'PULSE_RATE_LIMITED' => l.rateLimited,
    'PULSE_ACCOUNT_LOCKED' => l.accountLocked,
    'PULSE_TEMPORARY_PASSWORD_EXPIRED' => l.temporaryPasswordExpired,
    'PULSE_MODULE_UNAVAILABLE' => l.moduleUnavailable,
    'PULSE_ACCESS_DENIED' => l.accessDenied,
    'PULSE_SESSION_INVALID' => l.sessionEnded,
    'PULSE_INVALID_PASSWORD' => l.invalidPassword,
    'PULSE_PASSWORD_UNCHANGED' => l.passwordUnchanged,
    'PULSE_PASSWORD_TOO_SHORT' => l.passwordLength,
    'networkError' => l.networkError,
    'signedIn' => l.signedIn,
    'signedOut' => l.signedOut,
    'passwordChanged' => l.passwordChanged,
    _ => l.requestError,
  };

  @override
  Widget build(BuildContext context) {
    final account = _account;
    if (_restoring) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l.loading),
            ],
          ),
        ),
      );
    }
    final access = account == null || account.mustChangePassword;
    final banner = _message != null && (access || _message != 'signedIn')
        ? Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Semantics(
              liveRegion: true,
              child: Text(
                message(_message!),
                style: TextStyle(
                  color: _messageError
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          )
        : null;
    if (access) {
      return AccessShell(
        onSignOut: account == null || _loading ? null : _signOut,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ?banner,
            if (account == null)
              _buildLogin(context)
            else
              _buildFirstAccess(context, account),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(pulseBrand.value?.title ?? 'MNSCloud Pulse'),
        actions: [
          NotificationsButton(
            key: ValueKey('bell-${account.timeClockAccountUUID}'),
            api: _api,
            onOpenRequest: _openRequests,
            onSessionEnded: _sessionEnded,
          ),
          const AccessLanguageButton(),
          const InstallAppButton(),
          IconButton(
            tooltip: l.signOut,
            onPressed: _loading ? null : _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            // Both tabs stay mounted (the punch queue keeps retrying); the hidden one has its
            // tickers off, which pauses its periodic reads.
            child: IndexedStack(
              index: _tab,
              sizing: StackFit.expand,
              children: [
                TickerMode(
                  enabled: _tab == 0,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ?banner,
                        if (_offlineEntry)
                          Padding(
                            key: const Key('offlineEntry'),
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              l.offlineEntry,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        PunchWorkspace(
                          key: ValueKey(account.timeClockAccountUUID),
                          api: _api,
                          account: account,
                          clock: _clock,
                          sync: _sync,
                          onSessionEnded: _sessionEnded,
                        ),
                      ],
                    ),
                  ),
                ),
                TickerMode(
                  enabled: _tab == 1,
                  child: _timesheetOpened
                      ? TimesheetView(
                          key: ValueKey(
                            'timesheet-${account.timeClockAccountUUID}',
                          ),
                          api: _api,
                          clock: _clock,
                          onSessionEnded: _sessionEnded,
                        )
                      : const SizedBox.shrink(),
                ),
                TickerMode(
                  enabled: _tab == 2,
                  child: _requestsOpened
                      ? RequestsView(
                          key: ValueKey(
                            'requests-${account.timeClockAccountUUID}',
                          ),
                          api: _api,
                          clock: _clock,
                          onSessionEnded: _sessionEnded,
                          focus: _focusRequest,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() {
          _tab = index;
          if (index == 1) _timesheetOpened = true;
          if (index == 2) _requestsOpened = true;
        }),
        destinations: [
          NavigationDestination(
            key: const Key('navHome'),
            icon: const Icon(Icons.fingerprint),
            label: l.navHome,
          ),
          NavigationDestination(
            key: const Key('navTimesheet'),
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l.navTimesheet,
          ),
          NavigationDestination(
            key: const Key('navRequests'),
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(Icons.assignment),
            label: l.navRequests,
          ),
        ],
      ),
    );
  }

  Widget _buildLogin(BuildContext context) {
    return Form(
      key: _loginForm,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              accessText(context, 'eyebrow', l.eyebrow).toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              accessText(context, 'title', l.title),
              style: const TextStyle(
                fontSize: 34,
                height: 1.15,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              accessText(context, 'subtitle', l.subtitle),
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _loginCodeController,
              focusNode: _codeFocus,
              decoration: InputDecoration(labelText: l.employeeCode),
              textCapitalization: TextCapitalization.characters,
              autofillHints: const [AutofillHints.username],
              textInputAction: TextInputAction.next,
              autocorrect: false,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? l.required : null,
              onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              decoration: InputDecoration(
                labelText: l.password,
                suffixIcon: IconButton(
                  tooltip: _showPassword ? l.hidePassword : l.showPassword,
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              obscureText: !_showPassword,
              autofillHints: const [AutofillHints.password],
              enableSuggestions: false,
              autocorrect: false,
              validator: (value) =>
                  value == null || value.isEmpty ? l.required : null,
              onFieldSubmitted: (_) => _signIn(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const Key('forgotPassword'),
                onPressed: () => showForgotPasswordDialog(context),
                child: Text(l.forgotPassword),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _loading ? null : _signIn,
              child: Text(l.signIn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstAccess(BuildContext context, PulseAccount account) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          account.employeeName ?? l.employee,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(account.loginCode),
        const SizedBox(height: 20),
        Text(l.firstAccess, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(l.firstAccessHelp),
        const SizedBox(height: 24),
        Form(
          key: _passwordForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _newPasswordController,
                autofocus: true,
                obscureText: !_showPassword,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  labelText: l.newPassword,
                  helperText: l.passwordLength,
                  suffixIcon: IconButton(
                    tooltip: _showPassword ? l.hidePassword : l.showPassword,
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
                validator: (value) =>
                    (value?.length ?? 0) < 10 ? l.passwordLength : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(labelText: l.confirmPassword),
                validator: (value) => value != _newPasswordController.text
                    ? l.passwordMismatch
                    : value == null || value.isEmpty
                    ? l.required
                    : null,
                onFieldSubmitted: (_) => _changePassword(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _changePassword,
                child: Text(l.changePassword),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
