import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const PulseApp());
}

class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MNSCloud Pulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff2ed7d0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const PulseShell(),
    );
  }
}

class PulseShell extends StatefulWidget {
  const PulseShell({super.key});

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

  String? _token;
  Map<String, dynamic>? _account;
  List<Map<String, dynamic>> _punches = [];
  bool _loading = false;
  String? _message;

  @override
  void dispose() {
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

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);
    final data = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['error'] ?? data['message'] ?? 'Request failed.');
    }

    return data;
  }

  Future<void> _run(Future<void> Function() task) async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await task();
    } catch (error) {
      setState(
        () => _message = error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signIn() async {
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
        _message = 'Signed in successfully.';
      });
      await _loadPunches();
    });
  }

  Future<void> _changePassword() async {
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
        _newPasswordController.clear();
        _message = 'Password changed successfully.';
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
        () => _message = item?['Duplicate'] == 1
            ? 'Punch already synced.'
            : 'Punch saved.',
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
      _message = 'Signed out.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MNSCloud Pulse'),
        actions: [
          if (_token != null)
            IconButton(
              tooltip: 'Sign out',
              onPressed: _loading ? null : _signOut,
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.fingerprint,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pulse',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text('Secure workforce time clock'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _message!,
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ),
                if (_token == null)
                  _buildLogin(context)
                else
                  _buildWorkspace(context),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogin(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _loginCodeController,
          decoration: const InputDecoration(labelText: 'Employee login'),
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _loading ? null : _signIn,
          icon: const Icon(Icons.login),
          label: const Text('Sign in'),
        ),
      ],
    );
  }

  Widget _buildWorkspace(BuildContext context) {
    final account = _account ?? {};
    final mustChange = account['mustChangePassword'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          account['employeeName']?.toString() ?? 'Employee',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(account['loginCode']?.toString() ?? ''),
        const SizedBox(height: 20),
        if (mustChange) ...[
          TextField(
            controller: _newPasswordController,
            decoration: const InputDecoration(labelText: 'New password'),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _changePassword,
            icon: const Icon(Icons.lock_reset),
            label: const Text('Change password'),
          ),
        ] else ...[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _PunchButton(
                label: 'Clock in',
                icon: Icons.login,
                onPressed: () => _recordPunch('clock_in'),
              ),
              _PunchButton(
                label: 'Break start',
                icon: Icons.coffee,
                onPressed: () => _recordPunch('break_start'),
              ),
              _PunchButton(
                label: 'Break end',
                icon: Icons.work,
                onPressed: () => _recordPunch('break_end'),
              ),
              _PunchButton(
                label: 'Clock out',
                icon: Icons.logout,
                onPressed: () => _recordPunch('clock_out'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Recent punches',
            style: Theme.of(context).textTheme.titleMedium,
          ),
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
