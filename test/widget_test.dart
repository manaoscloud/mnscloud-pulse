import 'package:flutter_test/flutter_test.dart';
import 'package:mnscloud_pulse/main.dart';

void main() {
  testWidgets('renders Pulse shell', (tester) async {
    await tester.pumpWidget(const PulseApp());

    expect(find.text('MNSCloud Pulse'), findsOneWidget);
    expect(find.text('Secure workforce time clock'), findsOneWidget);
    expect(find.text('Pulse login coming next'), findsOneWidget);
  });
}
