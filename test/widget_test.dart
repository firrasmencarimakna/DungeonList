import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('RPG Quest Log loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RPGQuestApp());

    // Verify that the title is present.
    expect(find.text('Ye Olde Quest Log'), findsOneWidget);
  });
}
