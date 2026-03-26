class Room {
  final String id;
  final String name;
  final String groupId;
  final int sortOrder;

  const Room({
    required this.id,
    required this.name,
    required this.groupId,
    required this.sortOrder,
  });

  Room copyWith({String? id, String? name, String? groupId, int? sortOrder}) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      groupId: groupId ?? this.groupId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'groupId': groupId, 'sortOrder': sortOrder};
  }

  /// `fallbackGroupId` is used to migrate old persisted rooms that were stored
  /// before the room-group feature existed.
  static Room fromMap(
    Map<String, dynamic> map, {
    required String fallbackGroupId,
  }) {
    return Room(
      id: (map['id'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      groupId: (map['groupId'] ?? fallbackGroupId) as String,
      sortOrder: (map['sortOrder'] ?? 0) as int,
    );
  }
}
