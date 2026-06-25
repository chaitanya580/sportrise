import 'package:flutter_test/flutter_test.dart';

import 'package:sportrise/main.dart';

void main() {
  testWidgets('App renders welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SportRiseApp());
    await tester.pumpAndSettle();

    expect(find.text('SportRise'), findsOneWidget);
  });
}
