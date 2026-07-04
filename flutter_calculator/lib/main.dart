import 'package:flutter/material.dart';
import 'logic/calculator_logic.dart';
import 'screens/calculator_screen.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized for SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  
  final CalculatorLogic logic = CalculatorLogic();
  // Wait for saved theme and history state to load
  await logic.loadSettings();
  
  runApp(MyApp(logic: logic));
}

class MyApp extends StatelessWidget {
  final CalculatorLogic logic;
  const MyApp({super.key, required this.logic});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Premium Glassmorphic Calculator',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      home: CalculatorScreen(logic: logic),
    );
  }
}
