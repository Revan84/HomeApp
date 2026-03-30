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

  @override
  String get homeWelcomeTitle => 'Welcome';

  @override
  String get homeDefaultAreaGroupName => 'House #1';

  @override
  String homeConnectionSummary(int onlineCount, int offlineCount) {
    return '$onlineCount connected devices · $offlineCount offline';
  }

  @override
  String get favoritesPageTitle => 'Favorites list';

  @override
  String get favoriteRemoveTooltip => 'Remove from favorites';

  @override
  String get favoritesActiveFilterLabel => 'Active: All';

  @override
  String get favoritesFilterTooltip => 'Open favorites filters';

  @override
  String get favoritesAddTooltip => 'Add a favorite';

  @override
  String get roomsSectionTitle => 'Areas';

  @override
  String get roomsPageTitle => 'Rooms list';

  @override
  String get roomsActiveFilterLabel => 'Active: All';

  @override
  String get roomsFilterTooltip => 'Open room filters';

  @override
  String get roomsEmptyState => 'No room groups yet';

  @override
  String get roomsAddGroupTitle => 'Add a group';

  @override
  String get roomsRenameGroupTitle => 'Rename group';

  @override
  String get roomsGroupNameHint => 'Ex. House, Apartment';

  @override
  String get roomsAddRoomTitle => 'Add a room';

  @override
  String get roomsRenameRoomTitle => 'Rename room';

  @override
  String get roomsRoomNameHint => 'Ex. Living room, Kitchen';

  @override
  String get roomsAddGroupTooltip => 'Add a room group';

  @override
  String get roomsAddRoomTooltip => 'Add a room';

  @override
  String get roomsRenameGroupTooltip => 'Rename group';

  @override
  String get roomsDeleteGroupTooltip => 'Delete group';

  @override
  String get roomsDeleteRoomTooltip => 'Delete room';

  @override
  String get roomsDeleteGroupTitle => 'Delete group';

  @override
  String roomsDeleteEmptyGroupMessage(String groupName) {
    return 'Delete the group “$groupName”?';
  }

  @override
  String roomsDeleteGroupWithRoomsMessage(String groupName, int roomCount) {
    return 'Delete the group “$groupName” and its $roomCount room(s)?';
  }

  @override
  String get roomsDeleteRoomTitle => 'Delete room';

  @override
  String roomsDeleteRoomMessage(String roomName) {
    return 'Delete the room “$roomName”?';
  }

  @override
  String get roomsNoGroupForQuickAdd =>
      'You must create a room group before adding a room.';

  @override
  String get roomsFirstGroupLabel => 'First group';

  @override
  String get roomsCreateFirstGroup => 'Create first group';

  @override
  String get roomsTargetGroupLabel => 'Target group';

  @override
  String get roomsTargetGroupRequired => 'Select a room group';

  @override
  String get homeNoActiveRoomGroup => 'No group';

  @override
  String get homeSelectRoomGroupTitle => 'Select a group';

  @override
  String get roomsNoActiveGroupSelected =>
      'No active room group. Select one from the Home page.';

  @override
  String roomsEmptyForGroup(String groupName) {
    return 'No rooms yet for the group “$groupName”.';
  }

  @override
  String get roomsGroupNameFieldLabel => 'Group name';

  @override
  String get validationRoomGroupNameRequired => 'Enter a group name';

  @override
  String get roomsAddRoomSheetTitle => 'Add a room';

  @override
  String get roomsCreateNewRoom => 'Create a new room';

  @override
  String get roomsNoAvailableRooms => 'No other rooms available';

  @override
  String roomsEquipmentCount(int count) {
    return '($count devices)';
  }

  @override
  String get statsAddWidgetTitle => 'Add widget';

  @override
  String get statsAddChart => 'Chart';

  @override
  String get statsAddTable => 'Table';

  @override
  String get statsAddHistory => 'History';

  @override
  String get statsAddKpi => 'KPI';

  @override
  String get statsNoWidgets => 'No widgets yet. Add one to get started.';

  @override
  String get statsConfigTitle => 'Configure widget';

  @override
  String get statsMetricLabel => 'Metric';

  @override
  String get statsTimeRangeLabel => 'Time range';

  @override
  String get statsChartTypeLabel => 'Chart type';

  @override
  String get statsTimeRangeDay => '1 Day';

  @override
  String get statsTimeRangeWeek => '1 Week';

  @override
  String get statsTimeRangeMonth => '1 Month';

  @override
  String get statsTimeRangeYear => '1 Year';

  @override
  String get statsTimeRangeMax => 'Max';

  @override
  String get statsNoData => 'No data';

  @override
  String get statsDeviceLabel => 'Device';

  @override
  String get statsNoDevicesInRoom => 'No devices in this room';

  @override
  String get statsEditWidget => 'Edit widget';

  @override
  String get statsDeleteWidget => 'Delete widget';

  @override
  String get statsDeleteConfirm => 'Delete this widget?';

  @override
  String get statsEmptyHint => 'Tap + to add your first widget';

  @override
  String get tvAddTitle => 'Add a TV';

  @override
  String get tvDefaultName => 'Smart TV';

  @override
  String get tvNameHint => 'e.g. Samsung Living Room';

  @override
  String get tvTestFailed => 'Connection failed';

  @override
  String get tvDeleteConfirm => 'Delete this TV?';

  @override
  String get tvReconnect => 'Reconnect';

  @override
  String get tvStatusConnected => 'Connected';

  @override
  String get tvStatusConnecting => 'Connecting…';

  @override
  String get tvStatusDisconnected => 'Disconnected';

  @override
  String get tvKeyPower => 'Power off';

  @override
  String get tvKeyVolUp => 'Volume +';

  @override
  String get tvKeyVolDown => 'Volume −';

  @override
  String get tvKeyMute => 'Mute';

  @override
  String get tvKeyUp => 'Up';

  @override
  String get tvKeyDown => 'Down';

  @override
  String get tvKeyLeft => 'Left';

  @override
  String get tvKeyRight => 'Right';

  @override
  String get tvKeyBack => 'Back';

  @override
  String get tvKeyHome => 'Home';

  @override
  String get tvKeyMenu => 'Menu';

  @override
  String get tvKeyKeyboard => 'Keyboard';

  @override
  String get tvKeySource => 'Source';

  @override
  String get tvAppsTitle => 'Applications:';

  @override
  String get tvTypeSmartTv => 'Smart TV';

  @override
  String get tvDefaultModel => 'Samsung';

  @override
  String get tvStatusConnectedWifi => 'Connected (wi-fi)';

  @override
  String get tvModelLabel => 'Model';

  @override
  String get tvModelHint => 'e.g. Samsung 55Q80B';

  @override
  String get tvVoiceListening => 'Listening…';

  @override
  String get tvVoiceTap => 'Tap the mic to retry';

  @override
  String get tvVoiceError => 'Microphone unavailable';

  @override
  String get tvKeySettings => 'Settings';

  @override
  String get tvKeyboardHint => 'Type text to send to TV…';

  @override
  String get tvKeyboardSend => 'Send';

  @override
  String get addDeviceTypeTitle => 'Device type';

  @override
  String get deviceTypePlug => 'Connected plug';

  @override
  String get deviceTypeTv => 'Smart TV';

  @override
  String get deviceTypeWled => 'WLED LED Strip';

  @override
  String get wledAddTitle => 'Add WLED device';

  @override
  String get wledDefaultName => 'LED Strip';

  @override
  String get wledNameHint => 'e.g. Living Room LEDs';

  @override
  String get wledModelHint => 'e.g. WLED v0.14';

  @override
  String get wledTestFailed => 'Connection failed';

  @override
  String get wledDeleteConfirm => 'Delete this device?';

  @override
  String get wledBrightnessLabel => 'Brightness';

  @override
  String get wledSpeedLabel => 'Speed';

  @override
  String get wledIntensityLabel => 'Intensity';

  @override
  String get wledColorsTab => 'Colors';

  @override
  String get wledEffectsTab => 'Effects';

  @override
  String get wledScenesLabel => 'Scenes';
}
