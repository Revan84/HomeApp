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
  String get validationIpRequired => 'IP address is required';

  @override
  String get validationIpInvalidFormat => 'Invalid format (e.g. 192.168.1.37)';

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
  String get netStatusOnline => 'Online';

  @override
  String get netStatusOffline => 'Offline';

  @override
  String get valueUnknown => '—';

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
  String get languageFrench => 'French';

  @override
  String get languageEnglish => 'English';

  @override
  String get detailsConnectedWifi => 'Connected (Wi-Fi)';

  @override
  String powerWatts(Object value) {
    return '$value W';
  }

  @override
  String get valueYes => 'Yes';

  @override
  String get valueNo => 'No';

  @override
  String energyWh(Object value) {
    return '$value Wh';
  }

  @override
  String get detailsEditNameTooltip => 'Edit name';

  @override
  String get detailsEditIpTooltip => 'Edit local IP';

  @override
  String get detailsSelectTypeTooltip => 'Select type';

  @override
  String get detailsRoomDropdownTooltip => 'Select room';

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
  String homeConnectionSummary(int onlineCount, int offlineCount) {
    return '$onlineCount connected devices · $offlineCount offline';
  }

  @override
  String get favoritesPageTitle => 'Favorites list';

  @override
  String get favoritesSearchHint => 'Search devices...';

  @override
  String get roomsSectionTitle => 'Areas';

  @override
  String get roomsPageTitle => 'Rooms list';

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
  String get roomsSearchHint => 'Search rooms...';

  @override
  String get roomDetailRemoveTooltip => 'Remove from room';

  @override
  String get roomDetailUnlinkTitle => 'Remove from room?';

  @override
  String roomDetailUnlinkMessage(String deviceName) {
    return '\'$deviceName\' will be removed from this room.';
  }

  @override
  String get roomDetailUnlinkConfirm => 'Remove';

  @override
  String get roomsGroupNameFieldLabel => 'Group name';

  @override
  String get validationRoomGroupNameRequired => 'Enter a group name';

  @override
  String get roomsCreateNewRoom => 'Create a new room';

  @override
  String get roomsNoAvailableRooms => 'No other rooms available';

  @override
  String roomsEquipmentCount(int count) {
    return '($count devices)';
  }

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
  String get statsDeviceLabel => 'Device';

  @override
  String get statsNoDevicesInRoom => 'No devices in this room';

  @override
  String get statsEditWidget => 'Edit widget';

  @override
  String get statsDeleteConfirm => 'Delete this widget?';

  @override
  String get statsEmptyHint => 'Tap + to add your first widget';

  @override
  String get statsNoCompatibleDevice =>
      'No compatible device for this widget type';

  @override
  String get statsDeviceTypeSmartPlug => 'Smart Plug';

  @override
  String get statsDeviceTypeGeneric => 'Device';

  @override
  String statsWidgetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count widgets',
      one: '1 widget',
    );
    return '$_temp0';
  }

  @override
  String get tvAddTitle => 'Add a TV';

  @override
  String get tvDefaultName => 'Smart TV';

  @override
  String get tvNameHint => 'e.g. Samsung Living Room';

  @override
  String get tvReconnect => 'Reconnect';

  @override
  String get tvStatusConnecting => 'Connecting…';

  @override
  String get tvStatusDisconnected => 'Disconnected';

  @override
  String get tvKeyBack => 'Back';

  @override
  String get tvKeyHome => 'Home';

  @override
  String get tvKeyKeyboard => 'Keyboard';

  @override
  String get tvKeySource => 'Source';

  @override
  String get tvStatusConnectedWifi => 'Connected (wi-fi)';

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
  String get tvKeyboardSend => 'Send';

  @override
  String get deviceTypePlug => 'Connected plug';

  @override
  String get deviceTypeTv => 'Smart TV';

  @override
  String get cobLedRgbAddTitle => 'Add WLED device';

  @override
  String get cobLedRgbDefaultName => 'LED Strip';

  @override
  String get cobLedRgbNameHint => 'e.g. Living Room LEDs';

  @override
  String get cobLedRgbModelHint => 'e.g. WLED v0.14';

  @override
  String get smartPlugSubtitle => 'Smart Plug';

  @override
  String get smartPlugKpiUnit => 'W';

  @override
  String smartPlugCostPerHour(String cost) {
    return '≈ $cost €/h';
  }

  @override
  String smartPlugCostToday(String cost) {
    return '≈ $cost€ today';
  }

  @override
  String smartPlugKwhCumulated(String kwh) {
    return '$kwh kWh cumulated';
  }

  @override
  String get smartPlugSectionConsumption => 'Consumption';

  @override
  String get smartPlugSectionTimeline => 'Timeline';

  @override
  String get smartPlugSectionAlerts => 'Alerts';

  @override
  String get smartPlugEditKwhPriceTitle => 'Electricity price';

  @override
  String get smartPlugAlertConditionWatts => 'Power (W)';

  @override
  String get smartPlugAlertConditionDailyCost => 'Daily cost (€)';

  @override
  String get smartPlugAlertThresholdHintWatts => 'e.g. 2500';

  @override
  String get smartPlugAlertThresholdHintCost => 'e.g. 1.50';

  @override
  String get smartPlugAlertNotifRequired =>
      'Select at least one notification type';

  @override
  String get tvSubtitle => 'Remote Control';

  @override
  String get tvSourceActive => 'Source active';

  @override
  String get tvSectionRemote => 'Remote';

  @override
  String get tvSectionApplications => 'Applications';

  @override
  String get detailSectionLive => 'LIVE';

  @override
  String get detailSectionHistoric => 'HISTORIC';

  @override
  String get detailSectionInformations => 'INFORMATIONS';

  @override
  String get detailSectionAlerts => 'ALERTS';

  @override
  String get detailSectionTemperature => 'TEMPERATURE';

  @override
  String get detailStatMin => 'MIN';

  @override
  String get detailStatMax => 'MAX';

  @override
  String get detailStatAvgWeek => 'Average Week';

  @override
  String get detailStatAvgMonth => 'Average Month';

  @override
  String get detailStatAmplitude => 'Amplitude';

  @override
  String get detailStatToday => 'Today';

  @override
  String get detailInfoStatus => 'Status';

  @override
  String get detailTrendRising => 'Trend: rising';

  @override
  String get detailTrendFalling => 'Trend: falling';

  @override
  String get detailTrendUpward => 'Trend: upward';

  @override
  String get detailTrendDownward => 'Trend: downward';

  @override
  String get thermometerTypeLabel => 'Thermometer';

  @override
  String get hygrometerTypeLabel => 'Hygrometer';

  @override
  String get cobLedRgbTypeLabel => 'COB LED RGB';

  @override
  String get cobLedCctTypeLabel => 'COB LED CCT';

  @override
  String get deviceOfflineBanner => 'Device is offline';

  @override
  String get deviceNotFound => 'Device not found';

  @override
  String get cobLedSectionLuminosity => 'LUMINOSITY';

  @override
  String get cobLedSectionWledControls => 'WLED CONTROLS';

  @override
  String get cobLedRgbSectionColor => 'COLOR';

  @override
  String get cobLedHexCodeLabel => 'Hexa Code';

  @override
  String get cobLedEffectsUnavailable => 'Effects unavailable (device offline)';

  @override
  String get cobLedRgbNoScenes => 'No templates yet';

  @override
  String get cobLedRgbDeleteSceneTitle => 'Delete template?';

  @override
  String cobLedRgbDeleteSceneBody(Object name) {
    return '\"$name\" will be deleted.';
  }

  @override
  String get cobLedCctSectionColourTemp => 'COLOUR TEMPERATURE';

  @override
  String get cobLedCctSaveAsTemplateTitle => 'Save as template';

  @override
  String get cobLedCctTemplateNameHint => 'Template name';

  @override
  String get cobLedCctDeviceHint => 'e.g. ESP32 CCT Controller';

  @override
  String get sensorAlertConditionAbove => 'Above';

  @override
  String get sensorAlertConditionBelow => 'Below';

  @override
  String get hygrometerComfortRangeLabel => 'Comfort range: 40% – 60%';

  @override
  String get hygrometerStatComfort => 'Comfort';

  @override
  String get homeSectionToday => 'Today';

  @override
  String get homeTodayConsumptionLabel => 'Consumption';

  @override
  String get homeTodayAvgTempLabel => 'Average temp.';

  @override
  String get homeTodayHumidityLabel => 'Humidity';

  @override
  String get equipmentsFilterAllTypes => 'All types';

  @override
  String equipmentsRoomAll(int count) {
    return 'All Rooms ($count)';
  }

  @override
  String equipmentsRoomItem(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get equipmentsSearchHint => 'Search devices...';

  @override
  String areasAllRooms(int count) {
    return 'All Rooms ($count)';
  }

  @override
  String areasRoomItem(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get areasNoRooms => 'No rooms yet.';

  @override
  String get areasNoDevices => 'No devices in this room.';

  @override
  String get deviceStatusOn => 'ON';

  @override
  String get deviceStatusOff => 'OFF';

  @override
  String colorCopiedSnack(String hex) {
    return '$hex copied';
  }

  @override
  String get cobLedEffectLabel => 'Effect';

  @override
  String get cobLedSpeedLabel => 'Speed';

  @override
  String get cobLedIntensityLabel => 'Intensity';

  @override
  String get cobLedAudioReactive => 'Audio Reactive';

  @override
  String get cobLedAudioReactiveHint => 'React to microphone input';

  @override
  String get cobLedLoadingEffects => 'Loading effects…';

  @override
  String get cobLedNoPresets => 'No presets found on device.';

  @override
  String get cobLedSectionTemplates => 'TEMPLATES';

  @override
  String get cobLedSectionActiveScene => 'ACTIVE SCENE';

  @override
  String get cobLedNoActiveScene => 'No active scene';

  @override
  String get cobLedPresetActive => 'Active';

  @override
  String get cobLedPresetApply => 'Apply';

  @override
  String get addDeviceTitle => 'Add a device';

  @override
  String get addDeviceTypeLabel => 'Device type';

  @override
  String get addDeviceTypeHint => 'Select a type';

  @override
  String get addDeviceNameLabel => 'Device Name';

  @override
  String get addDeviceModelOptionalLabel => 'Model (optional)';

  @override
  String get addDeviceConnectedCheck => 'Connected ✓';

  @override
  String get cobLedCctAddTitle => 'Add CCT LED Light';

  @override
  String get cobLedCctAddDeviceError =>
      'Couldn\'t add the LED controller. Check the IP and try again.';

  @override
  String get cctLabelWarmWhite => 'Warm white';

  @override
  String get cctLabelNeutralWhite => 'Neutral white';

  @override
  String get cctLabelCoolWhite => 'Cool white';

  @override
  String get validationNameRequired => 'Name required';

  @override
  String connectionFailedDetail(String error) {
    return 'Connection failed: $error';
  }

  @override
  String get noData => 'No data';

  @override
  String get cobLedCctTemplatesTitle => 'Templates';

  @override
  String get cobLedCctNoTemplates =>
      'No templates yet. Save a scene to reuse it later.';

  @override
  String get cobLedCctTemplateActiveBadge => 'Active';

  @override
  String get cobLedCctSpdSuffix => 'spd';

  @override
  String get cobLedCctWarm => 'Warm';

  @override
  String get cobLedCctCold => 'Cold';

  @override
  String get cobLedCctNoActiveTemplate => 'No active template';

  @override
  String get cobLedCctSceneActive => 'Scene active';

  @override
  String get cobLedCctUpdateTemplateTitle => 'Update template';

  @override
  String get cobLedCctDeleteSceneTitle => 'Delete template?';

  @override
  String cobLedCctDeleteSceneBody(String name) {
    return '\"$name\" will be permanently removed.';
  }

  @override
  String get deviceInfoLocalIp => 'Local IP';

  @override
  String get deviceInfoModelLabel => 'Model';

  @override
  String get deviceInfoConnection => 'Connection';

  @override
  String get deviceConnectionWifi => 'Wi-Fi';

  @override
  String get deviceMenuDelete => 'Delete';

  @override
  String get deviceMenuRefresh => 'Refresh';

  @override
  String get deviceLastKnownValues => 'Last known values';

  @override
  String get alertNoneConfigured => 'No threshold configured';

  @override
  String get alertSheetAddTitle => 'Add Alert';

  @override
  String get alertConditionLabel => 'Alert type';

  @override
  String get alertThresholdLabel => 'Threshold';

  @override
  String get alertNotificationsLabel => 'Notifications';

  @override
  String get alertNotifPush => 'Push';

  @override
  String get alertNotifBanner => 'In-app banner';

  @override
  String get deviceMenuEdit => 'Edit';

  @override
  String get deviceSectionInformations => 'Informations';

  @override
  String get deviceTestFailed => 'Connection failed';

  @override
  String get fabScanOnWifiComingSoon => 'Wi-Fi scan coming soon';

  @override
  String get connectedCameraTypeLabel => 'IP Camera';

  @override
  String get connectedCameraAddTitle => 'Add IP Camera';

  @override
  String get connectedCameraDeviceHint => 'e.g. HomeCam 3';

  @override
  String get connectedCameraAddDeviceError =>
      'Couldn\'t add the camera. Check the IP and try again.';

  @override
  String get connectedCameraOffline => 'Offline';

  @override
  String get connectedCameraRtspUsernameLabel => 'RTSP Username';

  @override
  String get connectedCameraRtspPasswordLabel => 'RTSP Password';

  @override
  String get connectedCameraStreamSectionTitle => 'Live Stream';

  @override
  String get connectedCameraStreamComingSoon =>
      'Real-time stream available in the next update.';

  @override
  String get connectedCameraRtspLabel => 'Camera Credentials';

  @override
  String get cameraAccountUserLabel => 'Camera Username';

  @override
  String get cameraAccountUserHint => 'admin';

  @override
  String get cameraAccountPasswordLabel => 'Camera Password';

  @override
  String get cameraAccountPasswordHint => 'Enter password';

  @override
  String get cameraTestSaveAnyway => 'Save anyway';
}
