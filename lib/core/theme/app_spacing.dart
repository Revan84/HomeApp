import 'package:flutter/material.dart';

/// Spacing scale — single naming convention throughout.
///
/// Base  xxs  2   xs  4   sm  6   md  8
/// Large  lg 10   xl 12  x2l 14  x3l 16  x4l 18  x5l 20  x6l 24  x8l 32
///
/// Rename map from previous names:
///   md2 → lg   |  lg  → xl  |  lg2 → x2l  |  xl  → x3l
///   xl2 → x4l  |  xxl → x5l |  x3l → x6l  |  x4l → x8l
abstract final class AppSpacing {
  // ── raw scale ──────────────────────────────────────────────────────────────
  static const double xxs = 2;
  static const double xs  = 4;
  static const double sm  = 6;
  static const double md  = 8;
  static const double lg  = 10;
  static const double xl  = 12;
  static const double x2l = 14;
  static const double x3l = 16;
  static const double x4l = 18;
  static const double x5l = 20;
  static const double x6l = 24;
  static const double x8l = 32;

  // ── pre-built EdgeInsets ───────────────────────────────────────────────────
  /// Horizontal padding for full-width content blocks (16).
  static const EdgeInsets pageH =
      EdgeInsets.symmetric(horizontal: x3l);

  /// Standard padding inside cards (16).
  static const EdgeInsets cardPadding = EdgeInsets.all(x3l);

  /// Compact card padding (12).
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(xl);

  /// Standard bottom-sheet content padding (l:16 t:12 r:16 b:16).
  static const EdgeInsets sheetPadding =
      EdgeInsets.fromLTRB(x3l, xl, x3l, x3l);

  /// Section header row padding (l:16 t:0 r:16 b:6).
  static const EdgeInsets sectionHeader =
      EdgeInsets.fromLTRB(x3l, 0, x3l, sm);

  // ── vertical gap widgets ───────────────────────────────────────────────────
  static const Widget gapXxs = SizedBox(height: xxs);
  static const Widget gapXs  = SizedBox(height: xs);
  static const Widget gapSm  = SizedBox(height: sm);
  static const Widget gapMd  = SizedBox(height: md);
  static const Widget gapLg  = SizedBox(height: lg);
  static const Widget gapXl  = SizedBox(height: xl);
  static const Widget gapX2l = SizedBox(height: x2l);
  static const Widget gapX3l = SizedBox(height: x3l);
  static const Widget gapX4l = SizedBox(height: x4l);
  static const Widget gapX5l = SizedBox(height: x5l);
  static const Widget gapX6l = SizedBox(height: x6l);
  static const Widget gapX8l = SizedBox(height: x8l);

  // ── horizontal gap widgets ─────────────────────────────────────────────────
  static const Widget gapHXxs = SizedBox(width: xxs);
  static const Widget gapHXs  = SizedBox(width: xs);
  static const Widget gapHSm  = SizedBox(width: sm);
  static const Widget gapHMd  = SizedBox(width: md);
  static const Widget gapHLg  = SizedBox(width: lg);
  static const Widget gapHXl  = SizedBox(width: xl);
  static const Widget gapHX2l = SizedBox(width: x2l);
  static const Widget gapHX3l = SizedBox(width: x3l);
  static const Widget gapHX4l = SizedBox(width: x4l);
  static const Widget gapHX5l = SizedBox(width: x5l);
  static const Widget gapHX6l = SizedBox(width: x6l);
  static const Widget gapHX8l = SizedBox(width: x8l);
}
