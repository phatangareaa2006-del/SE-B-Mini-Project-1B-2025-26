import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_app/main.dart';

void main() {
  testWidgets('App loads and shows Dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const CoffeeApp());
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
