import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_font_sizes.dart';

/// Semantic typography styles for the app.
///
/// Hierarchy (small → large):
///   labelSmall  11  w400  secondary  — meta labels, timestamps, captions
///   body        13  w400  primary    — default readable text
///   bodyStrong  13  w600  primary    — emphasised body, tile subtitles
///   sectionTitle 16 w700  primary    — section headers, sheet titles
///   heading     18  w700  primary    — page headings, card titles
///   display     20  w700  primary    — prominent values (watts, kWh)
///   kpi         38  w700  primary    — large stat numbers
abstract final class AppTextStyles {
  /// Meta labels, timestamps, captions, unit suffixes.
  static const TextStyle labelSmall = TextStyle(
    fontSize: AppFontSizes.sm,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  /// Default body text — descriptions, list content.
  static const TextStyle body = TextStyle(
    fontSize: AppFontSizes.body,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// Emphasised body — tile titles, form labels, active states.
  static const TextStyle bodyStrong = TextStyle(
    fontSize: AppFontSizes.body,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// Section headers and sheet titles.
  static const TextStyle sectionTitle = TextStyle(
    fontSize: AppFontSizes.sectionTitle,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// Page-level headings, detail page titles.
  static const TextStyle heading = TextStyle(
    fontSize: AppFontSizes.heading,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// Prominent live values — power, energy, temperature readings.
  static const TextStyle display = TextStyle(
    fontSize: AppFontSizes.display,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  /// Large stat numbers — KPI tiles, summary counters.
  static const TextStyle kpi = TextStyle(
    fontSize: AppFontSizes.kpi,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.0,
  );
}
