import 'dart:convert';

/// Storage/transport shape for [TvDevice].
/// Contains only field declarations and Map/JSON conversion.
/// All domain mapping is handled by [TvDeviceMapper].
class TvDeviceDto {
  final String id;
  final String name;
  final String ipAddress;
  final String? roomId;
  final bool isFavorite;
  final String modelName;
  final String source;
  final String? wsToken;

  const TvDeviceDto({
    required this.id,
    required this.name,
    required this.ipAddress,
    this.roomId,
    this.isFavorite = false,
    this.modelName = '',
    this.source = 'HDMI 1',
    this.wsToken,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'ipAddress': ipAddress,
        'roomId': roomId,
        'isFavorite': isFavorite,
        'modelName': modelName,
        'source': source,
        'wsToken': wsToken,
      };

  factory TvDeviceDto.fromMap(Map<String, dynamic> m) => TvDeviceDto(
        id: (m['id'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        ipAddress: (m['ipAddress'] ?? '') as String,
        roomId: m['roomId'] as String?,
        isFavorite: (m['isFavorite'] ?? false) as bool,
        modelName: (m['modelName'] ?? '') as String,
        source: (m['source'] ?? 'HDMI 1') as String,
        wsToken: m['wsToken'] as String?,
      );

  String toJson() => jsonEncode(toMap());

  factory TvDeviceDto.fromJson(String s) =>
      TvDeviceDto.fromMap(jsonDecode(s) as Map<String, dynamic>);
}
