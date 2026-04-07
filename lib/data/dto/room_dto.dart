/// Storage shape for [Room].
/// Contains only field declarations and Map conversion.
/// All domain mapping is handled by [RoomMapper].
class RoomDto {
  final String id;
  final String name;
  final String groupId;
  final int sortOrder;

  const RoomDto({
    required this.id,
    required this.name,
    required this.groupId,
    required this.sortOrder,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'groupId': groupId,
        'sortOrder': sortOrder,
      };

  factory RoomDto.fromMap(
    Map<String, dynamic> map, {
    required String fallbackGroupId,
  }) =>
      RoomDto(
        id: (map['id'] ?? '') as String,
        name: (map['name'] ?? '') as String,
        groupId: (map['groupId'] ?? fallbackGroupId) as String,
        sortOrder: (map['sortOrder'] ?? 0) as int,
      );
}
