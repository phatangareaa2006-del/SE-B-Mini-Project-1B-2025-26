import 'package:flutter/material.dart';

class AppTheme {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

  static void toggleTheme() {
    if (themeNotifier.value == ThemeMode.light) {
      themeNotifier.value = ThemeMode.dark;
    } else {
      themeNotifier.value = ThemeMode.light;
    }
  }

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getBgColor(BuildContext context) {
    return isDark(context) ? const Color(0xFF0A0E21) : const Color(0xFFF0F2F5);
  }
  
  static Color getCardColor(BuildContext context) {
    return isDark(context) ? Colors.white.withOpacity(0.05) : Colors.white;
  }

  static Color getCardBorderColor(BuildContext context) {
    return isDark(context) ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);
  }

  static Color getTextColor(BuildContext context) {
    return isDark(context) ? Colors.white : Colors.black87;
  }

  static Color getSubTextColor(BuildContext context) {
    return isDark(context) ? Colors.white70 : Colors.black54;
  }

  static Color getPrimaryColor() {
    return Colors.blueAccent;
  }
}
