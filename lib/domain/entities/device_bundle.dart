import 'cob_led_cct_device.dart';
import 'cob_led_rgb_device.dart';
import 'equipment.dart';
import 'tv_device.dart';

/// Groups the four heterogeneous device lists that travel together throughout
/// the home feature (home tab, favorites page, rooms page).
///
/// Avoids repeating the same four-parameter signature everywhere a new device
/// type is added.
class DeviceBundle {
  final List<Equipment> equipments;
  final List<TvDevice> tvDevices;
  final List<CobLedRgbDevice> cobLedRgbDevices;
  final List<CobLedCctDevice> cobLedCctDevices;

  const DeviceBundle({
    required this.equipments,
    required this.tvDevices,
    required this.cobLedRgbDevices,
    required this.cobLedCctDevices,
  });

  static const empty = DeviceBundle(
    equipments: [],
    tvDevices: [],
    cobLedRgbDevices: [],
    cobLedCctDevices: [],
  );

  bool get isEmpty =>
      equipments.isEmpty &&
      tvDevices.isEmpty &&
      cobLedRgbDevices.isEmpty &&
      cobLedCctDevices.isEmpty;

  bool get isNotEmpty => !isEmpty;
}
