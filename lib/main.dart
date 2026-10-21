import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'src/brand/brand.dart';
import 'src/access/access_shell.dart';
import 'src/access/access_preferences.dart';
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
  const PulseShell({super.key, this.client});
  final http.Client? client;

  @override
  State<PulseShell> createState() => _PulseShellState();
}

class _PulseShellState extends State<PulseShell> {
  static const _apiBaseUrl = String.fromEnvironment(
    'PULSE_PUBLIC_API_BASE_URL',
    defaultValue: '/api/v1',
  );

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
  String? _token;
  Map<String, dynamic>? _account;
  List<Map<String, dynamic>> _punches = [];
  bool _loading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    pulseBrand.addListener(_brandChanged);
  }

  void _brandChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    pulseBrand.removeListener(_brandChanged);
    _confirmPasswordController.dispose();
    _codeFocus.dispose();
    _passwordFocus.dispose();
    _loginCodeController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Uri _uri(String path) {
    final base = _apiBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$base$path');
  }

  Map<String, String> get _jsonHeaders => {
    'content-type': 'application/json',
    if (_token != null) 'authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final request = http.Request(method, _uri(path));
    request.headers.addAll(_jsonHeaders);
    if (body != null) request.body = jsonEncode(body);

    final streamed = await (widget.client?.send(request) ?? request.send())
        .timeout(const Duration(seconds: 20));
    final response = await http.Response.fromStream(streamed);
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);
    final data = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _AccessFailure(
        response.statusCode == 429
            ? 'rateLimited'
            : data['code'] == 'PULSE_INVALID_CREDENTIALS' ||
                  (path.endsWith('/signin') && response.statusCode == 401)
            ? 'invalidCredentials'
            : 'requestError',
      );
    }

    return data;
  }

  Future<void> _run(Future<void> Function() task) async {
    setState(() {
      _loading = true;
      _message = null;
      _messageError = false;
    });
    try {
      await task();
    } catch (error) {
      if (mounted) {
        setState(() {
          _messageError = true;
          _message = error is _AccessFailure ? error.code : 'networkError';
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
      final response = await _request(
        'POST',
        '/pulse/auth/signin',
        body: {
          'loginCode': _loginCodeController.text.trim(),
          'password': _passwordController.text,
        },
      );
      final data = response['data'] as Map<String, dynamic>;
      setState(() {
        _token = data['jwt'] as String?;
        _account = data['account'] as Map<String, dynamic>?;
        _message = 'signedIn';
      });
      if (_account?['mustChangePassword'] != true) await _loadPunches();
    });
  }

  Future<void> _changePassword() async {
    if (_loading || !(_passwordForm.currentState?.validate() ?? false)) return;
    await _run(() async {
      await _request(
        'POST',
        '/pulse/auth/change-password',
        body: {
          'currentPassword': _passwordController.text,
          'newPassword': _newPasswordController.text,
        },
      );
      final profile = await _request('GET', '/pulse/auth/me');
      setState(() {
        _account = profile['data']?['item'] as Map<String, dynamic>?;
        _passwordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _message = 'passwordChanged';
      });
    });
  }

  Future<void> _recordPunch(String type) async {
    await _run(() async {
      final response = await _request(
        'POST',
        '/pulse/punches',
        body: {
          'type': type,
          'idempotencyKey': '${DateTime.now().microsecondsSinceEpoch}-$type',
          'occurredAt': DateTime.now().toUtc().toIso8601String(),
          'source': 'mobile',
        },
      );
      final item = response['data']?['item'] as Map<String, dynamic>?;
      setState(
        () => _message = item?['Duplicate'] == 1 ? 'punchSynced' : 'punchSaved',
      );
      await _loadPunches();
    });
  }

  Future<void> _loadPunches() async {
    final response = await _request('GET', '/pulse/punches?limit=20');
    final items = response['data']?['items'];
    setState(() {
      _punches = items is List
          ? items.whereType<Map<String, dynamic>>().toList()
          : [];
    });
  }

  void _signOut() {
    setState(() {
      _token = null;
      _account = null;
      _punches = [];
      _passwordController.clear();
      _newPasswordController.clear();
      _message = 'signedOut';
    });
  }

  String message(String key) => switch (key) {
    'invalidCredentials' => l.invalidCredentials,
    'rateLimited' => l.rateLimited,
    'requestError' => l.requestError,
    'networkError' => l.networkError,
    'signedIn' => l.signedIn,
    'signedOut' => l.signedOut,
    'passwordChanged' => l.passwordChanged,
    'punchSaved' => l.punchSaved,
    'punchSynced' => l.punchSynced,
    _ => l.requestError,
  };

  @override
  Widget build(BuildContext context) {
    final access = _token == null || _account?['mustChangePassword'] == true;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_message != null)
          Padding(
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
          ),
        if (_token == null) _buildLogin(context) else _buildWorkspace(context),
        if (_loading)
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: LinearProgressIndicator(),
          ),
      ],
    );
    if (access) {
      return AccessShell(
        onSignOut: _token == null || _loading ? null : _signOut,
        child: content,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(pulseBrand.value?.title ?? 'MNSCloud Pulse'),
        actions: [
          const AccessLanguageButton(),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: content,
            ),
          ),
        ),
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

  Widget _buildWorkspace(BuildContext context) {
    final account = _account ?? {};
    final mustChange = account['mustChangePassword'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          account['employeeName']?.toString() ?? l.employee,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(account['loginCode']?.toString() ?? ''),
        const SizedBox(height: 20),
        if (mustChange) ...[
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
        ] else ...[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _PunchButton(
                label: l.clockIn,
                icon: Icons.login,
                onPressed: () => _recordPunch('clock_in'),
              ),
              _PunchButton(
                label: l.breakStart,
                icon: Icons.coffee,
                onPressed: () => _recordPunch('break_start'),
              ),
              _PunchButton(
                label: l.breakEnd,
                icon: Icons.work,
                onPressed: () => _recordPunch('break_end'),
              ),
              _PunchButton(
                label: l.clockOut,
                icon: Icons.logout,
                onPressed: () => _recordPunch('clock_out'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(l.recentPunches, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final punch in _punches)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: Text(punch['Type']?.toString() ?? ''),
              subtitle: Text(punch['OccurredAt']?.toString() ?? ''),
              trailing: Text(punch['Status']?.toString() ?? ''),
            ),
        ],
      ],
    );
  }
}

class _PunchButton extends StatelessWidget {
  const _PunchButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _AccessFailure implements Exception {
  const _AccessFailure(this.code);
  final String code;
}
