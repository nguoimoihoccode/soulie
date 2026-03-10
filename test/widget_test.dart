import 'package:flutter_test/flutter_test.dart';
import 'package:soulie/main.dart';

void main() {
  testWidgets('App should start', (WidgetTester tester) async {
    await tester.pumpWidget(const SoulieApp());
    await tester.pumpAndSettle();
    expect(find.text('Soulie'), findsWidgets);
  });
}
