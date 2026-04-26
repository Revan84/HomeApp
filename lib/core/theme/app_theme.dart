import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_font_sizes.dart';
import 'app_radius.dart';
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

      // ── Dialogs ──────────────────────────────────────────────────────────────
      // AlertDialog, SimpleDialog, Dialog all inherit from dialogTheme.
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.x3l),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: AppFontSizes.sectionTitle,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: AppFontSizes.body,
          color: AppColors.textSecondary,
        ),
      ),

      // ── Buttons ───────────────────────────────────────────────────────────────
      // TextButton — used as Cancel / secondary action in dialogs.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: AppFontSizes.body,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
      // FilledButton — used as primary confirm action in dialogs.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.bg,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: AppFontSizes.body,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
      // ElevatedButton — fallback for legacy button usage.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: AppFontSizes.body,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),

      // ── Input fields ─────────────────────────────────────────────────────────
      // TextField inside dialogs inherits this.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bg,
        hintStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: AppFontSizes.body,
          color: AppColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),

      // ── Snack bar ─────────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: AppFontSizes.body,
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Popup menu (3-dot menus) ──────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: AppFontSizes.body,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
