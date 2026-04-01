import 'package:flutter_test/flutter_test.dart';
import 'package:sabji_mart/main.dart';

void main() {
  testWidgets('Veg app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VegApp());
    expect(find.byType(VegApp), findsOneWidget);
  });
}
