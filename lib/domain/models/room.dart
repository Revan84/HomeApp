class Room {
  final String id;
  final String name;

  Room({required this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  static Room fromMap(Map<String, dynamic> m) => Room(
        id: (m['id'] ?? '') as String,
        name: (m['name'] ?? '') as String,
      );
}
