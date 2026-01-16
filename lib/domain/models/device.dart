import 'device_capabilities.dart';
import 'enums.dart';

class Device {
  final String id; // UUID
  final String name;
  final DeviceType type;
  final DeviceProtocol protocol;

  /// HTTP: IP/host (ex: 192.168.1.50)
  /// BLE:  MAC (ex: AA:BB:CC:DD:EE:FF)
  /// MQTT: clientId / topic root (selon ton design)
  final String address;

  final String room;

  final DeviceCapabilities capabilities;

  final DateTime? lastSeen;
  final bool isOnline;

  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.protocol,
    required this.address,
    required this.room,
    required this.capabilities,
    this.lastSeen,
    this.isOnline = false,
  });

  Device copyWith({
    String? id,
    String? name,
    DeviceType? type,
    DeviceProtocol? protocol,
    String? address,
    String? room,
    DeviceCapabilities? capabilities,
    DateTime? lastSeen,
    bool? isOnline,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      protocol: protocol ?? this.protocol,
      address: address ?? this.address,
      room: room ?? this.room,
      capabilities: capabilities ?? this.capabilities,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'protocol': protocol.name,
        'address': address,
        'room': room,
        'capabilities': capabilities.toJson(),
        'lastSeen': lastSeen?.toIso8601String(),
        'isOnline': isOnline,
      };

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String,
      name: json['name'] as String,
      type: DeviceType.values.byName(json['type'] as String),
      protocol: DeviceProtocol.values.byName(json['protocol'] as String),
      address: json['address'] as String,
      room: (json['room'] as String?) ?? 'Unknown',
      capabilities: DeviceCapabilities.fromJson(
        (json['capabilities'] as Map).cast<String, dynamic>(),
      ),
      lastSeen: json['lastSeen'] == null
          ? null
          : DateTime.parse(json['lastSeen'] as String),
      isOnline: json['isOnline'] == true,
    );
  }
}
