import 'package:flutter_test/flutter_test.dart';
import 'package:bluemart/main.dart';

void main() {
  testWidgets('App starts and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BlueMartApp());
    expect(find.text('BlueMart'), findsOneWidget);
  });
}