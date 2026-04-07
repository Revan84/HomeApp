/// Storage shape for [RoomGroup].
/// Contains only field declarations and Map conversion.
/// All domain mapping is handled by [RoomGroupMapper].
class RoomGroupDto {
  final String id;
  final String name;
  final int sortOrder;

  const RoomGroupDto({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'sortOrder': sortOrder,
      };

  factory RoomGroupDto.fromMap(Map<String, dynamic> map) => RoomGroupDto(
        id: (map['id'] ?? '') as String,
        name: (map['name'] ?? '') as String,
        sortOrder: (map['sortOrder'] ?? 0) as int,
      );
}
