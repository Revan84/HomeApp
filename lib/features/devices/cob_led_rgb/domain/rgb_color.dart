/// Domain-level RGB color representation.
///
/// Avoids depending on Flutter's `Color` in lower layers.
class RgbColor {
  final int red;
  final int green;
  final int blue;

  const RgbColor({required this.red, required this.green, required this.blue});

  /// Creates from 0.0–1.0 floating-point channels (as used by Flutter's Color API).
  factory RgbColor.fromFloats(double r, double g, double b) => RgbColor(
        red: (r * 255).round().clamp(0, 255),
        green: (g * 255).round().clamp(0, 255),
        blue: (b * 255).round().clamp(0, 255),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RgbColor &&
          other.red == red &&
          other.green == green &&
          other.blue == blue;

  @override
  int get hashCode => Object.hash(red, green, blue);

  /// Hex string without alpha, e.g. "#FF00AA".
  String get hex =>
      '#${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}'.toUpperCase();

  @override
  String toString() => 'RgbColor($red, $green, $blue)';
}
