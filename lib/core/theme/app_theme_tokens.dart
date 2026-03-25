import 'package:flutter/material.dart';

class AppThemeTokens {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surface(BuildContext context) => Theme.of(context).cardColor;

  static Color elevatedSurface(BuildContext context) => isDark(context)
      ? const Color(0xFF182335)
      : Colors.white;

  static Color mutedSurface(BuildContext context) => isDark(context)
      ? const Color(0xFF111C2D)
      : const Color(0xFFF8FAFF);

  static Color outline(BuildContext context) => Theme.of(context).dividerColor;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.color ??
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);

  static Color pageBackground(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color softAccent(BuildContext context, Color color) => color.withValues(
    alpha: isDark(context) ? 0.18 : 0.10,
  );

  static List<BoxShadow> cardShadow(BuildContext context) => isDark(context)
      ? const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ]
      : const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ];
}
