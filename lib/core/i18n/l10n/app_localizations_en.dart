// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabHome => 'Home';

  @override
  String get tabData => 'Statistics';

  @override
  String get tabEquipments => 'Devices';

  @override
  String get tabAutomation => 'Automations';

  @override
  String get tabProfile => 'Profile';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get refresh => 'Refresh';

  @override
  String get favorites => 'Favorites';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String get addEquipmentTitle => 'Add a device';

  @override
  String get editEquipmentTitle => 'Edit device';

  @override
  String get ipLocalLabel => 'Local IP';

  @override
  String get ipLocalHint => 'e.g. 192.168.1.37';

  @override
  String get nameLabel => 'Name';

  @override
  String get roomLabel => 'Room';

  @override
  String get none => 'None';

  @override
  String get showDataTitle => 'Displayed data';

  @override
  String get showOnOff => 'On/Off';

  @override
  String get showPower => 'Power (W)';

  @override
  String get showEnergy => 'Energy (Wh/kWh)';

  @override
  String get showRssi => 'RSSI / Wi-Fi';

  @override
  String get favorite => 'Favorite';

  @override
  String get test => 'Test';

  @override
  String get testOk => 'Test OK';

  @override
  String get deleteEquipmentConfirmTitle => 'Delete device?';

  @override
  String deleteEquipmentConfirmBody(Object name) {
    return '“$name” will be deleted.';
  }

  @override
  String get close => 'Close';

  @override
  String get nameHintExample => 'e.g. Desk plug';

  @override
  String get channelLabel => 'Channel';

  @override
  String get channelHint => '0';

  @override
  String get typeLabel => 'Type';

  @override
  String get equipmentTypeShellyPlusPlugS => 'Smart plug';

  @override
  String get equipmentTypeShellyPlugS => 'Smart plug (Shelly Plug S)';

  @override
  String get equipmentTypeOther => 'Other (test)';

  @override
  String get validationIpRequired => 'IP required';

  @override
  String get validationIpInvalidFormat => 'Invalid IP format';

  @override
  String get validationIpInvalid => 'Invalid IP';

  @override
  String get validationNumberInvalid => 'Invalid number';

  @override
  String get validationChannelInvalid => 'Invalid channel';

  @override
  String testFailed(Object error) {
    return 'Test failed: $error';
  }

  @override
  String get defaultEquipmentName => 'Device';

  @override
  String get detectedInfoTitle => 'Detected info';

  @override
  String deviceInfoName(Object value) {
    return 'Name: $value';
  }

  @override
  String deviceInfoModel(Object value) {
    return 'Model: $value';
  }

  @override
  String deviceInfoMac(Object value) {
    return 'MAC: $value';
  }

  @override
  String get detailsNetworkTitle => 'Network';

  @override
  String detailsWifiLine(Object value) {
    return 'Wi-Fi: $value';
  }

  @override
  String detailsPhoneIpLine(Object value) {
    return 'Phone IP: $value';
  }

  @override
  String detailsEquipmentIpLine(Object value) {
    return 'Device: $value';
  }

  @override
  String detailsStatusLine(Object value) {
    return 'Status: $value';
  }

  @override
  String get netGrantWifiAccess => 'Allow Wi-Fi access';

  @override
  String get netWifiPermissionRequired =>
      'Permission required to read Wi-Fi (SSID/IP)';

  @override
  String get netWifiPermissionRequiredPrefix => 'Permission required';

  @override
  String get netStatusOnline => 'Online';

  @override
  String get netStatusOffline => 'Offline';

  @override
  String get netStatusNotOnWifi => 'Not on Wi-Fi (or Wi-Fi not detectable)';

  @override
  String get netStatusNotOnWifiPrefix => 'Not on Wi-Fi';

  @override
  String get netStatusWrongWifi => 'Wrong Wi-Fi (different network)';

  @override
  String get netStatusWrongWifiPrefix => 'Wrong Wi-Fi';

  @override
  String get detailsDeviceInfoTitle => 'Device info';

  @override
  String detailsDeviceModelLine(Object value) {
    return 'Model: $value';
  }

  @override
  String detailsDeviceGenLine(Object value) {
    return 'Gen: $value';
  }

  @override
  String detailsDeviceFwLine(Object value) {
    return 'FW: $value';
  }

  @override
  String detailsDeviceMacLine(Object value) {
    return 'MAC: $value';
  }

  @override
  String get detailsLiveDataTitle => 'Live data';

  @override
  String detailsOnOffLine(Object value) {
    return 'On/Off: $value';
  }

  @override
  String detailsPowerLine(Object value) {
    return 'Power: $value';
  }

  @override
  String detailsEnergyLine(Object value) {
    return 'Energy: $value';
  }

  @override
  String detailsRssiLine(Object value) {
    return 'RSSI: $value';
  }

  @override
  String detailsLastUpdatedLine(Object value) {
    return 'Last update: $value';
  }

  @override
  String get valueUnknown => '—';

  @override
  String get valueOn => 'ON';

  @override
  String get valueOff => 'OFF';

  @override
  String get actionTurnOn => 'Turn on';

  @override
  String get actionTurnOff => 'Turn off';

  @override
  String get areas => 'Rooms';

  @override
  String get noRoomsYet => 'No rooms yet.';

  @override
  String get seeAll => 'See all';

  @override
  String get seeLess => 'See less';

  @override
  String get addRoomTitle => 'Add a room';

  @override
  String get roomNameLabel => 'Room name';

  @override
  String get roomNameHint => 'e.g. Living room';

  @override
  String get validationRoomNameRequired => 'Name required';

  @override
  String get noEquipments => 'No devices';

  @override
  String get profileAccountSecurity => 'Account & Security';

  @override
  String get profileRemoteAccess =>
      'Remote access (reverse proxy, connection status)';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileAppearance => 'Appearance';

  @override
  String get profileBackupRestore => 'Backup / Restore configuration';

  @override
  String get profileLogout => 'Logout';

  @override
  String get valueSystemDefault => 'System default';

  @override
  String get profileTitle => 'Profile';

  @override
  String get languageFrench => 'French';

  @override
  String get languageEnglish => 'English';

  @override
  String get detailsConnectionLabel => 'Connection';

  @override
  String get detailsConnectedWifi => 'Connected (Wi-Fi)';

  @override
  String get detailsChartPlaceholder => 'Chart (placeholder)';

  @override
  String detailsUpdatedAt(Object value) {
    return 'Updated: $value';
  }

  @override
  String powerWatts(Object value) {
    return '$value W';
  }

  @override
  String get valueYes => 'Yes';

  @override
  String get valueNo => 'No';

  @override
  String detailsKeyValueLine(Object key, Object value) {
    return '$key: $value';
  }

  @override
  String energyWh(Object value) {
    return '$value Wh';
  }

  @override
  String get detailsHistoryWindow2h => 'Last 2 hours';

  @override
  String get detailsHistoryWindow24h => 'Last 24 hours';

  @override
  String get detailsHistoryWindow7d => 'Last 7 days';

  @override
  String detailsUpdatedAgo(Object ago) {
    return 'Updated $ago ago';
  }

  @override
  String get detailsUpdatedJustNow => 'Updated just now';

  @override
  String get detailsTrendUp => 'Rising';

  @override
  String get detailsTrendDown => 'Falling';

  @override
  String get detailsTrendFlat => 'Stable';

  @override
  String get detailsDeviceModelRightLabel => 'Model';

  @override
  String get detailsEditNameTooltip => 'Edit name';

  @override
  String get detailsEditIpTooltip => 'Edit local IP';

  @override
  String get detailsSelectTypeTooltip => 'Select type';

  @override
  String get detailsToggleFavoriteTooltip => 'Toggle favorite';

  @override
  String get detailsConnectionStatusLabel => 'Network status';

  @override
  String get detailsConnectedWifiShort => 'Connected (Wi-Fi)';

  @override
  String get detailsDisconnectedShort => 'Disconnected';

  @override
  String get detailsRoomDropdownTooltip => 'Select room';

  @override
  String get detailsActionDelete => 'Delete';

  @override
  String get detailsEditNameDialogTitle => 'Edit device name';

  @override
  String get detailsEditNameHint => 'e.g. Plug';

  @override
  String get detailsEditIpDialogTitle => 'Edit local IP';

  @override
  String get detailsEditIpHint => 'e.g. 192.168.1.37';

  @override
  String get detailsRoomUnknown => 'Unknown room';

  @override
  String get detailsDeviceModelUnknown => 'Unknown model';

  @override
  String get detailsChartNoData => 'No data';

  @override
  String get detailsTimelineTickNow => 'Now';

  @override
  String get historyRange1d => '1D';

  @override
  String get historyRange1w => '1W';

  @override
  String get historyRange1m => '1M';

  @override
  String get historyRange1y => '1Y';

  @override
  String get historyRangeMax => 'Max';

  @override
  String get unitWattShort => 'W';

  @override
  String get confirmDeleteEquipment =>
      'Delete this equipment? This action cannot be undone.';

  @override
  String get updatedJustNow => 'Updated just now';

  @override
  String updatedSecondsAgo(int seconds) {
    return 'Updated ${seconds}s ago';
  }

  @override
  String updatedMinutesAgo(int minutes) {
    return 'Updated $minutes min ago';
  }

  @override
  String updatedHoursAgo(int hours) {
    return 'Updated $hours h ago';
  }
}
