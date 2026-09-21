import 'package:flutter_test/flutter_test.dart';
import 'package:wcwi_team_project/main.dart';

void main() {
  testWidgets('connection modes are displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('WiFi Mode'), findsOneWidget);
    expect(find.text('Bluetooth Mode'), findsOneWidget);
    expect(find.text('Chat History'), findsOneWidget);
  });
}
