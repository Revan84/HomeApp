class RoomGroup {
  final String id;
  final String name;
  final int sortOrder;

  const RoomGroup({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  RoomGroup copyWith({String? id, String? name, int? sortOrder}) {
    return RoomGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'sortOrder': sortOrder};
  }

  static RoomGroup fromMap(Map<String, dynamic> map) {
    return RoomGroup(
      id: (map['id'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      sortOrder: (map['sortOrder'] ?? 0) as int,
    );
  }
}
