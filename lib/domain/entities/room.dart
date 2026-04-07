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
}
