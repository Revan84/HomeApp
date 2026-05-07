/// A locally-stored CCT preset: a named snapshot of all WLED controls that
/// can be applied instantly to a CCT device.
class CctScene {
  final String id;
  final String name;
  final int colorTempK;   // 2700–6500 K
  final int brightness;   // 0–255
  final int effectId;     // WLED effect index (0 = Static)
  final int effectSpeed;  // 0–255
  final bool audioReactive;

  const CctScene({
    required this.id,
    required this.name,
    required this.colorTempK,
    required this.brightness,
    this.effectId = 0,
    this.effectSpeed = 128,
    this.audioReactive = false,
  });

  CctScene copyWith({
    String? id,
    String? name,
    int? colorTempK,
    int? brightness,
    int? effectId,
    int? effectSpeed,
    bool? audioReactive,
  }) =>
      CctScene(
        id: id ?? this.id,
        name: name ?? this.name,
        colorTempK: colorTempK ?? this.colorTempK,
        brightness: brightness ?? this.brightness,
        effectId: effectId ?? this.effectId,
        effectSpeed: effectSpeed ?? this.effectSpeed,
        audioReactive: audioReactive ?? this.audioReactive,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'colorTempK': colorTempK,
        'brightness': brightness,
        'effectId': effectId,
        'effectSpeed': effectSpeed,
        'audioReactive': audioReactive,
      };

  factory CctScene.fromMap(Map<String, dynamic> map) => CctScene(
        id: map['id'] as String,
        name: map['name'] as String,
        colorTempK: map['colorTempK'] as int,
        brightness: map['brightness'] as int,
        // Defaults handle scenes saved before these fields existed.
        effectId: (map['effectId'] as int?) ?? 0,
        effectSpeed: (map['effectSpeed'] as int?) ?? 128,
        audioReactive: (map['audioReactive'] as bool?) ?? false,
      );
}
