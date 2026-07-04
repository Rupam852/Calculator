import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_calculator/main.dart';
import 'package:flutter_calculator/logic/calculator_logic.dart';

void main() {
  testWidgets('Calculator UI elements smoke test', (WidgetTester tester) async {
    final CalculatorLogic logic = CalculatorLogic();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(logic: logic));

    // Verify that the app title is present
    expect(find.text('CALCULATOR'), findsOneWidget);

    // Verify that the starting calculator value is '0'
    expect(find.text('0'), findsAtLeastNWidgets(1));
  });
}
