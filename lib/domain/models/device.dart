import 'device_capabilities.dart';
import 'enums.dart';

class Device {
  final String id;
  final String name;
  final DeviceType type;
  final DeviceProtocol protocol;

  /// HTTP → IP
  /// BLE → MAC
  /// MQTT → topic root / client id
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
      type: DeviceType.values.byName(json['type']),
      protocol: DeviceProtocol.values.byName(json['protocol']),
      address: json['address'] as String,
      room: json['room'] as String,
      capabilities: DeviceCapabilities.fromJson(
        Map<String, dynamic>.from(json['capabilities']),
      ),
      lastSeen: json['lastSeen'] == null
          ? null
          : DateTime.parse(json['lastSeen']),
      isOnline: json['isOnline'] == true,
    );
  }
}
