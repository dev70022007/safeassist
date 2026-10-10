import 'package:flutter_test/flutter_test.dart';
import 'package:safeassist/main.dart';

void main() {
  testWidgets('SafeAssist app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SafeAssistApp());

    expect(find.text('SafeAssist'), findsWidgets);
    expect(find.text('DEMO MODE'), findsOneWidget);
  });
}
