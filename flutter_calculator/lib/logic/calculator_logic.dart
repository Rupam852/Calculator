import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryItem {
  final String expression;
  final String result;

  HistoryItem({required this.expression, required this.result});

  Map<String, String> toJson() => {
        'expression': expression,
        'result': result,
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        expression: json['expression'] ?? '',
        result: json['result'] ?? '',
      );
}

class CalculatorLogic extends ChangeNotifier {
  String _currentInput = '0';
  double? _previousValue;
  String? _activeOperator; // 'add', 'subtract', 'multiply', 'divide'
  bool _shouldResetDisplay = false;
  String _expression = '';
  List<HistoryItem> _history = [];
  bool _isDarkMode = true;

  // Getters
  String get currentInput => _currentInput;
  String? get activeOperator => _activeOperator;
  String get expression => _expression;
  List<HistoryItem> get history => _history;
  bool get isDarkMode => _isDarkMode;

  CalculatorLogic() {
    loadSettings();
  }

  // Load theme and history from SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load theme
    _isDarkMode = prefs.getBool('calculator-theme-dark') ?? true;

    // Load history
    final String? historyJson = prefs.getString('calculator-history');
    if (historyJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(historyJson);
        _history = decoded.map((item) => HistoryItem.fromJson(item)).toList();
      } catch (e) {
        _history = [];
      }
    }
    notifyListeners();
  }

  // Toggle Theme
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('calculator-theme-dark', _isDarkMode);
  }

  // Save history helper
  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String historyJson = jsonEncode(_history.map((item) => item.toJson()).toList());
    await prefs.setString('calculator-history', historyJson);
  }

  // Add history item
  Future<void> _addHistoryItem(String expr, String result) async {
    if (_history.isNotEmpty && _history.first.expression == expr && _history.first.result == result) {
      return;
    }
    _history.insert(0, HistoryItem(expression: expr, result: result));
    if (_history.length > 50) {
      _history.removeLast();
    }
    notifyListeners();
    await _saveHistory();
  }

  // Clear history
  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('calculator-history');
  }

  // Restore calculation from history
  void selectHistoryItem(HistoryItem item) {
    _currentInput = item.result;
    _previousValue = null;
    _activeOperator = null;
    _expression = '';
    _shouldResetDisplay = false;
    notifyListeners();
  }

  // Precision number formatting
  String formatNumber(double value) {
    if (value.isNaN || value.isInfinite) return 'Error';
    
    // Avoid floating-point inaccuracies
    String valStr = value.toStringAsFixed(10);
    double rounded = double.parse(valStr);
    
    if (rounded == rounded.toInt().toDouble()) {
      return rounded.toInt().toString();
    }
    
    String result = rounded.toString();
    if (result.contains('.')) {
      result = result.replaceAll(RegExp(r'\.?0+$'), ''); // Trim trailing zeroes
    }
    return result;
  }

  // User input operations
  void appendNumber(String num) {
    if (_currentInput == '0' || _shouldResetDisplay) {
      if (_expression.endsWith('=')) {
        _expression = '';
      }
      _currentInput = num;
      _shouldResetDisplay = false;
    } else {
      if (_currentInput.length < 15) {
        _currentInput += num;
      }
    }
    notifyListeners();
  }

  void appendDecimal() {
    if (_shouldResetDisplay) {
      if (_expression.endsWith('=')) {
        _expression = '';
      }
      _currentInput = '0.';
      _shouldResetDisplay = false;
      notifyListeners();
      return;
    }
    if (!_currentInput.contains('.')) {
      _currentInput += '.';
      notifyListeners();
    }
  }

  void clearAll() {
    _currentInput = '0';
    _previousValue = null;
    _activeOperator = null;
    _expression = '';
    _shouldResetDisplay = false;
    notifyListeners();
  }

  void handleBackspace() {
    if (_expression.endsWith('=')) {
      clearAll();
      return;
    }

    if (_shouldResetDisplay || _currentInput == '0') {
      if (_activeOperator != null) {
        final List<String> parts = _expression.split(' ');
        if (parts.length >= 3) {
          final String lastNum = parts.removeLast();
          final String lastOp = parts.removeLast();
          
          _expression = parts.join(' ');
          
          final opMapping = {'+': 'add', '−': 'subtract', '×': 'multiply', '÷': 'divide'};
          _activeOperator = opMapping[lastOp];
          _previousValue = _evaluateExpressionParts(parts);
          
          _currentInput = lastNum;
          _shouldResetDisplay = false;
        } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
          _currentInput = parts[0];
          _expression = '';
          _activeOperator = null;
          _previousValue = null;
          _shouldResetDisplay = false;
        } else {
          clearAll();
        }
      } else {
        clearAll();
      }
    } else {
      if (_currentInput.length > 1) {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      } else {
        _currentInput = '0';
      }
    }
    notifyListeners();
  }

  double _evaluateExpressionParts(List<String> parts) {
    if (parts.isEmpty) return 0;
    double result = double.tryParse(parts[0]) ?? 0;
    
    int i = 1;
    while (i < parts.length - 1) {
      String op = parts[i];
      double nextVal = double.tryParse(parts[i + 1]) ?? 0;
      
      if (op == '+') {
        result += nextVal;
      } else if (op == '−') {
        result -= nextVal;
      } else if (op == '×') {
        result *= nextVal;
      } else if (op == '÷') {
        if (nextVal != 0) {
          result /= nextVal;
        } else {
          result = 0;
        }
      }
      i += 2;
    }
    return result;
  }

  void handlePercent() {
    final double? num = double.tryParse(_currentInput);
    if (num != null) {
      _currentInput = formatNumber(num / 100);
      notifyListeners();
    }
  }

  void handleNegate() {
    if (_currentInput == '0') return;
    if (_currentInput.startsWith('-')) {
      _currentInput = _currentInput.substring(1);
    } else {
      _currentInput = '-$_currentInput';
    }
    notifyListeners();
  }

  void chooseOperator(String operator) {
    if (_shouldResetDisplay && _activeOperator != null) {
      // Just switch the active operator
      _activeOperator = operator;
      notifyListeners();
      return;
    }

    if (_activeOperator != null && !_shouldResetDisplay) {
      // Intermediate calculation (builds continuous expression)
      final double? prev = _previousValue;
      final double? current = double.tryParse(_currentInput);
      if (prev != null && current != null) {
        double result;
        switch (_activeOperator) {
          case 'add': result = prev + current; break;
          case 'subtract': result = prev - current; break;
          case 'multiply': result = prev * current; break;
          case 'divide':
            if (current == 0) {
              _currentInput = 'Error';
              _expression = '$_expression ÷ 0';
              _activeOperator = null;
              _shouldResetDisplay = true;
              notifyListeners();
              return;
            }
            result = prev / current;
            break;
          default: return;
        }
        final opSymbols = {'add': '+', 'subtract': '−', 'multiply': '×', 'divide': '÷'};
        final String currentOpSymbol = opSymbols[_activeOperator] ?? '';
        
        _expression = '$_expression $currentOpSymbol ${formatNumber(current)}';
        _previousValue = result;
      }
    } else {
      _previousValue = double.tryParse(_currentInput);
      if (_previousValue != null) {
        _expression = formatNumber(_previousValue!);
      }
    }

    _activeOperator = operator;
    _currentInput = '0'; // Clear the input box for the next number entry
    _shouldResetDisplay = true;
    notifyListeners();
  }

  void calculate() {
    if (_activeOperator == null || _shouldResetDisplay) return;

    final double? prev = _previousValue;
    final double? current = double.tryParse(_currentInput);

    if (prev == null || current == null) return;

    double result;
    switch (_activeOperator) {
      case 'add': result = prev + current; break;
      case 'subtract': result = prev - current; break;
      case 'multiply': result = prev * current; break;
      case 'divide':
        if (current == 0) {
          _currentInput = 'Error';
          _expression = '$_expression ÷ 0';
          _activeOperator = null;
          _shouldResetDisplay = true;
          notifyListeners();
          return;
        }
        result = prev / current;
        break;
      default: return;
    }

    final opSymbols = {'add': '+', 'subtract': '−', 'multiply': '×', 'divide': '÷'};
    final String currentOpSymbol = opSymbols[_activeOperator] ?? '';
    final String fullExpression = '$_expression $currentOpSymbol ${formatNumber(current)}';
    final String formattedResult = formatNumber(result);

    _currentInput = formattedResult;
    _expression = '$fullExpression =';
    _addHistoryItem(fullExpression, formattedResult);

    _activeOperator = null;
    _previousValue = null;
    _shouldResetDisplay = true;
    notifyListeners();
  }
}
