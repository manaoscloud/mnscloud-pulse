import 'package:flutter_test/flutter_test.dart';
import 'package:mnscloud_pulse/main.dart';

void main() {
  testWidgets('renders Pulse shell', (tester) async {
    await tester.pumpWidget(const PulseApp());
    await tester.pumpAndSettle();

    expect(find.text('MNSCloud Pulse'), findsOneWidget);
    expect(find.text('Access your time clock'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
