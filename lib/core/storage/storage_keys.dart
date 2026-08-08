/// All local-storage keys in one place to prevent typos and duplication.
abstract final class StorageKeys {
  static const equipments = 'equipments_v1';
  static const roomGroups = 'room_groups_v1';
  static const rooms = 'rooms_v1';
  static const tvDevices = 'tv_devices_v1';
  static const cobLedRgbDevices = 'cob_led_rgb_devices_v1';
  static const cobLedCctDevices = 'cob_led_cct_devices_v1';
  static const connectedCameraDevices = 'connected_camera_devices_v1';
  static const liveHistory = 'live_history_v1';
  static const statsDashboardPrefix = 'stats_dashboard_';
  static const localePreference = 'app_locale';

  // Today section
  static const kwhPrice = 'today_kwh_price_v1';
  static const todayWidgetConfig = 'today_widget_config_v1';

  // Plug alerts — per-device key
  static String plugAlerts(String equipmentId) => 'plug_alerts_${equipmentId}_v1';

  // Sensor alerts (thermometer / hygrometer) — per-device key
  static String sensorAlerts(String equipmentId) => 'sensor_alerts_${equipmentId}_v1';
}
