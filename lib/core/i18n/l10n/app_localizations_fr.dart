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
  String get ipLocalLabel => 'IP locale';

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
  String get validationIpInvalid => 'IP invalide';

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
  String get detailsNetworkTitle => 'Réseau';

  @override
  String detailsWifiLine(Object value) {
    return 'Wi-Fi: $value';
  }

  @override
  String detailsPhoneIpLine(Object value) {
    return 'IP téléphone: $value';
  }

  @override
  String detailsEquipmentIpLine(Object value) {
    return 'Équipement: $value';
  }

  @override
  String detailsStatusLine(Object value) {
    return 'Statut: $value';
  }

  @override
  String get netGrantWifiAccess => 'Autoriser l\'accès Wi-Fi';

  @override
  String get netWifiPermissionRequired =>
      'Permission requise pour lire le Wi-Fi (SSID/IP)';

  @override
  String get netWifiPermissionRequiredPrefix => 'Permission requise';

  @override
  String get netStatusOnline => 'En ligne';

  @override
  String get netStatusOffline => 'Hors ligne';

  @override
  String get netStatusNotOnWifi => 'Pas en Wi-Fi (ou Wi-Fi non détectable)';

  @override
  String get netStatusNotOnWifiPrefix => 'Pas en Wi-Fi';

  @override
  String get netStatusWrongWifi => 'Mauvais Wi-Fi (réseau différent)';

  @override
  String get netStatusWrongWifiPrefix => 'Mauvais Wi-Fi';

  @override
  String get detailsDeviceInfoTitle => 'Infos appareil';

  @override
  String detailsDeviceModelLine(Object value) {
    return 'Modèle: $value';
  }

  @override
  String detailsDeviceGenLine(Object value) {
    return 'Génération: $value';
  }

  @override
  String detailsDeviceFwLine(Object value) {
    return 'Firmware: $value';
  }

  @override
  String detailsDeviceMacLine(Object value) {
    return 'MAC: $value';
  }

  @override
  String get detailsLiveDataTitle => 'Données live';

  @override
  String detailsOnOffLine(Object value) {
    return 'On/Off: $value';
  }

  @override
  String detailsPowerLine(Object value) {
    return 'Puissance: $value';
  }

  @override
  String detailsEnergyLine(Object value) {
    return 'Énergie: $value';
  }

  @override
  String detailsRssiLine(Object value) {
    return 'RSSI: $value';
  }

  @override
  String detailsLastUpdatedLine(Object value) {
    return 'Dernière maj: $value';
  }

  @override
  String get valueUnknown => '—';

  @override
  String get valueOn => 'ON';

  @override
  String get valueOff => 'OFF';

  @override
  String get actionTurnOn => 'Allumer';

  @override
  String get actionTurnOff => 'Éteindre';

  @override
  String get areas => 'Pièces';

  @override
  String get noRoomsYet => 'Aucune pièce pour le moment.';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get seeLess => 'Voir moins';

  @override
  String get addRoomTitle => 'Ajouter une pièce';

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
  String get valueSystemDefault => 'Langue du système';

  @override
  String get profileTitle => 'Profil';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get detailsConnectionLabel => 'Connexion';

  @override
  String get detailsConnectedWifi => 'Connecté (Wi-Fi)';

  @override
  String get detailsChartPlaceholder => 'Graphique (placeholder)';

  @override
  String detailsUpdatedAt(Object value) {
    return 'Mis à jour : $value';
  }

  @override
  String powerWatts(Object value) {
    return '$value W';
  }

  @override
  String get valueYes => 'Oui';

  @override
  String get valueNo => 'Non';

  @override
  String detailsKeyValueLine(Object key, Object value) {
    return '$key : $value';
  }

  @override
  String energyWh(Object value) {
    return '$value Wh';
  }

  @override
  String get detailsHistoryWindow2h => 'Dernières 2 heures';

  @override
  String get detailsHistoryWindow24h => 'Dernières 24 heures';

  @override
  String get detailsHistoryWindow7d => '7 derniers jours';

  @override
  String detailsUpdatedAgo(Object ago) {
    return 'Mis à jour il y a $ago';
  }

  @override
  String get detailsUpdatedJustNow => 'Mis à jour à l\'instant';

  @override
  String get detailsTrendUp => 'En hausse';

  @override
  String get detailsTrendDown => 'En baisse';

  @override
  String get detailsTrendFlat => 'Stable';

  @override
  String get detailsDeviceModelRightLabel => 'Modèle';

  @override
  String get detailsEditNameTooltip => 'Modifier le nom';

  @override
  String get detailsEditIpTooltip => 'Modifier l\'IP locale';

  @override
  String get detailsSelectTypeTooltip => 'Choisir le type';

  @override
  String get detailsToggleFavoriteTooltip => 'Basculer en favori';

  @override
  String get detailsConnectionStatusLabel => 'Statut réseau';

  @override
  String get detailsConnectedWifiShort => 'Connecté (Wi-Fi)';

  @override
  String get detailsDisconnectedShort => 'Déconnecté';

  @override
  String get detailsRoomDropdownTooltip => 'Choisir la pièce';

  @override
  String get detailsActionDelete => 'Supprimer';

  @override
  String get detailsEditNameDialogTitle => 'Modifier le nom de l\'équipement';

  @override
  String get detailsEditNameHint => 'ex : Plug';

  @override
  String get detailsEditIpDialogTitle => 'Modifier l\'IP locale';

  @override
  String get detailsEditIpHint => 'ex : 192.168.1.37';

  @override
  String get detailsRoomUnknown => 'Pièce inconnue';

  @override
  String get detailsDeviceModelUnknown => 'Modèle inconnu';

  @override
  String get detailsChartNoData => 'Aucune donnée';

  @override
  String get detailsTimelineTickNow => 'Maintenant';

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
  String get homeDefaultAreaGroupName => 'Maison #1';

  @override
  String homeConnectionSummary(int onlineCount, int offlineCount) {
    return '$onlineCount équipements connectés · $offlineCount hors ligne';
  }

  @override
  String get favoritesPageTitle => 'Liste des favoris';

  @override
  String get favoriteRemoveTooltip => 'Retirer des favoris';

  @override
  String get favoritesActiveFilterLabel => 'Actif(s) : Tous';

  @override
  String get favoritesFilterTooltip => 'Ouvrir les filtres des favoris';

  @override
  String get favoritesAddTooltip => 'Ajouter un favori';

  @override
  String get favoritesSearchHint => 'Rechercher des appareils...';

  @override
  String favoritesOnlineOf(int online, int total) {
    return '$online / $total en ligne';
  }

  @override
  String favoritesRoomsCount(int count) {
    return '$count pièces';
  }

  @override
  String get roomsSectionTitle => 'Areas';

  @override
  String get roomsPageTitle => 'Liste des pièces';

  @override
  String get roomsActiveFilterLabel => 'Actif(s) : Tous';

  @override
  String get roomsFilterTooltip => 'Ouvrir les filtres des pièces';

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
  String get roomsRoomNameLabel => 'Nom de la pièce';

  @override
  String get roomsRoomNameHint => 'Ex. Salon, Cuisine';

  @override
  String get roomsAddGroupTooltip => 'Ajouter un ensemble de pièces';

  @override
  String get roomsAddRoomTooltip => 'Ajouter une pièce';

  @override
  String get roomsRenameGroupTooltip => 'Renommer l\'ensemble';

  @override
  String get roomsDeleteGroupTooltip => 'Supprimer l\'ensemble';

  @override
  String get roomsDeleteRoomTooltip => 'Supprimer la pièce';

  @override
  String get roomsDeleteGroupTitle => 'Supprimer l\'ensemble';

  @override
  String roomsDeleteEmptyGroupMessage(String groupName) {
    return 'Supprimer l\'ensemble « $groupName » ?';
  }

  @override
  String roomsDeleteGroupWithRoomsMessage(String groupName, int roomCount) {
    return 'Supprimer l\'ensemble « $groupName » et ses $roomCount pièce(s) ?';
  }

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
  String get roomsNoActiveGroupSelected =>
      'Aucun ensemble de pièces actif. Sélectionnez-en un depuis l\'accueil.';

  @override
  String roomsEmptyForGroup(String groupName) {
    return 'Aucune pièce pour l\'ensemble « $groupName ».';
  }

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
  String get roomsAddRoomSheetTitle => 'Ajouter une pièce';

  @override
  String get roomsCreateNewRoom => 'Créer une nouvelle pièce';

  @override
  String get roomsNoAvailableRooms => 'Aucune autre pièce disponible';

  @override
  String roomsEquipmentCount(int count) {
    return '($count équipements)';
  }

  @override
  String get statsAddWidgetTitle => 'Ajouter un widget';

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
  String get statsTimeRangeDay => '1 Jour';

  @override
  String get statsTimeRangeWeek => '1 Semaine';

  @override
  String get statsTimeRangeMonth => '1 Mois';

  @override
  String get statsTimeRangeYear => '1 An';

  @override
  String get statsTimeRangeMax => 'Max';

  @override
  String get statsNoData => 'Aucune donnée';

  @override
  String get statsDeviceLabel => 'Équipement';

  @override
  String get statsNoDevicesInRoom => 'Aucun équipement dans cette pièce';

  @override
  String get statsEditWidget => 'Modifier le widget';

  @override
  String get statsDeleteWidget => 'Supprimer le widget';

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
  String get tvTestFailed => 'Connexion échouée';

  @override
  String get tvDeleteConfirm => 'Supprimer cette TV ?';

  @override
  String get tvReconnect => 'Reconnecter';

  @override
  String get tvStatusConnected => 'Connecté';

  @override
  String get tvStatusConnecting => 'Connexion…';

  @override
  String get tvStatusDisconnected => 'Déconnecté';

  @override
  String get tvKeyPower => 'Éteindre';

  @override
  String get tvKeyVolUp => 'Volume +';

  @override
  String get tvKeyVolDown => 'Volume −';

  @override
  String get tvKeyMute => 'Muet';

  @override
  String get tvKeyUp => 'Haut';

  @override
  String get tvKeyDown => 'Bas';

  @override
  String get tvKeyLeft => 'Gauche';

  @override
  String get tvKeyRight => 'Droite';

  @override
  String get tvKeyBack => 'Retour';

  @override
  String get tvKeyHome => 'Accueil';

  @override
  String get tvKeyMenu => 'Menu';

  @override
  String get tvKeyKeyboard => 'Clavier';

  @override
  String get tvKeySource => 'Source';

  @override
  String get tvAppsTitle => 'Applications :';

  @override
  String get tvTypeSmartTv => 'TV Connectée';

  @override
  String get tvDefaultModel => 'Samsung';

  @override
  String get tvStatusConnectedWifi => 'Connected (wi-fi)';

  @override
  String get tvModelLabel => 'Modèle';

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
  String get tvKeyboardHint => 'Texte à envoyer à la TV…';

  @override
  String get tvKeyboardSend => 'Envoyer';

  @override
  String get addDeviceTypeTitle => 'Type d\'appareil';

  @override
  String get deviceTypePlug => 'Prise connectée';

  @override
  String get deviceTypeTv => 'TV connectée';

  @override
  String get deviceTypeCobLedRgb => 'Bandeau LED WLED';

  @override
  String get deviceTypeCobLedCct => 'Éclairage LED CCT';

  @override
  String get cobLedRgbAddTitle => 'Ajouter un appareil WLED';

  @override
  String get cobLedRgbDefaultName => 'Bandeau LED';

  @override
  String get cobLedRgbNameHint => 'ex : LEDs Salon';

  @override
  String get cobLedRgbModelHint => 'ex : WLED v0.14';

  @override
  String get cobLedRgbTestFailed => 'Connexion échouée';

  @override
  String get cobLedRgbDeleteConfirm => 'Supprimer cet appareil ?';

  @override
  String get cobLedRgbBrightnessLabel => 'Luminosité';

  @override
  String get cobLedRgbSpeedLabel => 'Vitesse';

  @override
  String get cobLedRgbIntensityLabel => 'Intensité';

  @override
  String get cobLedRgbColorsTab => 'Couleurs';

  @override
  String get cobLedRgbEffectsTab => 'Effets';

  @override
  String get cobLedRgbScenesLabel => 'Scènes';

  @override
  String smartPlugDetailTitle(String name) {
    return '$name';
  }

  @override
  String get smartPlugSubtitle => 'Prise connectée';

  @override
  String get smartPlugOnline => 'en ligne';

  @override
  String get smartPlugOffline => 'hors ligne';

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
  String get smartPlugTimelineSubtitle => 'On/off dernières 24h';

  @override
  String get smartPlugSectionAlerts => 'Alertes';

  @override
  String get smartPlugNoAlerts => 'Aucun seuil configuré';

  @override
  String get smartPlugSectionInformations => 'Informations';

  @override
  String get smartPlugInfoLocalIp => 'IP locale';

  @override
  String get smartPlugInfoModel => 'Modèle';

  @override
  String get smartPlugInfoConnection => 'Connexion';

  @override
  String get smartPlugWifi => 'Wi-Fi';

  @override
  String get smartPlugChangeRoom => 'Modifier';

  @override
  String get smartPlugMenuRefresh => 'Actualiser';

  @override
  String get smartPlugMenuEdit => 'Modifier';

  @override
  String get smartPlugMenuDelete => 'Supprimer';

  @override
  String get smartPlugDeleteConfirmTitle => 'Supprimer l\'équipement ?';

  @override
  String get smartPlugDeleteConfirmBody => 'Cette action est irréversible.';

  @override
  String get smartPlugDeleteConfirmCancel => 'Annuler';

  @override
  String get smartPlugDeleteConfirmConfirm => 'Supprimer';

  @override
  String get smartPlugLastKnownValues => 'Dernières valeurs connues';

  @override
  String get smartPlugEditKwhPriceTitle => 'Prix de l\'électricité';

  @override
  String get smartPlugAlertSheetTitle => 'Ajouter une alerte';

  @override
  String get smartPlugAlertConditionLabel => 'Type d\'alerte';

  @override
  String get smartPlugAlertConditionWatts => 'Consommation (W)';

  @override
  String get smartPlugAlertConditionDailyCost => 'Coût journalier (€)';

  @override
  String get smartPlugAlertThresholdLabel => 'Seuil';

  @override
  String get smartPlugAlertThresholdHintWatts => 'ex. 2500';

  @override
  String get smartPlugAlertThresholdHintCost => 'ex. 1,50';

  @override
  String get smartPlugAlertNotificationsLabel => 'Notifications';

  @override
  String get smartPlugAlertNotifPush => 'Push';

  @override
  String get smartPlugAlertNotifBanner => 'Bannière';

  @override
  String get smartPlugAlertNotifRequired =>
      'Sélectionnez au moins un type de notification';

  @override
  String get tvSubtitle => 'Télécommande';

  @override
  String get tvOnline => 'en ligne';

  @override
  String get tvOffline => 'hors ligne';

  @override
  String get tvSourceActive => 'Source active';

  @override
  String get tvSectionRemote => 'Télécommande';

  @override
  String get tvSectionApplications => 'Applications';

  @override
  String get tvSectionInformations => 'Informations';

  @override
  String get tvMenuRefresh => 'Actualiser';

  @override
  String get tvMenuEdit => 'Modifier';

  @override
  String get tvMenuDelete => 'Supprimer';

  @override
  String get tvDeleteConfirmTitle => 'Supprimer la TV ?';

  @override
  String get tvDeleteConfirmBody => 'Cette action est irréversible.';

  @override
  String get tvDeleteConfirmCancel => 'Annuler';

  @override
  String get tvDeleteConfirmConfirm => 'Supprimer';

  @override
  String get tvLastKnownValues => 'Dernières valeurs connues';

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
  String get addDeviceIpLabel => 'IP locale';

  @override
  String get addDeviceRoomLabel => 'Pièce';

  @override
  String get addDeviceRoomOptionalLabel => 'Pièce (optionnel)';

  @override
  String get addDeviceModelOptionalLabel => 'Modèle (optionnel)';

  @override
  String get addDeviceFavoriteLabel => 'Favori';

  @override
  String get addDeviceAddToFavorites => 'Ajouter aux favoris';

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
  String get validationIpInvalidRange => 'Adresse IP invalide';

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
  String get fabScanOnWifiComingSoon => 'Scan Wi-Fi bientôt disponible';
}
