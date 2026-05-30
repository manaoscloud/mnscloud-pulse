import 'package:flutter/material.dart';

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

class PulseShell extends StatelessWidget {
  const PulseShell({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
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
                                'MNSCloud Pulse',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text('Secure workforce time clock'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 96),
                    Text(
                      'Clock in with a Pulse code, not personal documents.',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This public Flutter client will consume the documented MNSCloud Pulse API. '
                      'Authentication, tenant scope, password hashing, geofence decisions, and '
                      'timesheet rules stay in the MNSCloud API/control plane.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.login),
                      label: const Text('Pulse login coming next'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.schedule),
                      label: const Text('Time clock workspace'),
                    ),
                    const SizedBox(height: 96),
                    Text(
                      'No secrets, customer data, production hosts, or private policy rules belong in this repository.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
