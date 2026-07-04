import 'dart:ui';
import 'package:flutter/material.dart';
import '../logic/calculator_logic.dart';
import '../widgets/glass_box.dart';

class CalculatorScreen extends StatefulWidget {
  final CalculatorLogic logic;
  const CalculatorScreen({super.key, required this.logic});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  bool _isHistoryOpen = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.logic,
      builder: (context, _) {
        final bool isDark = widget.logic.isDarkMode;

        // Theme colors
        final Color textMain = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);
        final Color textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

        final Color cardBg = isDark ? const Color(0x1F111827) : const Color(0xA6FFFFFF);
        final Color cardBorder = isDark ? const Color(0x15FFFFFF) : const Color(0x99FFFFFF);

        final Color screenBg = isDark ? const Color(0xB20A0F1E) : const Color(0xB3FFFFFF);
        final Color screenBorder = isDark ? const Color(0x0DFFFFFF) : const Color(0x80FFFFFF);

        final Color btnNumBg = isDark ? const Color(0x0AFFFFFF) : const Color(0xB3FFFFFF);
        final Color btnNumBorder = isDark ? const Color(0x08FFFFFF) : const Color(0xCCFFFFFF);
        final Color btnNumText = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155);

        final Color btnActionBg = isDark ? const Color(0x26F43F5E) : const Color(0x14E11D48);
        final Color btnActionBorder = isDark ? const Color(0x33F43F5E) : const Color(0x26E11D48);
        final Color btnActionText = isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48);

        final Color btnOpBg = isDark ? const Color(0x336366F1) : const Color(0x144F46E5);
        final Color btnOpBorder = isDark ? const Color(0x406366F1) : const Color(0x264F46E5);
        final Color btnOpText = isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5);

        final List<Color> btnEqGradient = isDark
            ? [const Color(0xFF6366F1), const Color(0xFFA855F7)]
            : [const Color(0xFF4F46E5), const Color(0xFF9333EA)];

        final Color historyDrawerBg = isDark ? const Color(0xF20F172A) : const Color(0xF7FFFFFF);

        // Dimensions
        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isMobile = screenWidth <= 600;
        final double cardWidth = screenWidth > 400 ? 375.0 : screenWidth * 0.9;
        final double drawerWidth = isMobile ? screenWidth * 0.85 : 375.0;

        return Scaffold(
          body: Stack(
            children: [
              // 1. Dynamic Background Gradient
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF090D16), const Color(0xFF111827), const Color(0xFF1E112A)]
                        : [const Color(0xFFEEF2F6), const Color(0xFFE0E7FF), const Color(0xFFFAE8FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // 2. Glowing Blur Background Shapes
              Positioned(
                top: -100,
                left: -100,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? const Color(0x266366F1) : const Color(0x336366F1),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                right: -100,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 600,
                  height: 600,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? const Color(0x1FA855F7) : const Color(0x26A855F7),
                  ),
                ),
              ),

              // 3. Overall Blur overlay for background shapes
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),

              // 4. Main Calculator Interface
              SafeArea(
                child: isMobile
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          children: [
                            // Header
                            _buildHeader(textMain, textMuted),
                            const SizedBox(height: 16),
                            // Screen Display (Expanded on mobile to take remaining space)
                            Expanded(
                              child: _buildScreenDisplay(
                                screenBg: screenBg,
                                screenBorder: screenBorder,
                                textMuted: textMuted,
                                textMain: textMain,
                                screenWidth: screenWidth,
                                isMobile: true,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Keypad Grid
                            _buildKeypad(
                              isDark: isDark,
                              btnNumBg: btnNumBg,
                              btnNumBorder: btnNumBorder,
                              btnNumText: btnNumText,
                              btnActionBg: btnActionBg,
                              btnActionBorder: btnActionBorder,
                              btnActionText: btnActionText,
                              btnOpBg: btnOpBg,
                              btnOpBorder: btnOpBorder,
                              btnOpText: btnOpText,
                              btnEqGradient: btnEqGradient,
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: GlassBox(
                            width: cardWidth,
                            color: cardBg,
                            borderColor: cardBorder,
                            borderRadius: BorderRadius.circular(32),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildHeader(textMain, textMuted),
                                const SizedBox(height: 20),
                                _buildScreenDisplay(
                                  screenBg: screenBg,
                                  screenBorder: screenBorder,
                                  textMuted: textMuted,
                                  textMain: textMain,
                                  screenWidth: screenWidth,
                                  isMobile: false,
                                ),
                                const SizedBox(height: 20),
                                _buildKeypad(
                                  isDark: isDark,
                                  btnNumBg: btnNumBg,
                                  btnNumBorder: btnNumBorder,
                                  btnNumText: btnNumText,
                                  btnActionBg: btnActionBg,
                                  btnActionBorder: btnActionBorder,
                                  btnActionText: btnActionText,
                                  btnOpBg: btnOpBg,
                                  btnOpBorder: btnOpBorder,
                                  btnOpText: btnOpText,
                                  btnEqGradient: btnEqGradient,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),

              // 5. Sliding History Drawer Overlay (Root stack level)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                top: 0,
                bottom: 0,
                right: _isHistoryOpen ? 0 : -drawerWidth,
                width: drawerWidth,
                child: GlassBox(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(24),
                    bottomLeft: const Radius.circular(24),
                    topRight: isMobile ? Radius.zero : const Radius.circular(24),
                    bottomRight: isMobile ? Radius.zero : const Radius.circular(24),
                  ),
                  color: historyDrawerBg,
                  borderColor: cardBorder,
                  child: SafeArea(
                    child: Column(
                      children: [
                        // History Header
                        Padding(
                          padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'History',
                                style: TextStyle(
                                  color: textMain,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: widget.logic.clearHistory,
                                    child: Text(
                                      'Clear All',
                                      style: TextStyle(color: btnActionText, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: textMain),
                                    onPressed: () {
                                      setState(() {
                                        _isHistoryOpen = false;
                                      });
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Colors.white24),
                        
                        // History List
                        Expanded(
                          child: widget.logic.history.isEmpty
                              ? Center(
                                  child: Text(
                                    'No history yet',
                                    style: TextStyle(color: textMuted, fontSize: 16),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: widget.logic.history.length,
                                  itemBuilder: (context, index) {
                                    final item = widget.logic.history[index];
                                    return InkWell(
                                      onTap: () {
                                        widget.logic.selectHistoryItem(item);
                                        setState(() {
                                          _isHistoryOpen = false;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              item.expression,
                                              style: TextStyle(color: textMuted, fontSize: 13),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.result,
                                              style: TextStyle(
                                                color: textMain,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(Color textMain, Color textMuted) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            widget.logic.isDarkMode ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
            color: textMain,
          ),
          onPressed: widget.logic.toggleTheme,
        ),
        Text(
          'CALCULATOR',
          style: TextStyle(
            color: textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 2.0,
          ),
        ),
        IconButton(
          icon: Icon(Icons.history, color: textMain),
          onPressed: () {
            setState(() {
              _isHistoryOpen = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildScreenDisplay({
    required Color screenBg,
    required Color screenBorder,
    required Color textMuted,
    required Color textMain,
    required double screenWidth,
    required bool isMobile,
  }) {
    return Container(
      width: double.infinity,
      constraints: isMobile ? null : const BoxConstraints(minHeight: 110),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: screenBg,
        border: Border.all(color: screenBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Expression Preview
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Text(
              widget.logic.expression +
                  (widget.logic.activeOperator != null
                      ? ' ${_getOperatorSymbol(widget.logic.activeOperator!)}'
                      : ''),
              style: TextStyle(
                color: textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Current Input
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Text(
              widget.logic.currentInput,
              style: TextStyle(
                color: textMain,
                fontSize: screenWidth < 360 ? 30 : 36,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getOperatorSymbol(String op) {
    final opSymbols = {'add': '+', 'subtract': '−', 'multiply': '×', 'divide': '÷'};
    return opSymbols[op] ?? '';
  }

  Widget _buildKeypad({
    required bool isDark,
    required Color btnNumBg,
    required Color btnNumBorder,
    required Color btnNumText,
    required Color btnActionBg,
    required Color btnActionBorder,
    required Color btnActionText,
    required Color btnOpBg,
    required Color btnOpBorder,
    required Color btnOpText,
    required List<Color> btnEqGradient,
  }) {
    // Keypad layout items
    final List<Map<String, dynamic>> keys = [
      {'text': 'AC', 'type': 'action', 'action': 'clear'},
      {'text': '⌫', 'type': 'action', 'action': 'backspace'},
      {'text': '%', 'type': 'action', 'action': 'percent'},
      {'text': '÷', 'type': 'operator', 'operator': 'divide'},
      
      {'text': '7', 'type': 'number'},
      {'text': '8', 'type': 'number'},
      {'text': '9', 'type': 'number'},
      {'text': '×', 'type': 'operator', 'operator': 'multiply'},
      
      {'text': '4', 'type': 'number'},
      {'text': '5', 'type': 'number'},
      {'text': '6', 'type': 'number'},
      {'text': '−', 'type': 'operator', 'operator': 'subtract'},
      
      {'text': '1', 'type': 'number'},
      {'text': '2', 'type': 'number'},
      {'text': '3', 'type': 'number'},
      {'text': '+', 'type': 'operator', 'operator': 'add'},
      
      {'text': '±', 'type': 'action', 'action': 'negate'},
      {'text': '0', 'type': 'number'},
      {'text': '.', 'type': 'decimal'},
      {'text': '=', 'type': 'equals'},
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final keyItem = keys[index];
        final String text = keyItem['text'];
        final String type = keyItem['type'];

        Color bg;
        Color border;
        Color textColor;
        List<Color>? gradient;

        if (type == 'number' || type == 'decimal') {
          bg = btnNumBg;
          border = btnNumBorder;
          textColor = btnNumText;
        } else if (type == 'action') {
          bg = btnActionBg;
          border = btnActionBorder;
          textColor = btnActionText;
        } else if (type == 'operator') {
          bg = btnOpBg;
          border = btnOpBorder;
          textColor = btnOpText;
        } else {
          // equals
          bg = Colors.transparent;
          border = Colors.transparent;
          textColor = Colors.white;
          gradient = btnEqGradient;
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: gradient != null ? LinearGradient(colors: gradient) : null,
            boxShadow: type == 'equals'
                ? [
                    BoxShadow(
                      color: gradient![0].withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Material(
            color: gradient != null ? Colors.transparent : bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: border,
                width: type == 'equals' ? 0.0 : 1.0,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                _handleKeyPress(keyItem);
              },
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: type == 'equals' ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleKeyPress(Map<String, dynamic> keyItem) {
    final String type = keyItem['type'];
    if (type == 'number') {
      widget.logic.appendNumber(keyItem['text']);
    } else if (type == 'decimal') {
      widget.logic.appendDecimal();
    } else if (type == 'operator') {
      widget.logic.chooseOperator(keyItem['operator']);
    } else if (type == 'equals') {
      widget.logic.calculate();
    } else if (type == 'action') {
      final String act = keyItem['action'];
      if (act == 'clear') {
        widget.logic.clearAll();
      } else if (act == 'backspace') {
        widget.logic.handleBackspace();
      } else if (act == 'percent') {
        widget.logic.handlePercent();
      } else if (act == 'negate') {
        widget.logic.handleNegate();
      }
    }
  }
}
