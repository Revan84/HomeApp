import 'package:flutter/material.dart';

/// Border-radius scale — same naming convention as AppSpacing.
///
/// Base  xs  2   sm  6   md  8   lg 10   xl 12
/// Large x2l 16  x3l 20  x4l 25  pill 999
///
/// Rename map from previous names:
///   xl2 → x2l  |  xxl → x3l  |  x3l → x4l
abstract final class AppRadius {
  // ── raw scale ──────────────────────────────────────────────────────────────
  static const double xs   = 2;
  static const double sm   = 6;
  static const double md   = 8;
  static const double lg   = 10;
  static const double xl   = 12;
  static const double x2l  = 16;
  static const double x3l  = 20;
  static const double x4l  = 25;
  static const double pill = 999;

  // ── semantic aliases ───────────────────────────────────────────────────────
  /// Device cards (plug, TV, WLED, thermometer) — 12.
  static const double card   = xl;
  /// Pill-style list tiles (equipments, profile, favorites) — 25.
  static const double tile   = x4l;
  /// Horizontal filter chips — 6.
  static const double chip   = sm;
  /// Bottom-sheet top-corner rounding — 20.
  static const double sheet  = x3l;
  /// Action buttons — 25.
  static const double button = x4l;

  // ── pre-built BorderRadius ─────────────────────────────────────────────────
  static const BorderRadius xsBR   = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smBR   = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdBR   = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgBR   = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlBR   = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius x2lBR  = BorderRadius.all(Radius.circular(x2l));
  static const BorderRadius x3lBR  = BorderRadius.all(Radius.circular(x3l));
  static const BorderRadius x4lBR  = BorderRadius.all(Radius.circular(x4l));
  static const BorderRadius pillBR = BorderRadius.all(Radius.circular(pill));

  // ── semantic pre-built ─────────────────────────────────────────────────────
  static const BorderRadius cardBR   = xlBR;
  static const BorderRadius tileBR   = x4lBR;
  static const BorderRadius chipBR   = smBR;
  static const BorderRadius buttonBR = x4lBR;

  /// Top-only rounding for bottom sheets and modals.
  static const BorderRadius sheetTopBR =
      BorderRadius.vertical(top: Radius.circular(sheet));
}
