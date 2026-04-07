/// Storage shape for [LivePoint] power-history entries.
/// Contains only field declarations and Map conversion.
/// All domain mapping is handled by [LivePointMapper].
///
/// Storage format: `{'at': millisecondsSinceEpoch, 'powerW': double}`
class LivePointDto {
  final int at;
  final double powerW;

  const LivePointDto({required this.at, required this.powerW});

  Map<String, dynamic> toMap() => {'at': at, 'powerW': powerW};

  /// Returns null when [raw] is not a valid, in-range map entry.
  /// Used for defensive deserialization of potentially corrupted storage.
  static LivePointDto? tryFromMap(Object? raw) {
    if (raw is! Map) return null;
    final at = raw['at'];
    final power = raw['powerW'];
    if (at is! int || at <= 0 || power is! num) return null;
    return LivePointDto(at: at, powerW: power.toDouble());
  }
}
