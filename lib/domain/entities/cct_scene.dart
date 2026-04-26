/// A locally-stored CCT preset: a named combination of colour temperature
/// and brightness that can be applied instantly to a CCT device.
class CctScene {
  final String id;
  final String name;
  final int colorTempK; // 2700–6500
  final int brightness; // 0–255

  const CctScene({
    required this.id,
    required this.name,
    required this.colorTempK,
    required this.brightness,
  });

  CctScene copyWith({
    String? id,
    String? name,
    int? colorTempK,
    int? brightness,
  }) =>
      CctScene(
        id: id ?? this.id,
        name: name ?? this.name,
        colorTempK: colorTempK ?? this.colorTempK,
        brightness: brightness ?? this.brightness,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'colorTempK': colorTempK,
        'brightness': brightness,
      };

  factory CctScene.fromMap(Map<String, dynamic> map) => CctScene(
        id: map['id'] as String,
        name: map['name'] as String,
        colorTempK: map['colorTempK'] as int,
        brightness: map['brightness'] as int,
      );
}
