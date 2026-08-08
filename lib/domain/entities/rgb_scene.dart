/// A locally-stored RGB preset: a named snapshot of color, brightness, and
/// effect settings that can be applied instantly to a WLED RGB device.
class RgbScene {
  final String id;
  final String name;
  final int colorRed;        // 0–255
  final int colorGreen;      // 0–255
  final int colorBlue;       // 0–255
  final int brightness;      // 0–255
  final int effectId;        // WLED effect index (0 = Static)
  final int effectSpeed;     // 0–255
  final int effectIntensity; // 0–255

  const RgbScene({
    required this.id,
    required this.name,
    required this.colorRed,
    required this.colorGreen,
    required this.colorBlue,
    required this.brightness,
    this.effectId = 0,
    this.effectSpeed = 128,
    this.effectIntensity = 128,
  });

  RgbScene copyWith({
    String? id,
    String? name,
    int? colorRed,
    int? colorGreen,
    int? colorBlue,
    int? brightness,
    int? effectId,
    int? effectSpeed,
    int? effectIntensity,
  }) =>
      RgbScene(
        id: id ?? this.id,
        name: name ?? this.name,
        colorRed: colorRed ?? this.colorRed,
        colorGreen: colorGreen ?? this.colorGreen,
        colorBlue: colorBlue ?? this.colorBlue,
        brightness: brightness ?? this.brightness,
        effectId: effectId ?? this.effectId,
        effectSpeed: effectSpeed ?? this.effectSpeed,
        effectIntensity: effectIntensity ?? this.effectIntensity,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'colorRed': colorRed,
        'colorGreen': colorGreen,
        'colorBlue': colorBlue,
        'brightness': brightness,
        'effectId': effectId,
        'effectSpeed': effectSpeed,
        'effectIntensity': effectIntensity,
      };

  factory RgbScene.fromMap(Map<String, dynamic> m) => RgbScene(
        id: m['id'] as String,
        name: m['name'] as String,
        colorRed: (m['colorRed'] as int?) ?? 255,
        colorGreen: (m['colorGreen'] as int?) ?? 255,
        colorBlue: (m['colorBlue'] as int?) ?? 255,
        brightness: (m['brightness'] as int?) ?? 128,
        effectId: (m['effectId'] as int?) ?? 0,
        effectSpeed: (m['effectSpeed'] as int?) ?? 128,
        effectIntensity: (m['effectIntensity'] as int?) ?? 128,
      );
}
