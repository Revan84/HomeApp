import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static const String _fontFamily = 'ShareTech';

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.bg,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
        onError: AppColors.textPrimary,
      ),
      textTheme: const TextTheme(
        // Large numbers — KPI tiles, stat counters
        displaySmall: AppTextStyles.kpi,
        // Prominent values — live watts, kWh, temperature
        headlineSmall: AppTextStyles.display,
        // Page-level headings, detail titles
        titleLarge: AppTextStyles.heading,
        // Section headers, sheet titles
        titleMedium: AppTextStyles.sectionTitle,
        // Tile titles, form labels, emphasized text
        bodyLarge: AppTextStyles.bodyStrong,
        // Default readable text — used by Text() widget
        bodyMedium: AppTextStyles.body,
        // Captions, timestamps, meta labels
        bodySmall: AppTextStyles.labelSmall,
        labelSmall: AppTextStyles.labelSmall,
      ).apply(fontFamily: _fontFamily),
      // AppColors.card is the warm-dark base used by device cards.
      // AppColors.surface is reserved for elevated layers (sheets, dialogs).
      cardTheme: const CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dividerColor: AppColors.border,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    );
  }
}
