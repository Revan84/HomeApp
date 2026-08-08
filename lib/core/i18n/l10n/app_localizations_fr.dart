// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get tabHome => 'Accueil';

  @override
  String get tabData => 'Statistiques';

  @override
  String get tabEquipments => 'Équipements';

  @override
  String get tabAutomation => 'Automations';

  @override
  String get tabProfile => 'Profil';

  @override
  String get add => 'Ajouter';

  @override
  String get save => 'Sauvegarder';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get refresh => 'Rafraîchir';

  @override
  String get favorites => 'Favoris';

  @override
  String get noFavorites => 'Aucun favori pour le moment';

  @override
  String get addEquipmentTitle => 'Ajouter un équipement';

  @override
  String get editEquipmentTitle => 'Modifier l\'équipement';

  @override
  String get ipLocalHint => 'ex: 192.168.1.37';

  @override
  String get nameLabel => 'Nom';

  @override
  String get roomLabel => 'Pièce';

  @override
  String get none => 'Aucune';

  @override
  String get showDataTitle => 'Données à afficher';

  @override
  String get showOnOff => 'On/Off';

  @override
  String get showPower => 'Puissance (W)';

  @override
  String get showEnergy => 'Énergie (Wh/kWh)';

  @override
  String get showRssi => 'RSSI / Wi-Fi';

  @override
  String get favorite => 'Favori';

  @override
  String get test => 'Tester';

  @override
  String get testOk => 'Test OK';

  @override
  String get deleteEquipmentConfirmTitle => 'Supprimer l\'équipement ?';

  @override
  String deleteEquipmentConfirmBody(Object name) {
    return '“$name” sera supprimé.';
  }

  @override
  String get close => 'Fermer';

  @override
  String get nameHintExample => 'ex: Prise bureau';

  @override
  String get channelLabel => 'Canal (channel)';

  @override
  String get channelHint => '0';

  @override
  String get typeLabel => 'Type';

  @override
  String get equipmentTypeShellyPlusPlugS => 'Prise connectée';

  @override
  String get equipmentTypeShellyPlugS => 'Prise connectée (Shelly Plug S)';

  @override
  String get equipmentTypeOther => 'Autre (test)';

  @override
  String get validationIpRequired => 'L\'adresse IP est requise';

  @override
  String get validationIpInvalidFormat => 'Format invalide (ex. 192.168.1.37)';

  @override
  String get validationNumberInvalid => 'Nombre invalide';

  @override
  String get validationChannelInvalid => 'Canal invalide';

  @override
  String testFailed(Object error) {
    return 'Test KO: $error';
  }

  @override
  String get defaultEquipmentName => 'Équipement';

  @override
  String get detectedInfoTitle => 'Infos détectées';

  @override
  String deviceInfoName(Object value) {
    return 'Nom: $value';
  }

  @override
  String deviceInfoModel(Object value) {
    return 'Modèle: $value';
  }

  @override
  String deviceInfoMac(Object value) {
    return 'MAC: $value';
  }

  @override
  String get netStatusOnline => 'En ligne';

  @override
  String get netStatusOffline => 'Hors ligne';

  @override
  String get valueUnknown => '—';

  @override
  String get roomNameLabel => 'Nom de la pièce';

  @override
  String get roomNameHint => 'ex: Salon';

  @override
  String get validationRoomNameRequired => 'Nom requis';

  @override
  String get noEquipments => 'Aucun équipement';

  @override
  String get profileAccountSecurity => 'Compte et sécurité';

  @override
  String get profileRemoteAccess =>
      'Accès distant (reverse proxy, état connexion)';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileAppearance => 'Apparence';

  @override
  String get profileBackupRestore => 'Sauvegarde / Restauration configuration';

  @override
  String get profileLogout => 'Déconnexion';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get detailsConnectedWifi => 'Connecté (Wi-Fi)';

  @override
  String powerWatts(Object value) {
    return '$value W';
  }

  @override
  String get valueYes => 'Oui';

  @override
  String get valueNo => 'Non';

  @override
  String energyWh(Object value) {
    return '$value Wh';
  }

  @override
  String get detailsEditNameTooltip => 'Modifier le nom';

  @override
  String get detailsEditIpTooltip => 'Modifier l\'IP locale';

  @override
  String get detailsSelectTypeTooltip => 'Choisir le type';

  @override
  String get detailsRoomDropdownTooltip => 'Choisir la pièce';

  @override
  String get historyRange1d => '1J';

  @override
  String get historyRange1w => '1S';

  @override
  String get historyRange1m => '1M';

  @override
  String get historyRange1y => '1A';

  @override
  String get historyRangeMax => 'Max';

  @override
  String get unitWattShort => 'W';

  @override
  String get confirmDeleteEquipment =>
      'Supprimer cet équipement ? Cette action est irréversible.';

  @override
  String get updatedJustNow => 'Mis à jour à l\'instant';

  @override
  String updatedSecondsAgo(int seconds) {
    return 'Mis à jour il y a ${seconds}s';
  }

  @override
  String updatedMinutesAgo(int minutes) {
    return 'Mis à jour il y a $minutes min';
  }

  @override
  String updatedHoursAgo(int hours) {
    return 'Mis à jour il y a $hours h';
  }

  @override
  String get homeWelcomeTitle => 'Bienvenue';

  @override
  String homeConnectionSummary(int onlineCount, int offlineCount) {
    return '$onlineCount équipements connectés · $offlineCount hors ligne';
  }

  @override
  String get favoritesPageTitle => 'Liste des favoris';

  @override
  String get favoritesSearchHint => 'Rechercher des appareils...';

  @override
  String get roomsSectionTitle => 'Areas';

  @override
  String get roomsPageTitle => 'Liste des pièces';

  @override
  String get roomsEmptyState => 'Aucun ensemble de pièces pour le moment';

  @override
  String get roomsAddGroupTitle => 'Ajouter un ensemble';

  @override
  String get roomsRenameGroupTitle => 'Renommer l\'ensemble';

  @override
  String get roomsGroupNameHint => 'Ex. Maison, Appartement';

  @override
  String get roomsAddRoomTitle => 'Ajouter une pièce';

  @override
  String get roomsRenameRoomTitle => 'Renommer la pièce';

  @override
  String get roomsRoomNameHint => 'Ex. Salon, Cuisine';

  @override
  String get roomsDeleteRoomTitle => 'Supprimer la pièce';

  @override
  String roomsDeleteRoomMessage(String roomName) {
    return 'Supprimer la pièce « $roomName » ?';
  }

  @override
  String get roomsNoGroupForQuickAdd =>
      'Vous devez d\'abord créer un ensemble de pièces avant d\'ajouter une pièce.';

  @override
  String get roomsFirstGroupLabel => 'Premier ensemble';

  @override
  String get roomsCreateFirstGroup => 'Créer le premier ensemble';

  @override
  String get roomsTargetGroupLabel => 'Ensemble cible';

  @override
  String get roomsTargetGroupRequired => 'Sélectionnez un ensemble de pièces';

  @override
  String get homeNoActiveRoomGroup => 'Aucun ensemble';

  @override
  String get homeSelectRoomGroupTitle => 'Choisir un ensemble';

  @override
  String get roomsSearchHint => 'Rechercher des pièces...';

  @override
  String get roomDetailRemoveTooltip => 'Retirer de la pièce';

  @override
  String get roomDetailUnlinkTitle => 'Retirer de la pièce ?';

  @override
  String roomDetailUnlinkMessage(String deviceName) {
    return '\'$deviceName\' sera retiré de cette pièce.';
  }

  @override
  String get roomDetailUnlinkConfirm => 'Retirer';

  @override
  String get roomsGroupNameFieldLabel => 'Nom de l\'ensemble';

  @override
  String get validationRoomGroupNameRequired => 'Saisissez un nom d\'ensemble';

  @override
  String get roomsCreateNewRoom => 'Créer une nouvelle pièce';

  @override
  String get roomsNoAvailableRooms => 'Aucune autre pièce disponible';

  @override
  String roomsEquipmentCount(int count) {
    return '($count équipements)';
  }

  @override
  String get statsAddChart => 'Graphique';

  @override
  String get statsAddTable => 'Tableau';

  @override
  String get statsAddHistory => 'Historique';

  @override
  String get statsAddKpi => 'KPI';

  @override
  String get statsNoWidgets => 'Aucun widget. Ajoutez-en un pour commencer.';

  @override
  String get statsConfigTitle => 'Configurer le widget';

  @override
  String get statsMetricLabel => 'Métrique';

  @override
  String get statsTimeRangeLabel => 'Période';

  @override
  String get statsChartTypeLabel => 'Type de graphique';

  @override
  String get statsDeviceLabel => 'Équipement';

  @override
  String get statsNoDevicesInRoom => 'Aucun équipement dans cette pièce';

  @override
  String get statsEditWidget => 'Modifier le widget';

  @override
  String get statsDeleteConfirm => 'Supprimer ce widget ?';

  @override
  String get statsEmptyHint =>
      'Appuyez sur + pour ajouter votre premier widget';

  @override
  String get statsNoCompatibleDevice =>
      'Aucun appareil compatible pour ce type de widget';

  @override
  String get statsDeviceTypeSmartPlug => 'Prise connectée';

  @override
  String get statsDeviceTypeGeneric => 'Appareil';

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
  String get tvAddTitle => 'Ajouter une TV';

  @override
  String get tvDefaultName => 'Smart TV';

  @override
  String get tvNameHint => 'ex : Samsung Salon';

  @override
  String get tvReconnect => 'Reconnecter';

  @override
  String get tvStatusConnecting => 'Connexion…';

  @override
  String get tvStatusDisconnected => 'Déconnecté';

  @override
  String get tvKeyBack => 'Retour';

  @override
  String get tvKeyHome => 'Accueil';

  @override
  String get tvKeyKeyboard => 'Clavier';

  @override
  String get tvKeySource => 'Source';

  @override
  String get tvStatusConnectedWifi => 'Connected (wi-fi)';

  @override
  String get tvModelHint => 'ex : Samsung 55Q80B';

  @override
  String get tvVoiceListening => 'À l\'écoute…';

  @override
  String get tvVoiceTap => 'Appuyez sur le micro pour réessayer';

  @override
  String get tvVoiceError => 'Microphone indisponible';

  @override
  String get tvKeySettings => 'Paramètres';

  @override
  String get tvKeyboardSend => 'Envoyer';

  @override
  String get deviceTypePlug => 'Prise connectée';

  @override
  String get deviceTypeTv => 'TV connectée';

  @override
  String get cobLedRgbAddTitle => 'Ajouter un appareil WLED';

  @override
  String get cobLedRgbDefaultName => 'Bandeau LED';

  @override
  String get cobLedRgbNameHint => 'ex : LEDs Salon';

  @override
  String get cobLedRgbModelHint => 'ex : WLED v0.14';

  @override
  String get smartPlugSubtitle => 'Prise connectée';

  @override
  String get smartPlugKpiUnit => 'W';

  @override
  String smartPlugCostPerHour(String cost) {
    return '≈ $cost €/h';
  }

  @override
  String smartPlugCostToday(String cost) {
    return '≈ $cost€ aujourd\'hui';
  }

  @override
  String smartPlugKwhCumulated(String kwh) {
    return '$kwh kWh cumulés';
  }

  @override
  String get smartPlugSectionConsumption => 'Consommation';

  @override
  String get smartPlugSectionTimeline => 'Chronologie';

  @override
  String get smartPlugSectionAlerts => 'Alertes';

  @override
  String get smartPlugEditKwhPriceTitle => 'Prix de l\'électricité';

  @override
  String get smartPlugAlertConditionWatts => 'Consommation (W)';

  @override
  String get smartPlugAlertConditionDailyCost => 'Coût journalier (€)';

  @override
  String get smartPlugAlertThresholdHintWatts => 'ex. 2500';

  @override
  String get smartPlugAlertThresholdHintCost => 'ex. 1,50';

  @override
  String get smartPlugAlertNotifRequired =>
      'Sélectionnez au moins un type de notification';

  @override
  String get tvSubtitle => 'Télécommande';

  @override
  String get tvSourceActive => 'Source active';

  @override
  String get tvSectionRemote => 'Télécommande';

  @override
  String get tvSectionApplications => 'Applications';

  @override
  String get detailSectionLive => 'EN DIRECT';

  @override
  String get detailSectionHistoric => 'HISTORIQUE';

  @override
  String get detailSectionInformations => 'INFORMATIONS';

  @override
  String get detailSectionAlerts => 'ALERTES';

  @override
  String get detailSectionTemperature => 'TEMPÉRATURE';

  @override
  String get detailStatMin => 'MIN';

  @override
  String get detailStatMax => 'MAX';

  @override
  String get detailStatAvgWeek => 'Moy. semaine';

  @override
  String get detailStatAvgMonth => 'Moy. mois';

  @override
  String get detailStatAmplitude => 'Amplitude';

  @override
  String get detailStatToday => 'Aujourd\'hui';

  @override
  String get detailInfoStatus => 'Statut';

  @override
  String get detailTrendRising => 'Tendance : hausse';

  @override
  String get detailTrendFalling => 'Tendance : baisse';

  @override
  String get detailTrendUpward => 'Tendance : montée';

  @override
  String get detailTrendDownward => 'Tendance : descente';

  @override
  String get thermometerTypeLabel => 'Thermomètre';

  @override
  String get hygrometerTypeLabel => 'Hygromètre';

  @override
  String get cobLedRgbTypeLabel => 'COB LED RGB';

  @override
  String get cobLedCctTypeLabel => 'COB LED CCT';

  @override
  String get deviceOfflineBanner => 'Appareil hors ligne';

  @override
  String get deviceNotFound => 'Appareil introuvable';

  @override
  String get cobLedSectionLuminosity => 'LUMINOSITÉ';

  @override
  String get cobLedSectionWledControls => 'CONTRÔLES WLED';

  @override
  String get cobLedRgbSectionColor => 'COULEUR';

  @override
  String get cobLedCctSectionColourTemp => 'TEMPÉRATURE DE COULEUR';

  @override
  String get cobLedCctSaveAsTemplateTitle => 'Enregistrer comme modèle';

  @override
  String get cobLedCctTemplateNameHint => 'Nom du modèle';

  @override
  String get cobLedCctDeviceHint => 'ex. ESP32 CCT Controller';

  @override
  String get sensorAlertConditionAbove => 'Au-dessus';

  @override
  String get sensorAlertConditionBelow => 'En dessous';

  @override
  String get hygrometerComfortRangeLabel => 'Zone de confort : 40 % – 60 %';

  @override
  String get hygrometerStatComfort => 'Confort';

  @override
  String get homeSectionToday => 'Aujourd\'hui';

  @override
  String get homeTodayConsumptionLabel => 'Consommation';

  @override
  String get homeTodayAvgTempLabel => 'Temp. moy.';

  @override
  String get homeTodayHumidityLabel => 'Humidité';

  @override
  String get equipmentsFilterAllTypes => 'Tous les types';

  @override
  String equipmentsRoomAll(int count) {
    return 'Toutes les pièces ($count)';
  }

  @override
  String equipmentsRoomItem(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get equipmentsSearchHint => 'Rechercher un appareil...';

  @override
  String areasAllRooms(int count) {
    return 'Toutes les pièces ($count)';
  }

  @override
  String areasRoomItem(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get areasNoRooms => 'Aucune pièce configurée.';

  @override
  String get areasNoDevices => 'Aucun appareil dans cette pièce.';

  @override
  String get deviceStatusOn => 'ON';

  @override
  String get deviceStatusOff => 'OFF';

  @override
  String colorCopiedSnack(String hex) {
    return '$hex copié';
  }

  @override
  String get cobLedEffectLabel => 'Effet';

  @override
  String get cobLedSpeedLabel => 'Vitesse';

  @override
  String get cobLedIntensityLabel => 'Intensité';

  @override
  String get cobLedAudioReactive => 'Réactif au son';

  @override
  String get cobLedAudioReactiveHint => 'Réagir à l\'entrée du microphone';

  @override
  String get cobLedLoadingEffects => 'Chargement des effets…';

  @override
  String get cobLedNoPresets => 'Aucun preset trouvé sur l\'appareil.';

  @override
  String get cobLedSectionTemplates => 'MODÈLES';

  @override
  String get cobLedSectionActiveScene => 'SCÈNE ACTIVE';

  @override
  String get cobLedNoActiveScene => 'Aucune scène active';

  @override
  String get cobLedPresetActive => 'Actif';

  @override
  String get cobLedPresetApply => 'Appliquer';

  @override
  String get addDeviceTitle => 'Ajouter un appareil';

  @override
  String get addDeviceTypeLabel => 'Type d\'appareil';

  @override
  String get addDeviceTypeHint => 'Sélectionner un type';

  @override
  String get addDeviceNameLabel => 'Nom de l\'appareil';

  @override
  String get addDeviceModelOptionalLabel => 'Modèle (optionnel)';

  @override
  String get addDeviceConnectedCheck => 'Connecté ✓';

  @override
  String get cobLedCctAddTitle => 'Ajouter une lumière CCT';

  @override
  String get cobLedCctAddDeviceError =>
      'Impossible d\'ajouter le contrôleur LED. Vérifiez l\'IP et réessayez.';

  @override
  String get cctLabelWarmWhite => 'Blanc chaud';

  @override
  String get cctLabelNeutralWhite => 'Blanc neutre';

  @override
  String get cctLabelCoolWhite => 'Blanc froid';

  @override
  String get validationNameRequired => 'Nom requis';

  @override
  String connectionFailedDetail(String error) {
    return 'Connexion échouée : $error';
  }

  @override
  String get noData => 'Aucune donnée';

  @override
  String get cobLedCctTemplatesTitle => 'Modèles';

  @override
  String get cobLedCctNoTemplates =>
      'Aucun modèle. Enregistrez une scène pour la réutiliser.';

  @override
  String get cobLedCctTemplateActiveBadge => 'Actif';

  @override
  String get cobLedCctSpdSuffix => 'vit';

  @override
  String get cobLedCctWarm => 'Chaud';

  @override
  String get cobLedCctCold => 'Froid';

  @override
  String get cobLedCctNoActiveTemplate => 'Aucun modèle actif';

  @override
  String get cobLedCctSceneActive => 'Scène active';

  @override
  String get cobLedCctUpdateTemplateTitle => 'Modifier le modèle';

  @override
  String get cobLedCctDeleteSceneTitle => 'Supprimer le modèle ?';

  @override
  String cobLedCctDeleteSceneBody(String name) {
    return '« $name » sera définitivement supprimé.';
  }

  @override
  String get deviceInfoLocalIp => 'IP locale';

  @override
  String get deviceInfoModelLabel => 'Modèle';

  @override
  String get deviceInfoConnection => 'Connexion';

  @override
  String get deviceConnectionWifi => 'Wi-Fi';

  @override
  String get deviceMenuDelete => 'Supprimer';

  @override
  String get deviceMenuRefresh => 'Actualiser';

  @override
  String get deviceLastKnownValues => 'Dernières valeurs connues';

  @override
  String get alertNoneConfigured => 'Aucun seuil configuré';

  @override
  String get alertSheetAddTitle => 'Ajouter une alerte';

  @override
  String get alertConditionLabel => 'Type d\'alerte';

  @override
  String get alertThresholdLabel => 'Seuil';

  @override
  String get alertNotificationsLabel => 'Notifications';

  @override
  String get alertNotifPush => 'Push';

  @override
  String get alertNotifBanner => 'Bannière';

  @override
  String get deviceMenuEdit => 'Modifier';

  @override
  String get deviceSectionInformations => 'Informations';

  @override
  String get deviceTestFailed => 'Connexion échouée';

  @override
  String get fabScanOnWifiComingSoon => 'Scan Wi-Fi bientôt disponible';

  @override
  String get connectedCameraTypeLabel => 'Caméra IP';

  @override
  String get connectedCameraAddTitle => 'Ajouter une caméra IP';

  @override
  String get connectedCameraDeviceHint => 'ex. HomeCam 3';

  @override
  String get connectedCameraAddDeviceError =>
      'Impossible d\'ajouter la caméra. Vérifiez l\'IP et réessayez.';

  @override
  String get connectedCameraOffline => 'Hors ligne';

  @override
  String get connectedCameraRtspUsernameLabel => 'Identifiant RTSP';

  @override
  String get connectedCameraRtspPasswordLabel => 'Mot de passe RTSP';

  @override
  String get connectedCameraStreamSectionTitle => 'Flux en direct';

  @override
  String get connectedCameraStreamComingSoon =>
      'Le flux en temps réel sera disponible dans la prochaine mise à jour.';

  @override
  String get connectedCameraRtspLabel => 'Identifiants caméra';

  @override
  String get cameraAccountUserLabel => 'Identifiant caméra';

  @override
  String get cameraAccountUserHint => 'admin';

  @override
  String get cameraAccountPasswordLabel => 'Mot de passe caméra';

  @override
  String get cameraAccountPasswordHint => 'Saisir le mot de passe';

  @override
  String get cameraTestSaveAnyway => 'Enregistrer quand même';
}
