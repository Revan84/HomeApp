import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Backgrounds ─────────────────────────────────────────────────────────────
  /// Page / scaffold background — darkest layer.
  static const Color bg      = Color(0xFF1D1D1D);
  /// Device card background — warm dark, visually distinct from bg.
  static const Color card    = Color(0xFF1F1A1A);
  /// Elevated surfaces — bottom sheets, drawers, modals.
  static const Color surface = Color(0xFF252525);

  // ── Borders & dividers ──────────────────────────────────────────────────────
  static const Color border = Color(0xFF535353);

  // ── Text ────────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF8F2F2);
  static const Color textSecondary = Color(0xFF969696);

  // ── Brand ───────────────────────────────────────────────────────────────────
  /// Brand primary — colorScheme.primary, active indicators, CTAs.
  static const Color primary = Color(0xFF22BD41);

  // ── Semantic states ─────────────────────────────────────────────────────────
  /// Positive feedback — online status, confirmations.
  static const Color success = Color(0xFF22BD41);
  /// Errors, offline states, destructive actions.
  static const Color danger  = Color(0xFFD76F5D);

  // ── Device type accents ─────────────────────────────────────────────────────
  static const Color plugAccent        = Color(0xFF2334A2);
  static const Color thermometerAccent = Color(0xFFE32B2B);
  static const Color wledAccent        = Color(0xFF693F0E);
  static const Color hygrometerAccent  = Color(0xFF1B61A2);
  static const Color tvAccent          = Color(0xFF480C53);
}
