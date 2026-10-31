import 'package:flutter_test/flutter_test.dart';
import 'package:mnscloud_pulse/src/core/punch_queue.dart';
import 'package:mnscloud_pulse/src/offline/device_lock.dart';
import 'package:mnscloud_pulse/src/offline/secret_vault.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:mnscloud_pulse/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SecretVault.instance = MemoryVault();
    PunchStore.use(PunchStore.memory(sqlite3.openInMemory()));
    resetDeviceLock();
  });

  testWidgets('renders Pulse shell', (tester) async {
    await tester.pumpWidget(const PulseApp());
    await tester.pumpAndSettle();

    expect(find.text('MNSCloud Pulse'), findsOneWidget);
    expect(find.text('Access your time clock'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
