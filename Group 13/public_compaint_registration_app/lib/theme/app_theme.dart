import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const Color navyDark = Color(0xFF0F2548);
  static const Color navyMid = Color(0xFF162040);
  static const Color navyPrimary = Color(0xFF1A3C6E);
  static const Color gold = Color(0xFFE8A020);
  static const Color goldLight = Color(0xFFF0C040);

  // Background
  static const Color bgGray = Color(0xFFF0F2F5);
  static const Color white = Colors.white;
  static const Color cardBg = Color(0xFFFAFBFD);

  // Status colors
  static const Color pendingBg = Color(0xFFFFF3CD);
  static const Color pendingText = Color(0xFF856404);
  static const Color pendingDot = Color(0xFFFFC107);

  static const Color progressBg = Color(0xFFCCE5FF);
  static const Color progressText = Color(0xFF004085);
  static const Color progressDot = Color(0xFF0D6EFD);

  static const Color resolvedBg = Color(0xFFD4EDDA);
  static const Color resolvedText = Color(0xFF155724);
  static const Color resolvedDot = Color(0xFF28A745);

  static const Color rejectedBg = Color(0xFFF8D7DA);
  static const Color rejectedText = Color(0xFF721C24);
  static const Color rejectedDot = Color(0xFFDC3545);

  // Category colors
  static const Color roads = Color(0xFFE67E22);
  static const Color water = Color(0xFF2980B9);
  static const Color electricity = Color(0xFFF1C40F);
  static const Color sanitation = Color(0xFF27AE60);
  static const Color parks = Color(0xFF16A085);
  static const Color noise = Color(0xFF8E44AD);
  static const Color drainage = Color(0xFF2C3E50);
  static const Color other = Color(0xFF7F8C8D);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: navyPrimary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: bgGray,
        fontFamily: 'Georgia',
      );
}

class StatusConfig {
  final Color bg;
  final Color text;
  final Color dot;
  const StatusConfig({required this.bg, required this.text, required this.dot});
}

final Map<String, StatusConfig> statusColors = {
  'Pending': StatusConfig(
      bg: AppTheme.pendingBg,
      text: AppTheme.pendingText,
      dot: AppTheme.pendingDot),
  'In Progress': StatusConfig(
      bg: AppTheme.progressBg,
      text: AppTheme.progressText,
      dot: AppTheme.progressDot),
  'Resolved': StatusConfig(
      bg: AppTheme.resolvedBg,
      text: AppTheme.resolvedText,
      dot: AppTheme.resolvedDot),
  'Rejected': StatusConfig(
      bg: AppTheme.rejectedBg,
      text: AppTheme.rejectedText,
      dot: AppTheme.rejectedDot),
};
