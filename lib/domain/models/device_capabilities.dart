class DeviceCapabilities {
  final bool onOff;
  final bool temperature;
  final bool humidity;
  final bool power; // mesure conso

  const DeviceCapabilities({
    this.onOff = false,
    this.temperature = false,
    this.humidity = false,
    this.power = false,
  });

  Map<String, dynamic> toJson() => {
        'onOff': onOff,
        'temperature': temperature,
        'humidity': humidity,
        'power': power,
      };

  factory DeviceCapabilities.fromJson(Map<String, dynamic> json) {
    return DeviceCapabilities(
      onOff: json['onOff'] == true,
      temperature: json['temperature'] == true,
      humidity: json['humidity'] == true,
      power: json['power'] == true,
    );
  }
}
