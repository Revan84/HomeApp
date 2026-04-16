/// Reusable typography scale for the app.
///
/// Scale:
///   xs    10  – captions, micro-labels
///   sm    11  – small labels, timestamps
///   body  13  – default readable text
///   md    14  – medium UI text
///   lg    15  – slightly larger body
///   sectionTitle  16  – section headers, sheet titles
///   heading       18  – page headings, detail titles
///   display       20  – prominent live values (watts, temperature…)
abstract final class AppFontSizes {
  // ── General scale ──────────────────────────────────────────────────────────
  static const double xs           = 10;
  static const double sm           = 11;
  static const double body         = 13;
  static const double md           = 14;
  static const double lg           = 15;
  static const double sectionTitle = 16;
  static const double heading      = 18;
  static const double display      = 20;

  // ── Component-specific ─────────────────────────────────────────────────────
  // Not part of the general scale.
  // Move to the relevant widget or a dedicated constant once AppTextStyles
  // is updated to inline this value.
  static const double kpi = 38;
}
