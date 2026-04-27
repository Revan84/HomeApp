import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Libellé de l'onglet Accueil (barre de navigation)
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get tabHome;

  /// Libellé de l'onglet Statistiques (barre de navigation)
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get tabData;

  /// Libellé de l'onglet Équipements (barre de navigation)
  ///
  /// In fr, this message translates to:
  /// **'Équipements'**
  String get tabEquipments;

  /// Libellé de l'onglet Automations (barre de navigation)
  ///
  /// In fr, this message translates to:
  /// **'Automations'**
  String get tabAutomation;

  /// Libellé de l'onglet Profil (barre de navigation)
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// Libellé générique d'action : ajouter
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// Libellé générique d'action : sauvegarder
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder'**
  String get save;

  /// Libellé générique d'action : annuler
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// Libellé générique d'action : supprimer
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// Libellé générique d'action : modifier
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// Libellé générique d'action : rafraîchir
  ///
  /// In fr, this message translates to:
  /// **'Rafraîchir'**
  String get refresh;

  /// Titre de section : favoris
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get favorites;

  /// Message affiché quand la liste des favoris est vide
  ///
  /// In fr, this message translates to:
  /// **'Aucun favori pour le moment'**
  String get noFavorites;

  /// Titre de la bottom sheet d'ajout d'équipement
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un équipement'**
  String get addEquipmentTitle;

  /// Titre de la bottom sheet de modification d'équipement
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'équipement'**
  String get editEquipmentTitle;

  /// Label du champ IP locale
  ///
  /// In fr, this message translates to:
  /// **'IP locale'**
  String get ipLocalLabel;

  /// Hint/exemple du champ IP locale
  ///
  /// In fr, this message translates to:
  /// **'ex: 192.168.1.37'**
  String get ipLocalHint;

  /// Label du champ Nom
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get nameLabel;

  /// Label du champ de sélection de pièce
  ///
  /// In fr, this message translates to:
  /// **'Pièce'**
  String get roomLabel;

  /// Option générique : aucune
  ///
  /// In fr, this message translates to:
  /// **'Aucune'**
  String get none;

  /// Titre de section : choix des données affichées
  ///
  /// In fr, this message translates to:
  /// **'Données à afficher'**
  String get showDataTitle;

  /// Option d'affichage : interrupteur On/Off
  ///
  /// In fr, this message translates to:
  /// **'On/Off'**
  String get showOnOff;

  /// Option d'affichage : puissance en watts
  ///
  /// In fr, this message translates to:
  /// **'Puissance (W)'**
  String get showPower;

  /// Option d'affichage : énergie (Wh/kWh)
  ///
  /// In fr, this message translates to:
  /// **'Énergie (Wh/kWh)'**
  String get showEnergy;

  /// Option d'affichage : RSSI / qualité Wi-Fi
  ///
  /// In fr, this message translates to:
  /// **'RSSI / Wi-Fi'**
  String get showRssi;

  /// Libellé du switch : marquer comme favori
  ///
  /// In fr, this message translates to:
  /// **'Favori'**
  String get favorite;

  /// Bouton : tester la connexion / détection
  ///
  /// In fr, this message translates to:
  /// **'Tester'**
  String get test;

  /// Libellé du bouton quand le test est réussi
  ///
  /// In fr, this message translates to:
  /// **'Test OK'**
  String get testOk;

  /// Titre de la boîte de dialogue de confirmation de suppression
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'équipement ?'**
  String get deleteEquipmentConfirmTitle;

  /// Message de confirmation de suppression, avec le nom de l'équipement
  ///
  /// In fr, this message translates to:
  /// **'“{name}” sera supprimé.'**
  String deleteEquipmentConfirmBody(Object name);

  /// Tooltip/label : fermer
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// Hint/exemple du champ Nom
  ///
  /// In fr, this message translates to:
  /// **'ex: Prise bureau'**
  String get nameHintExample;

  /// Label du champ canal (index de relais/sortie)
  ///
  /// In fr, this message translates to:
  /// **'Canal (channel)'**
  String get channelLabel;

  /// Hint/exemple du champ canal
  ///
  /// In fr, this message translates to:
  /// **'0'**
  String get channelHint;

  /// Label du champ Type d'équipement
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// Libellé de type : Shelly Plus Plug S
  ///
  /// In fr, this message translates to:
  /// **'Prise connectée'**
  String get equipmentTypeShellyPlusPlugS;

  /// Libellé de type : Shelly Plug S
  ///
  /// In fr, this message translates to:
  /// **'Prise connectée (Shelly Plug S)'**
  String get equipmentTypeShellyPlugS;

  /// Libellé de type : autre équipement (test)
  ///
  /// In fr, this message translates to:
  /// **'Autre (test)'**
  String get equipmentTypeOther;

  /// Erreur validation : champ IP vide
  ///
  /// In fr, this message translates to:
  /// **'L\'adresse IP est requise'**
  String get validationIpRequired;

  /// Erreur validation : format IP incorrect
  ///
  /// In fr, this message translates to:
  /// **'Format invalide (ex. 192.168.1.37)'**
  String get validationIpInvalidFormat;

  /// Erreur de validation : IP hors plage
  ///
  /// In fr, this message translates to:
  /// **'IP invalide'**
  String get validationIpInvalid;

  /// Erreur de validation : valeur numérique invalide
  ///
  /// In fr, this message translates to:
  /// **'Nombre invalide'**
  String get validationNumberInvalid;

  /// Erreur de validation : canal hors plage
  ///
  /// In fr, this message translates to:
  /// **'Canal invalide'**
  String get validationChannelInvalid;

  /// Message d'erreur quand le test de connexion échoue
  ///
  /// In fr, this message translates to:
  /// **'Test KO: {error}'**
  String testFailed(Object error);

  /// Nom par défaut si l'utilisateur ne saisit rien
  ///
  /// In fr, this message translates to:
  /// **'Équipement'**
  String get defaultEquipmentName;

  /// Titre du bloc d'informations détectées via RPC
  ///
  /// In fr, this message translates to:
  /// **'Infos détectées'**
  String get detectedInfoTitle;

  /// Ligne info device : nom
  ///
  /// In fr, this message translates to:
  /// **'Nom: {value}'**
  String deviceInfoName(Object value);

  /// Ligne info device : modèle
  ///
  /// In fr, this message translates to:
  /// **'Modèle: {value}'**
  String deviceInfoModel(Object value);

  /// Ligne info device : adresse MAC
  ///
  /// In fr, this message translates to:
  /// **'MAC: {value}'**
  String deviceInfoMac(Object value);

  /// Titre de la carte réseau sur la page détails équipement
  ///
  /// In fr, this message translates to:
  /// **'Réseau'**
  String get detailsNetworkTitle;

  /// Ligne SSID Wi-Fi
  ///
  /// In fr, this message translates to:
  /// **'Wi-Fi: {value}'**
  String detailsWifiLine(Object value);

  /// Ligne IP du téléphone
  ///
  /// In fr, this message translates to:
  /// **'IP téléphone: {value}'**
  String detailsPhoneIpLine(Object value);

  /// Ligne IP de l'équipement
  ///
  /// In fr, this message translates to:
  /// **'Équipement: {value}'**
  String detailsEquipmentIpLine(Object value);

  /// Ligne statut réseau
  ///
  /// In fr, this message translates to:
  /// **'Statut: {value}'**
  String detailsStatusLine(Object value);

  /// Bouton demandant l'autorisation Wi-Fi/Localisation
  ///
  /// In fr, this message translates to:
  /// **'Autoriser l\'accès Wi-Fi'**
  String get netGrantWifiAccess;

  /// Statut affiché quand la permission Wi-Fi/Localisation manque
  ///
  /// In fr, this message translates to:
  /// **'Permission requise pour lire le Wi-Fi (SSID/IP)'**
  String get netWifiPermissionRequired;

  /// Préfixe utilisé pour bloquer les appels RPC quand la permission manque
  ///
  /// In fr, this message translates to:
  /// **'Permission requise'**
  String get netWifiPermissionRequiredPrefix;

  /// Statut: équipement joignable
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get netStatusOnline;

  /// Statut: équipement non joignable
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get netStatusOffline;

  /// Statut: téléphone pas en Wi-Fi
  ///
  /// In fr, this message translates to:
  /// **'Pas en Wi-Fi (ou Wi-Fi non détectable)'**
  String get netStatusNotOnWifi;

  /// Préfixe utilisé pour bloquer les appels RPC quand pas en Wi-Fi
  ///
  /// In fr, this message translates to:
  /// **'Pas en Wi-Fi'**
  String get netStatusNotOnWifiPrefix;

  /// Statut: téléphone sur un autre réseau
  ///
  /// In fr, this message translates to:
  /// **'Mauvais Wi-Fi (réseau différent)'**
  String get netStatusWrongWifi;

  /// Préfixe utilisé pour bloquer les appels RPC quand mauvais Wi-Fi
  ///
  /// In fr, this message translates to:
  /// **'Mauvais Wi-Fi'**
  String get netStatusWrongWifiPrefix;

  /// Titre de la carte device info
  ///
  /// In fr, this message translates to:
  /// **'Infos appareil'**
  String get detailsDeviceInfoTitle;

  /// Ligne modèle
  ///
  /// In fr, this message translates to:
  /// **'Modèle: {value}'**
  String detailsDeviceModelLine(Object value);

  /// Ligne génération
  ///
  /// In fr, this message translates to:
  /// **'Génération: {value}'**
  String detailsDeviceGenLine(Object value);

  /// Ligne version firmware
  ///
  /// In fr, this message translates to:
  /// **'Firmware: {value}'**
  String detailsDeviceFwLine(Object value);

  /// Ligne MAC
  ///
  /// In fr, this message translates to:
  /// **'MAC: {value}'**
  String detailsDeviceMacLine(Object value);

  /// Titre de la carte données live
  ///
  /// In fr, this message translates to:
  /// **'Données live'**
  String get detailsLiveDataTitle;

  /// Ligne On/Off
  ///
  /// In fr, this message translates to:
  /// **'On/Off: {value}'**
  String detailsOnOffLine(Object value);

  /// Ligne puissance
  ///
  /// In fr, this message translates to:
  /// **'Puissance: {value}'**
  String detailsPowerLine(Object value);

  /// Ligne énergie
  ///
  /// In fr, this message translates to:
  /// **'Énergie: {value}'**
  String detailsEnergyLine(Object value);

  /// Ligne RSSI
  ///
  /// In fr, this message translates to:
  /// **'RSSI: {value}'**
  String detailsRssiLine(Object value);

  /// Ligne dernière mise à jour
  ///
  /// In fr, this message translates to:
  /// **'Dernière maj: {value}'**
  String detailsLastUpdatedLine(Object value);

  /// Valeur inconnue / non disponible
  ///
  /// In fr, this message translates to:
  /// **'—'**
  String get valueUnknown;

  /// État on (interrupteur)
  ///
  /// In fr, this message translates to:
  /// **'ON'**
  String get valueOn;

  /// État off (interrupteur)
  ///
  /// In fr, this message translates to:
  /// **'OFF'**
  String get valueOff;

  /// Action: allumer l'équipement
  ///
  /// In fr, this message translates to:
  /// **'Allumer'**
  String get actionTurnOn;

  /// Action: éteindre l'équipement
  ///
  /// In fr, this message translates to:
  /// **'Éteindre'**
  String get actionTurnOff;

  /// Titre de la section affichant les pièces de la maison
  ///
  /// In fr, this message translates to:
  /// **'Pièces'**
  String get areas;

  /// Message affiché lorsqu'il n'y a encore aucune pièce enregistrée
  ///
  /// In fr, this message translates to:
  /// **'Aucune pièce pour le moment.'**
  String get noRoomsYet;

  /// Bouton pour afficher toutes les pièces lorsque la liste est réduite
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get seeAll;

  /// Bouton pour réduire la liste des pièces affichées
  ///
  /// In fr, this message translates to:
  /// **'Voir moins'**
  String get seeLess;

  /// Titre de la feuille modale permettant d'ajouter une pièce
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une pièce'**
  String get addRoomTitle;

  /// Label du champ de saisie du nom de la pièce
  ///
  /// In fr, this message translates to:
  /// **'Nom de la pièce'**
  String get roomNameLabel;

  /// Exemple affiché dans le champ de nom de la pièce
  ///
  /// In fr, this message translates to:
  /// **'ex: Salon'**
  String get roomNameHint;

  /// Message d'erreur affiché lorsque le nom de la pièce est vide
  ///
  /// In fr, this message translates to:
  /// **'Nom requis'**
  String get validationRoomNameRequired;

  /// Message affiché lorsqu'une pièce ne contient aucun équipement
  ///
  /// In fr, this message translates to:
  /// **'Aucun équipement'**
  String get noEquipments;

  /// Entrée du menu profil pour gérer le compte et la sécurité.
  ///
  /// In fr, this message translates to:
  /// **'Compte et sécurité'**
  String get profileAccountSecurity;

  /// Entrée du menu profil pour la configuration de l'accès distant.
  ///
  /// In fr, this message translates to:
  /// **'Accès distant (reverse proxy, état connexion)'**
  String get profileRemoteAccess;

  /// Entrée du menu profil pour changer la langue de l'application.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get profileLanguage;

  /// Entrée du menu profil pour personnaliser le thème et l'affichage.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get profileAppearance;

  /// Entrée du menu profil pour sauvegarder ou restaurer la configuration.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde / Restauration configuration'**
  String get profileBackupRestore;

  /// Bouton permettant de se déconnecter.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get profileLogout;

  /// Option de langue utilisant la langue du système du téléphone.
  ///
  /// In fr, this message translates to:
  /// **'Langue du système'**
  String get valueSystemDefault;

  /// Titre de l'onglet Profil.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// Libellé de langue: français.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// Libellé de langue: anglais.
  ///
  /// In fr, this message translates to:
  /// **'Anglais'**
  String get languageEnglish;

  /// Label for the connection status row in favorite details.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get detailsConnectionLabel;

  /// Connection status label when device is connected over Wi-Fi.
  ///
  /// In fr, this message translates to:
  /// **'Connecté (Wi-Fi)'**
  String get detailsConnectedWifi;

  /// Temporary placeholder text displayed where the chart will be.
  ///
  /// In fr, this message translates to:
  /// **'Graphique (placeholder)'**
  String get detailsChartPlaceholder;

  /// Last update label with a date/time string.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour : {value}'**
  String detailsUpdatedAt(Object value);

  /// Power label in watts.
  ///
  /// In fr, this message translates to:
  /// **'{value} W'**
  String powerWatts(Object value);

  /// Generic yes value.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get valueYes;

  /// Generic no value.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get valueNo;

  /// Affichage générique 'clé : valeur' dans les lignes d'infos d'une page détail.
  ///
  /// In fr, this message translates to:
  /// **'{key} : {value}'**
  String detailsKeyValueLine(Object key, Object value);

  /// Affichage d'énergie en Wh.
  ///
  /// In fr, this message translates to:
  /// **'{value} Wh'**
  String energyWh(Object value);

  /// Libellé de fenêtre d'historique (graphique) sur la page détails.
  ///
  /// In fr, this message translates to:
  /// **'Dernières 2 heures'**
  String get detailsHistoryWindow2h;

  /// Libellé de fenêtre d'historique (graphique) sur la page détails.
  ///
  /// In fr, this message translates to:
  /// **'Dernières 24 heures'**
  String get detailsHistoryWindow24h;

  /// Libellé de fenêtre d'historique (graphique) sur la page détails.
  ///
  /// In fr, this message translates to:
  /// **'7 derniers jours'**
  String get detailsHistoryWindow7d;

  /// Indique le temps écoulé depuis la dernière mise à jour (ex: 3 min).
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour il y a {ago}'**
  String detailsUpdatedAgo(Object ago);

  /// Affiché quand la dernière mise à jour est très récente.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour à l\'instant'**
  String get detailsUpdatedJustNow;

  /// Libellé tendance lorsque la puissance augmente (accessibilité).
  ///
  /// In fr, this message translates to:
  /// **'En hausse'**
  String get detailsTrendUp;

  /// Libellé tendance lorsque la puissance diminue (accessibilité).
  ///
  /// In fr, this message translates to:
  /// **'En baisse'**
  String get detailsTrendDown;

  /// Libellé tendance lorsque la puissance est stable (accessibilité).
  ///
  /// In fr, this message translates to:
  /// **'Stable'**
  String get detailsTrendFlat;

  /// Libellé affiché à droite pour le modèle/nom matériel (ex: Shelly Plug S Gen3).
  ///
  /// In fr, this message translates to:
  /// **'Modèle'**
  String get detailsDeviceModelRightLabel;

  /// Tooltip de l'icône pour modifier le nom de l'équipement.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le nom'**
  String get detailsEditNameTooltip;

  /// Tooltip de l'icône crayon à côté de l'IP locale.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'IP locale'**
  String get detailsEditIpTooltip;

  /// Tooltip de l'icône dropdown pour le type d'équipement.
  ///
  /// In fr, this message translates to:
  /// **'Choisir le type'**
  String get detailsSelectTypeTooltip;

  /// Tooltip du bouton favori (coeur) sur la page détails.
  ///
  /// In fr, this message translates to:
  /// **'Basculer en favori'**
  String get detailsToggleFavoriteTooltip;

  /// Libellé de ligne pour le statut réseau/connexion dans la zone infos.
  ///
  /// In fr, this message translates to:
  /// **'Statut réseau'**
  String get detailsConnectionStatusLabel;

  /// Texte court indiquant une connexion Wi-Fi active.
  ///
  /// In fr, this message translates to:
  /// **'Connecté (Wi-Fi)'**
  String get detailsConnectedWifiShort;

  /// Texte court indiquant que l'équipement est hors ligne.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecté'**
  String get detailsDisconnectedShort;

  /// Tooltip du dropdown pièce (bas de carte).
  ///
  /// In fr, this message translates to:
  /// **'Choisir la pièce'**
  String get detailsRoomDropdownTooltip;

  /// Libellé du bouton supprimer sur la page détails (si tu veux un libellé spécifique à cette page).
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get detailsActionDelete;

  /// Titre de la boîte de dialogue permettant de modifier le nom donné par l'utilisateur sur la page détails.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le nom de l\'équipement'**
  String get detailsEditNameDialogTitle;

  /// Exemple affiché dans le champ de saisie lors de la modification du nom de l'équipement.
  ///
  /// In fr, this message translates to:
  /// **'ex : Plug'**
  String get detailsEditNameHint;

  /// Titre de la boîte de dialogue permettant de modifier l'adresse IP locale de l'équipement sur la page détails.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'IP locale'**
  String get detailsEditIpDialogTitle;

  /// Exemple affiché dans le champ de saisie lors de la modification de l'IP locale.
  ///
  /// In fr, this message translates to:
  /// **'ex : 192.168.1.37'**
  String get detailsEditIpHint;

  /// Affiché quand l'équipement n'est associé à aucune pièce ou que la pièce n'est pas résolue.
  ///
  /// In fr, this message translates to:
  /// **'Pièce inconnue'**
  String get detailsRoomUnknown;

  /// Affiché quand le libellé du modèle matériel n'est pas disponible.
  ///
  /// In fr, this message translates to:
  /// **'Modèle inconnu'**
  String get detailsDeviceModelUnknown;

  /// Libellé affiché quand le graphique d'historique n'a pas assez de points pour être tracé.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée'**
  String get detailsChartNoData;

  /// Libellé de la timeline pour le dernier repère du graphique.
  ///
  /// In fr, this message translates to:
  /// **'Maintenant'**
  String get detailsTimelineTickNow;

  /// Libellé du chip de plage historique : 1 jour
  ///
  /// In fr, this message translates to:
  /// **'1J'**
  String get historyRange1d;

  /// Libellé du chip de plage historique : 1 semaine
  ///
  /// In fr, this message translates to:
  /// **'1S'**
  String get historyRange1w;

  /// Libellé du chip de plage historique : 1 mois
  ///
  /// In fr, this message translates to:
  /// **'1M'**
  String get historyRange1m;

  /// Libellé du chip de plage historique : 1 an
  ///
  /// In fr, this message translates to:
  /// **'1A'**
  String get historyRange1y;

  /// Libellé du chip de plage historique : plage maximale
  ///
  /// In fr, this message translates to:
  /// **'Max'**
  String get historyRangeMax;

  /// Unité courte pour les watts
  ///
  /// In fr, this message translates to:
  /// **'W'**
  String get unitWattShort;

  /// Message de confirmation pour supprimer l'équipement
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cet équipement ? Cette action est irréversible.'**
  String get confirmDeleteEquipment;

  /// Displayed when a device was updated less than 10 seconds ago.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour à l\'instant'**
  String get updatedJustNow;

  /// Message informant de la dernière mise à jour en secondes de l'équipement.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour il y a {seconds}s'**
  String updatedSecondsAgo(int seconds);

  /// Message informant de la dernière mise à jour en minutes de l'équipement.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour il y a {minutes} min'**
  String updatedMinutesAgo(int minutes);

  /// Message informant de la dernière mise à jour en heures de l'équipement.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour il y a {hours} h'**
  String updatedHoursAgo(int hours);

  /// Titre de bienvenue affiché dans l'en-tête de la page d'accueil
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get homeWelcomeTitle;

  /// Nom par défaut du groupe de pièces affiché dans l'en-tête d'accueil
  ///
  /// In fr, this message translates to:
  /// **'Maison #1'**
  String get homeDefaultAreaGroupName;

  /// Résumé de connectivité affiché dans l'en-tête d'accueil
  ///
  /// In fr, this message translates to:
  /// **'{onlineCount} équipements connectés · {offlineCount} hors ligne'**
  String homeConnectionSummary(int onlineCount, int offlineCount);

  /// Titre de la page listant les équipements favoris
  ///
  /// In fr, this message translates to:
  /// **'Liste des favoris'**
  String get favoritesPageTitle;

  /// Tooltip du bouton pour retirer un équipement des favoris
  ///
  /// In fr, this message translates to:
  /// **'Retirer des favoris'**
  String get favoriteRemoveTooltip;

  /// Libellé affiché en haut à droite de la page favoris pour l'état du filtre actif
  ///
  /// In fr, this message translates to:
  /// **'Actif(s) : Tous'**
  String get favoritesActiveFilterLabel;

  /// Tooltip du bouton d'ouverture des filtres sur la page favoris
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les filtres des favoris'**
  String get favoritesFilterTooltip;

  /// Tooltip du bouton rond permettant d'ajouter un favori sur la page favoris
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un favori'**
  String get favoritesAddTooltip;

  /// Texte d'aide du champ de recherche sur la page favoris
  ///
  /// In fr, this message translates to:
  /// **'Rechercher des appareils...'**
  String get favoritesSearchHint;

  /// Ligne de stats : nombre d'appareils en ligne sur le total
  ///
  /// In fr, this message translates to:
  /// **'{online} / {total} en ligne'**
  String favoritesOnlineOf(int online, int total);

  /// Ligne de stats : nombre de pièces dans le groupe actif
  ///
  /// In fr, this message translates to:
  /// **'{count} pièces'**
  String favoritesRoomsCount(int count);

  /// Titre de section de la liste des pièces affichée sur la page d'accueil
  ///
  /// In fr, this message translates to:
  /// **'Areas'**
  String get roomsSectionTitle;

  /// Titre de la page listant les ensembles de pièces et leurs pièces
  ///
  /// In fr, this message translates to:
  /// **'Liste des pièces'**
  String get roomsPageTitle;

  /// Libellé affiché en haut à droite de la page des pièces pour l'état du filtre actif
  ///
  /// In fr, this message translates to:
  /// **'Actif(s) : Tous'**
  String get roomsActiveFilterLabel;

  /// Tooltip du bouton d'ouverture des filtres sur la page des pièces
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les filtres des pièces'**
  String get roomsFilterTooltip;

  /// Texte affiché quand aucun ensemble de pièces n'existe encore
  ///
  /// In fr, this message translates to:
  /// **'Aucun ensemble de pièces pour le moment'**
  String get roomsEmptyState;

  /// Titre du dialogue d'ajout d'un ensemble de pièces
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un ensemble'**
  String get roomsAddGroupTitle;

  /// Titre du dialogue de renommage d'un ensemble de pièces
  ///
  /// In fr, this message translates to:
  /// **'Renommer l\'ensemble'**
  String get roomsRenameGroupTitle;

  /// Placeholder du champ de saisie du nom d'un ensemble de pièces
  ///
  /// In fr, this message translates to:
  /// **'Ex. Maison, Appartement'**
  String get roomsGroupNameHint;

  /// Titre du dialogue d'ajout d'une pièce
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une pièce'**
  String get roomsAddRoomTitle;

  /// Titre du dialogue de renommage d'une pièce
  ///
  /// In fr, this message translates to:
  /// **'Renommer la pièce'**
  String get roomsRenameRoomTitle;

  /// Placeholder du champ de saisie du nom d'une pièce
  ///
  /// In fr, this message translates to:
  /// **'Ex. Salon, Cuisine'**
  String get roomsRoomNameHint;

  /// Tooltip du bouton permettant d'ajouter un ensemble de pièces
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un ensemble de pièces'**
  String get roomsAddGroupTooltip;

  /// Tooltip du bouton permettant d'ajouter une pièce dans un ensemble
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une pièce'**
  String get roomsAddRoomTooltip;

  /// Tooltip du bouton permettant de renommer un ensemble de pièces
  ///
  /// In fr, this message translates to:
  /// **'Renommer l\'ensemble'**
  String get roomsRenameGroupTooltip;

  /// Tooltip du bouton permettant de supprimer un ensemble de pièces
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'ensemble'**
  String get roomsDeleteGroupTooltip;

  /// Tooltip du bouton permettant de supprimer une pièce
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la pièce'**
  String get roomsDeleteRoomTooltip;

  /// Titre du dialogue de confirmation de suppression d'un ensemble de pièces
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'ensemble'**
  String get roomsDeleteGroupTitle;

  /// Message de confirmation pour supprimer un ensemble vide
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'ensemble « {groupName} » ?'**
  String roomsDeleteEmptyGroupMessage(String groupName);

  /// Message de confirmation pour supprimer un ensemble contenant des pièces
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'ensemble « {groupName} » et ses {roomCount} pièce(s) ?'**
  String roomsDeleteGroupWithRoomsMessage(String groupName, int roomCount);

  /// Titre du dialogue de confirmation de suppression d'une pièce
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la pièce'**
  String get roomsDeleteRoomTitle;

  /// Message de confirmation pour supprimer une pièce
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la pièce « {roomName} » ?'**
  String roomsDeleteRoomMessage(String roomName);

  /// Message affiché dans le quick add de pièce quand aucun ensemble de pièces n'existe encore
  ///
  /// In fr, this message translates to:
  /// **'Vous devez d\'abord créer un ensemble de pièces avant d\'ajouter une pièce.'**
  String get roomsNoGroupForQuickAdd;

  /// Label du champ de saisie pour créer un premier ensemble de pièces depuis le quick add
  ///
  /// In fr, this message translates to:
  /// **'Premier ensemble'**
  String get roomsFirstGroupLabel;

  /// Texte du bouton permettant de créer le premier ensemble de pièces depuis le quick add
  ///
  /// In fr, this message translates to:
  /// **'Créer le premier ensemble'**
  String get roomsCreateFirstGroup;

  /// Label du sélecteur du groupe cible quand on ajoute une pièce
  ///
  /// In fr, this message translates to:
  /// **'Ensemble cible'**
  String get roomsTargetGroupLabel;

  /// Message d'erreur affiché quand aucun groupe cible n'est sélectionné pour ajouter une pièce
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez un ensemble de pièces'**
  String get roomsTargetGroupRequired;

  /// Libellé affiché dans l'en-tête de la home quand aucun ensemble de pièces n'est sélectionné
  ///
  /// In fr, this message translates to:
  /// **'Aucun ensemble'**
  String get homeNoActiveRoomGroup;

  /// Titre du bottom sheet permettant de choisir l'ensemble de pièces actif sur la home
  ///
  /// In fr, this message translates to:
  /// **'Choisir un ensemble'**
  String get homeSelectRoomGroupTitle;

  /// Message affiché dans la page des pièces lorsqu'aucun ensemble actif n'est sélectionné
  ///
  /// In fr, this message translates to:
  /// **'Aucun ensemble de pièces actif. Sélectionnez-en un depuis l\'accueil.'**
  String get roomsNoActiveGroupSelected;

  /// Message affiché dans la page des pièces lorsque l'ensemble actif ne contient encore aucune pièce
  ///
  /// In fr, this message translates to:
  /// **'Aucune pièce pour l\'ensemble « {groupName} ».'**
  String roomsEmptyForGroup(String groupName);

  /// Label du champ de saisie du nom d'un ensemble de pièces
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'ensemble'**
  String get roomsGroupNameFieldLabel;

  /// Message d'erreur affiché quand le nom d'un ensemble de pièces est vide
  ///
  /// In fr, this message translates to:
  /// **'Saisissez un nom d\'ensemble'**
  String get validationRoomGroupNameRequired;

  /// Titre du bottom sheet listant les pièces existantes à ajouter à un ensemble
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une pièce'**
  String get roomsAddRoomSheetTitle;

  /// Libellé de la ligne d'action pour créer une nouvelle pièce depuis le sheet d'ajout
  ///
  /// In fr, this message translates to:
  /// **'Créer une nouvelle pièce'**
  String get roomsCreateNewRoom;

  /// Message affiché dans le sheet d'ajout quand il n'y a pas de pièces d'autres ensembles à ajouter
  ///
  /// In fr, this message translates to:
  /// **'Aucune autre pièce disponible'**
  String get roomsNoAvailableRooms;

  /// Nombre d'équipements affiché dans la pilule d'une pièce sur la page des pièces
  ///
  /// In fr, this message translates to:
  /// **'({count} équipements)'**
  String roomsEquipmentCount(int count);

  /// Titre du bottom sheet pour ajouter un widget de statistiques
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un widget'**
  String get statsAddWidgetTitle;

  /// Option pour ajouter un widget graphique
  ///
  /// In fr, this message translates to:
  /// **'Graphique'**
  String get statsAddChart;

  /// Option pour ajouter un widget tableau
  ///
  /// In fr, this message translates to:
  /// **'Tableau'**
  String get statsAddTable;

  /// Option pour ajouter un widget historique
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get statsAddHistory;

  /// Option pour ajouter un widget KPI
  ///
  /// In fr, this message translates to:
  /// **'KPI'**
  String get statsAddKpi;

  /// Message affiché quand le dashboard de stats est vide
  ///
  /// In fr, this message translates to:
  /// **'Aucun widget. Ajoutez-en un pour commencer.'**
  String get statsNoWidgets;

  /// Titre du dialogue de configuration du widget
  ///
  /// In fr, this message translates to:
  /// **'Configurer le widget'**
  String get statsConfigTitle;

  /// Libellé du sélecteur de métrique dans la config du widget
  ///
  /// In fr, this message translates to:
  /// **'Métrique'**
  String get statsMetricLabel;

  /// Libellé du sélecteur de période dans la config du widget
  ///
  /// In fr, this message translates to:
  /// **'Période'**
  String get statsTimeRangeLabel;

  /// Libellé du sélecteur de type de graphique dans la config du widget
  ///
  /// In fr, this message translates to:
  /// **'Type de graphique'**
  String get statsChartTypeLabel;

  /// Libellé de période : 1 jour
  ///
  /// In fr, this message translates to:
  /// **'1 Jour'**
  String get statsTimeRangeDay;

  /// Libellé de période : 1 semaine
  ///
  /// In fr, this message translates to:
  /// **'1 Semaine'**
  String get statsTimeRangeWeek;

  /// Libellé de période : 1 mois
  ///
  /// In fr, this message translates to:
  /// **'1 Mois'**
  String get statsTimeRangeMonth;

  /// Libellé de période : 1 an
  ///
  /// In fr, this message translates to:
  /// **'1 An'**
  String get statsTimeRangeYear;

  /// Libellé de période : maximum
  ///
  /// In fr, this message translates to:
  /// **'Max'**
  String get statsTimeRangeMax;

  /// Affiché quand il n'y a pas de données à montrer
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée'**
  String get statsNoData;

  /// Libellé du menu déroulant de l'équipement dans le dialogue de configuration
  ///
  /// In fr, this message translates to:
  /// **'Équipement'**
  String get statsDeviceLabel;

  /// Message snackbar quand l'utilisateur essaie d'ajouter un widget mais la pièce sélectionnée n'a aucun équipement
  ///
  /// In fr, this message translates to:
  /// **'Aucun équipement dans cette pièce'**
  String get statsNoDevicesInRoom;

  /// Titre du dialogue de modification du widget
  ///
  /// In fr, this message translates to:
  /// **'Modifier le widget'**
  String get statsEditWidget;

  /// Bouton pour supprimer un widget
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le widget'**
  String get statsDeleteWidget;

  /// Message de confirmation avant suppression d'un widget
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce widget ?'**
  String get statsDeleteConfirm;

  /// Texte d'indication sous l'icône d'état vide
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur + pour ajouter votre premier widget'**
  String get statsEmptyHint;

  /// Message snackbar quand aucun appareil ne supporte le type de widget
  ///
  /// In fr, this message translates to:
  /// **'Aucun appareil compatible pour ce type de widget'**
  String get statsNoCompatibleDevice;

  /// Libellé pour le type prise connectée
  ///
  /// In fr, this message translates to:
  /// **'Prise connectée'**
  String get statsDeviceTypeSmartPlug;

  /// Libellé pour le type appareil générique
  ///
  /// In fr, this message translates to:
  /// **'Appareil'**
  String get statsDeviceTypeGeneric;

  /// Nombre de widgets dans un groupe d'appareils
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 widget} other{{count} widgets}}'**
  String statsWidgetCount(int count);

  /// Titre de la bottom sheet d'ajout TV
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une TV'**
  String get tvAddTitle;

  /// Nom par défaut d'une TV
  ///
  /// In fr, this message translates to:
  /// **'Smart TV'**
  String get tvDefaultName;

  /// Exemple de nom pour la TV
  ///
  /// In fr, this message translates to:
  /// **'ex : Samsung Salon'**
  String get tvNameHint;

  /// Message d'erreur si le test WS échoue
  ///
  /// In fr, this message translates to:
  /// **'Connexion échouée'**
  String get tvTestFailed;

  /// Confirmation de suppression TV
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette TV ?'**
  String get tvDeleteConfirm;

  /// Bouton de reconnexion TV
  ///
  /// In fr, this message translates to:
  /// **'Reconnecter'**
  String get tvReconnect;

  /// État TV : connecté
  ///
  /// In fr, this message translates to:
  /// **'Connecté'**
  String get tvStatusConnected;

  /// État TV : en cours de connexion
  ///
  /// In fr, this message translates to:
  /// **'Connexion…'**
  String get tvStatusConnecting;

  /// État TV : déconnecté
  ///
  /// In fr, this message translates to:
  /// **'Déconnecté'**
  String get tvStatusDisconnected;

  /// Touche télécommande : éteindre
  ///
  /// In fr, this message translates to:
  /// **'Éteindre'**
  String get tvKeyPower;

  /// Touche télécommande : volume haut
  ///
  /// In fr, this message translates to:
  /// **'Volume +'**
  String get tvKeyVolUp;

  /// Touche télécommande : volume bas
  ///
  /// In fr, this message translates to:
  /// **'Volume −'**
  String get tvKeyVolDown;

  /// Touche télécommande : muet
  ///
  /// In fr, this message translates to:
  /// **'Muet'**
  String get tvKeyMute;

  /// Touche télécommande : haut
  ///
  /// In fr, this message translates to:
  /// **'Haut'**
  String get tvKeyUp;

  /// Touche télécommande : bas
  ///
  /// In fr, this message translates to:
  /// **'Bas'**
  String get tvKeyDown;

  /// Touche télécommande : gauche
  ///
  /// In fr, this message translates to:
  /// **'Gauche'**
  String get tvKeyLeft;

  /// Touche télécommande : droite
  ///
  /// In fr, this message translates to:
  /// **'Droite'**
  String get tvKeyRight;

  /// Touche télécommande : retour
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get tvKeyBack;

  /// Touche télécommande : accueil
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get tvKeyHome;

  /// Touche télécommande : menu
  ///
  /// In fr, this message translates to:
  /// **'Menu'**
  String get tvKeyMenu;

  /// Touche télécommande : clavier
  ///
  /// In fr, this message translates to:
  /// **'Clavier'**
  String get tvKeyKeyboard;

  /// Touche télécommande : changer source
  ///
  /// In fr, this message translates to:
  /// **'Source'**
  String get tvKeySource;

  /// Titre de la section applications TV
  ///
  /// In fr, this message translates to:
  /// **'Applications :'**
  String get tvAppsTitle;

  /// Type d'équipement : TV connectée
  ///
  /// In fr, this message translates to:
  /// **'TV Connectée'**
  String get tvTypeSmartTv;

  /// Modèle TV par défaut
  ///
  /// In fr, this message translates to:
  /// **'Samsung'**
  String get tvDefaultModel;

  /// État TV connecté en wifi
  ///
  /// In fr, this message translates to:
  /// **'Connected (wi-fi)'**
  String get tvStatusConnectedWifi;

  /// Label champ modèle TV
  ///
  /// In fr, this message translates to:
  /// **'Modèle'**
  String get tvModelLabel;

  /// Exemple de modèle TV
  ///
  /// In fr, this message translates to:
  /// **'ex : Samsung 55Q80B'**
  String get tvModelHint;

  /// Saisie vocale : en écoute
  ///
  /// In fr, this message translates to:
  /// **'À l\'écoute…'**
  String get tvVoiceListening;

  /// Saisie vocale : appuyer pour démarrer
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur le micro pour réessayer'**
  String get tvVoiceTap;

  /// Erreur saisie vocale
  ///
  /// In fr, this message translates to:
  /// **'Microphone indisponible'**
  String get tvVoiceError;

  /// Touche télécommande : paramètres / menu
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get tvKeySettings;

  /// Indication champ clavier
  ///
  /// In fr, this message translates to:
  /// **'Texte à envoyer à la TV…'**
  String get tvKeyboardHint;

  /// Bouton envoi clavier
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get tvKeyboardSend;

  /// Titre du sélecteur de type d'appareil
  ///
  /// In fr, this message translates to:
  /// **'Type d\'appareil'**
  String get addDeviceTypeTitle;

  /// Type d'appareil : prise connectée
  ///
  /// In fr, this message translates to:
  /// **'Prise connectée'**
  String get deviceTypePlug;

  /// Type d'appareil : TV connectée
  ///
  /// In fr, this message translates to:
  /// **'TV connectée'**
  String get deviceTypeTv;

  /// No description provided for @deviceTypeCobLedRgb.
  ///
  /// In fr, this message translates to:
  /// **'Bandeau LED WLED'**
  String get deviceTypeCobLedRgb;

  /// Type d'appareil : lampe LED CCT à blanc réglable
  ///
  /// In fr, this message translates to:
  /// **'Éclairage LED CCT'**
  String get deviceTypeCobLedCct;

  /// No description provided for @cobLedRgbAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un appareil WLED'**
  String get cobLedRgbAddTitle;

  /// No description provided for @cobLedRgbDefaultName.
  ///
  /// In fr, this message translates to:
  /// **'Bandeau LED'**
  String get cobLedRgbDefaultName;

  /// No description provided for @cobLedRgbNameHint.
  ///
  /// In fr, this message translates to:
  /// **'ex : LEDs Salon'**
  String get cobLedRgbNameHint;

  /// No description provided for @cobLedRgbModelHint.
  ///
  /// In fr, this message translates to:
  /// **'ex : WLED v0.14'**
  String get cobLedRgbModelHint;

  /// No description provided for @cobLedRgbTestFailed.
  ///
  /// In fr, this message translates to:
  /// **'Connexion échouée'**
  String get cobLedRgbTestFailed;

  /// No description provided for @cobLedRgbDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cet appareil ?'**
  String get cobLedRgbDeleteConfirm;

  /// No description provided for @cobLedRgbBrightnessLabel.
  ///
  /// In fr, this message translates to:
  /// **'Luminosité'**
  String get cobLedRgbBrightnessLabel;

  /// No description provided for @cobLedRgbSpeedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Vitesse'**
  String get cobLedRgbSpeedLabel;

  /// No description provided for @cobLedRgbIntensityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Intensité'**
  String get cobLedRgbIntensityLabel;

  /// No description provided for @cobLedRgbColorsTab.
  ///
  /// In fr, this message translates to:
  /// **'Couleurs'**
  String get cobLedRgbColorsTab;

  /// No description provided for @cobLedRgbEffectsTab.
  ///
  /// In fr, this message translates to:
  /// **'Effets'**
  String get cobLedRgbEffectsTab;

  /// No description provided for @cobLedRgbScenesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Scènes'**
  String get cobLedRgbScenesLabel;

  /// Titre de l'écran détail prise connectée
  ///
  /// In fr, this message translates to:
  /// **'{name}'**
  String smartPlugDetailTitle(String name);

  /// Type d'appareil dans l'en-tête
  ///
  /// In fr, this message translates to:
  /// **'Prise connectée'**
  String get smartPlugSubtitle;

  /// Statut prise connectée: en ligne
  ///
  /// In fr, this message translates to:
  /// **'en ligne'**
  String get smartPlugOnline;

  /// Statut prise connectée: hors ligne
  ///
  /// In fr, this message translates to:
  /// **'hors ligne'**
  String get smartPlugOffline;

  /// Unité de puissance — watts
  ///
  /// In fr, this message translates to:
  /// **'W'**
  String get smartPlugKpiUnit;

  /// Coût estimé par heure
  ///
  /// In fr, this message translates to:
  /// **'≈ {cost} €/h'**
  String smartPlugCostPerHour(String cost);

  /// Coût estimé aujourd'hui
  ///
  /// In fr, this message translates to:
  /// **'≈ {cost}€ aujourd\'hui'**
  String smartPlugCostToday(String cost);

  /// Énergie cumulée en kWh
  ///
  /// In fr, this message translates to:
  /// **'{kwh} kWh cumulés'**
  String smartPlugKwhCumulated(String kwh);

  /// Titre section consommation
  ///
  /// In fr, this message translates to:
  /// **'Consommation'**
  String get smartPlugSectionConsumption;

  /// Titre section chronologie
  ///
  /// In fr, this message translates to:
  /// **'Chronologie'**
  String get smartPlugSectionTimeline;

  /// Sous-titre chronologie
  ///
  /// In fr, this message translates to:
  /// **'On/off dernières 24h'**
  String get smartPlugTimelineSubtitle;

  /// Titre section alertes
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get smartPlugSectionAlerts;

  /// Placeholder aucune alerte
  ///
  /// In fr, this message translates to:
  /// **'Aucun seuil configuré'**
  String get smartPlugNoAlerts;

  /// Titre section informations
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get smartPlugSectionInformations;

  /// Label IP locale
  ///
  /// In fr, this message translates to:
  /// **'IP locale'**
  String get smartPlugInfoLocalIp;

  /// Label modèle
  ///
  /// In fr, this message translates to:
  /// **'Modèle'**
  String get smartPlugInfoModel;

  /// Label type de connexion
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get smartPlugInfoConnection;

  /// Valeur connexion Wi-Fi
  ///
  /// In fr, this message translates to:
  /// **'Wi-Fi'**
  String get smartPlugWifi;

  /// Bouton changer de pièce
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get smartPlugChangeRoom;

  /// Menu: actualiser
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get smartPlugMenuRefresh;

  /// Menu: modifier
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get smartPlugMenuEdit;

  /// Menu: supprimer
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get smartPlugMenuDelete;

  /// Titre confirmation suppression
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'équipement ?'**
  String get smartPlugDeleteConfirmTitle;

  /// Corps confirmation suppression
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible.'**
  String get smartPlugDeleteConfirmBody;

  /// Annuler la suppression
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get smartPlugDeleteConfirmCancel;

  /// Confirmer la suppression
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get smartPlugDeleteConfirmConfirm;

  /// Bannière affichée quand la prise est hors ligne
  ///
  /// In fr, this message translates to:
  /// **'Dernières valeurs connues'**
  String get smartPlugLastKnownValues;

  /// Titre du dialogue pour modifier le prix du kWh
  ///
  /// In fr, this message translates to:
  /// **'Prix de l\'électricité'**
  String get smartPlugEditKwhPriceTitle;

  /// Titre du bottom sheet d'ajout d'alerte
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une alerte'**
  String get smartPlugAlertSheetTitle;

  /// Label au-dessus des chips de condition
  ///
  /// In fr, this message translates to:
  /// **'Type d\'alerte'**
  String get smartPlugAlertConditionLabel;

  /// Chip condition: seuil en watts
  ///
  /// In fr, this message translates to:
  /// **'Consommation (W)'**
  String get smartPlugAlertConditionWatts;

  /// Chip condition: seuil coût journalier
  ///
  /// In fr, this message translates to:
  /// **'Coût journalier (€)'**
  String get smartPlugAlertConditionDailyCost;

  /// Label au-dessus du champ de seuil
  ///
  /// In fr, this message translates to:
  /// **'Seuil'**
  String get smartPlugAlertThresholdLabel;

  /// Hint pour le seuil en watts
  ///
  /// In fr, this message translates to:
  /// **'ex. 2500'**
  String get smartPlugAlertThresholdHintWatts;

  /// Hint pour le seuil de coût journalier
  ///
  /// In fr, this message translates to:
  /// **'ex. 1,50'**
  String get smartPlugAlertThresholdHintCost;

  /// Label au-dessus des chips de notification
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get smartPlugAlertNotificationsLabel;

  /// Chip notification: notification push
  ///
  /// In fr, this message translates to:
  /// **'Push'**
  String get smartPlugAlertNotifPush;

  /// Chip notification: bannière in-app
  ///
  /// In fr, this message translates to:
  /// **'Bannière'**
  String get smartPlugAlertNotifBanner;

  /// Erreur de validation: aucun type de notification sélectionné
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez au moins un type de notification'**
  String get smartPlugAlertNotifRequired;

  /// Type d'appareil TV dans l'en-tête de détail
  ///
  /// In fr, this message translates to:
  /// **'Télécommande'**
  String get tvSubtitle;

  /// Statut TV : en ligne
  ///
  /// In fr, this message translates to:
  /// **'en ligne'**
  String get tvOnline;

  /// Statut TV : hors ligne
  ///
  /// In fr, this message translates to:
  /// **'hors ligne'**
  String get tvOffline;

  /// Label affiché sous le nom de la source actuelle
  ///
  /// In fr, this message translates to:
  /// **'Source active'**
  String get tvSourceActive;

  /// Titre de la carte section télécommande
  ///
  /// In fr, this message translates to:
  /// **'Télécommande'**
  String get tvSectionRemote;

  /// Titre de la carte section applications
  ///
  /// In fr, this message translates to:
  /// **'Applications'**
  String get tvSectionApplications;

  /// Titre de la carte section informations
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get tvSectionInformations;

  /// Menu TV : actualiser
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get tvMenuRefresh;

  /// Menu TV : modifier
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get tvMenuEdit;

  /// Menu TV : supprimer
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get tvMenuDelete;

  /// Titre de la confirmation de suppression TV
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la TV ?'**
  String get tvDeleteConfirmTitle;

  /// Corps de la confirmation de suppression TV
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible.'**
  String get tvDeleteConfirmBody;

  /// Bouton annuler la suppression TV
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get tvDeleteConfirmCancel;

  /// Bouton confirmer la suppression TV
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get tvDeleteConfirmConfirm;

  /// Bannière affichée sur le détail TV quand déconnecté
  ///
  /// In fr, this message translates to:
  /// **'Dernières valeurs connues'**
  String get tvLastKnownValues;

  /// Titre de carte section : lecture en direct
  ///
  /// In fr, this message translates to:
  /// **'EN DIRECT'**
  String get detailSectionLive;

  /// Titre de carte section : graphique historique
  ///
  /// In fr, this message translates to:
  /// **'HISTORIQUE'**
  String get detailSectionHistoric;

  /// Titre de carte section : informations appareil
  ///
  /// In fr, this message translates to:
  /// **'INFORMATIONS'**
  String get detailSectionInformations;

  /// Titre de carte section : alertes configurées
  ///
  /// In fr, this message translates to:
  /// **'ALERTES'**
  String get detailSectionAlerts;

  /// Titre de carte section : température (hygromètre)
  ///
  /// In fr, this message translates to:
  /// **'TEMPÉRATURE'**
  String get detailSectionTemperature;

  /// Label stat box : valeur minimale
  ///
  /// In fr, this message translates to:
  /// **'MIN'**
  String get detailStatMin;

  /// Label stat box : valeur maximale
  ///
  /// In fr, this message translates to:
  /// **'MAX'**
  String get detailStatMax;

  /// Label stat box : moyenne hebdomadaire
  ///
  /// In fr, this message translates to:
  /// **'Moy. semaine'**
  String get detailStatAvgWeek;

  /// Label stat box : moyenne mensuelle
  ///
  /// In fr, this message translates to:
  /// **'Moy. mois'**
  String get detailStatAvgMonth;

  /// Label stat box : écart min/max journalier
  ///
  /// In fr, this message translates to:
  /// **'Amplitude'**
  String get detailStatAmplitude;

  /// Label période stat box : aujourd'hui
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get detailStatToday;

  /// Label ligne info : statut de l'appareil
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get detailInfoStatus;

  /// Indicateur de tendance : température en hausse
  ///
  /// In fr, this message translates to:
  /// **'Tendance : hausse'**
  String get detailTrendRising;

  /// Indicateur de tendance : température en baisse
  ///
  /// In fr, this message translates to:
  /// **'Tendance : baisse'**
  String get detailTrendFalling;

  /// Indicateur de tendance : humidité en hausse
  ///
  /// In fr, this message translates to:
  /// **'Tendance : montée'**
  String get detailTrendUpward;

  /// Indicateur de tendance : humidité en baisse
  ///
  /// In fr, this message translates to:
  /// **'Tendance : descente'**
  String get detailTrendDownward;

  /// Label type appareil : thermomètre
  ///
  /// In fr, this message translates to:
  /// **'Thermomètre'**
  String get thermometerTypeLabel;

  /// Label type appareil : hygromètre
  ///
  /// In fr, this message translates to:
  /// **'Hygromètre'**
  String get hygrometerTypeLabel;

  /// Label type appareil : bandeau LED RGB
  ///
  /// In fr, this message translates to:
  /// **'COB LED RGB'**
  String get cobLedRgbTypeLabel;

  /// Label type appareil : éclairage COB LED CCT
  ///
  /// In fr, this message translates to:
  /// **'COB LED CCT'**
  String get cobLedCctTypeLabel;

  /// Bannière affichée quand un appareil est hors ligne
  ///
  /// In fr, this message translates to:
  /// **'Appareil hors ligne'**
  String get deviceOfflineBanner;

  /// Affiché quand l'identifiant de l'appareil est introuvable
  ///
  /// In fr, this message translates to:
  /// **'Appareil introuvable'**
  String get deviceNotFound;

  /// Titre de carte section : contrôles luminosité
  ///
  /// In fr, this message translates to:
  /// **'LUMINOSITÉ'**
  String get cobLedSectionLuminosity;

  /// Titre de carte section : contrôles effets WLED
  ///
  /// In fr, this message translates to:
  /// **'CONTRÔLES WLED'**
  String get cobLedSectionWledControls;

  /// Titre de carte section : sélecteur de couleur
  ///
  /// In fr, this message translates to:
  /// **'COULEUR'**
  String get cobLedRgbSectionColor;

  /// Titre de carte section : contrôles température de couleur
  ///
  /// In fr, this message translates to:
  /// **'TEMPÉRATURE DE COULEUR'**
  String get cobLedCctSectionColourTemp;

  /// Titre du dialogue pour enregistrer l'état CCT comme modèle
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer comme modèle'**
  String get cobLedCctSaveAsTemplateTitle;

  /// Texte indicatif du champ nom de modèle
  ///
  /// In fr, this message translates to:
  /// **'Nom du modèle'**
  String get cobLedCctTemplateNameHint;

  /// Texte indicatif du champ nom d'appareil CCT
  ///
  /// In fr, this message translates to:
  /// **'ex. ESP32 CCT Controller'**
  String get cobLedCctDeviceHint;

  /// Chip condition alerte : déclencher si valeur au-dessus du seuil
  ///
  /// In fr, this message translates to:
  /// **'Au-dessus'**
  String get sensorAlertConditionAbove;

  /// Chip condition alerte : déclencher si valeur en dessous du seuil
  ///
  /// In fr, this message translates to:
  /// **'En dessous'**
  String get sensorAlertConditionBelow;

  /// Label sous la barre de confort de l'hygromètre
  ///
  /// In fr, this message translates to:
  /// **'Zone de confort : 40 % – 60 %'**
  String get hygrometerComfortRangeLabel;

  /// Label stat box : niveau de confort actuel
  ///
  /// In fr, this message translates to:
  /// **'Confort'**
  String get hygrometerStatComfort;

  /// Titre de section page d'accueil : résumé du jour
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get homeSectionToday;

  /// Label KPI section aujourd'hui : consommation totale
  ///
  /// In fr, this message translates to:
  /// **'Consommation'**
  String get homeTodayConsumptionLabel;

  /// Label KPI section aujourd'hui : température moyenne
  ///
  /// In fr, this message translates to:
  /// **'Temp. moy.'**
  String get homeTodayAvgTempLabel;

  /// Label KPI section aujourd'hui : humidité
  ///
  /// In fr, this message translates to:
  /// **'Humidité'**
  String get homeTodayHumidityLabel;

  /// Chip filtre onglet appareils : tous les types
  ///
  /// In fr, this message translates to:
  /// **'Tous les types'**
  String get equipmentsFilterAllTypes;

  /// Chip filtre pièce : toutes les pièces avec nombre d'appareils
  ///
  /// In fr, this message translates to:
  /// **'Toutes les pièces ({count})'**
  String equipmentsRoomAll(int count);

  /// Chip filtre pièce : nom de pièce avec nombre d'appareils
  ///
  /// In fr, this message translates to:
  /// **'{name} ({count})'**
  String equipmentsRoomItem(String name, int count);

  /// Texte indicatif de la barre de recherche dans l'onglet appareils
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un appareil...'**
  String get equipmentsSearchHint;

  /// Chip section zones : toutes les pièces avec nombre d'appareils
  ///
  /// In fr, this message translates to:
  /// **'Toutes les pièces ({count})'**
  String areasAllRooms(int count);

  /// Chip section zones : nom de pièce avec nombre d'appareils
  ///
  /// In fr, this message translates to:
  /// **'{name} ({count})'**
  String areasRoomItem(String name, int count);

  /// État vide section zones : aucune pièce configurée
  ///
  /// In fr, this message translates to:
  /// **'Aucune pièce configurée.'**
  String get areasNoRooms;

  /// État vide section zones : pièce sans appareil
  ///
  /// In fr, this message translates to:
  /// **'Aucun appareil dans cette pièce.'**
  String get areasNoDevices;

  /// Barre de puissance : appareil allumé
  ///
  /// In fr, this message translates to:
  /// **'ON'**
  String get deviceStatusOn;

  /// Barre de puissance : appareil éteint
  ///
  /// In fr, this message translates to:
  /// **'OFF'**
  String get deviceStatusOff;

  /// Snackbar affiché quand une couleur hex est copiée
  ///
  /// In fr, this message translates to:
  /// **'{hex} copié'**
  String colorCopiedSnack(String hex);

  /// Label au-dessus du menu déroulant d'effets WLED
  ///
  /// In fr, this message translates to:
  /// **'Effet'**
  String get cobLedEffectLabel;

  /// Label curseur : vitesse de l'effet
  ///
  /// In fr, this message translates to:
  /// **'Vitesse'**
  String get cobLedSpeedLabel;

  /// Label curseur : intensité de l'effet
  ///
  /// In fr, this message translates to:
  /// **'Intensité'**
  String get cobLedIntensityLabel;

  /// Label toggle : mode réactif audio
  ///
  /// In fr, this message translates to:
  /// **'Réactif au son'**
  String get cobLedAudioReactive;

  /// Sous-titre du toggle réactif audio
  ///
  /// In fr, this message translates to:
  /// **'Réagir à l\'entrée du microphone'**
  String get cobLedAudioReactiveHint;

  /// Placeholder pendant le chargement des effets WLED
  ///
  /// In fr, this message translates to:
  /// **'Chargement des effets…'**
  String get cobLedLoadingEffects;

  /// État vide quand aucun preset WLED n'est disponible
  ///
  /// In fr, this message translates to:
  /// **'Aucun preset trouvé sur l\'appareil.'**
  String get cobLedNoPresets;

  /// Titre de section pour la liste des presets WLED
  ///
  /// In fr, this message translates to:
  /// **'MODÈLES'**
  String get cobLedSectionTemplates;

  /// Titre de section pour le preset WLED actif
  ///
  /// In fr, this message translates to:
  /// **'SCÈNE ACTIVE'**
  String get cobLedSectionActiveScene;

  /// Placeholder quand aucun preset WLED n'est actif
  ///
  /// In fr, this message translates to:
  /// **'Aucune scène active'**
  String get cobLedNoActiveScene;

  /// Badge sur le preset WLED actuellement actif
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get cobLedPresetActive;

  /// Bouton pour appliquer un preset WLED
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get cobLedPresetApply;

  /// Titre de la boîte de dialogue d'ajout d'appareil
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un appareil'**
  String get addDeviceTitle;

  /// Label champ : sélecteur de type d'appareil
  ///
  /// In fr, this message translates to:
  /// **'Type d\'appareil'**
  String get addDeviceTypeLabel;

  /// Placeholder dans le menu déroulant du type d'appareil
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner un type'**
  String get addDeviceTypeHint;

  /// Label champ : nom de l'appareil
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'appareil'**
  String get addDeviceNameLabel;

  /// Label champ : adresse IP locale
  ///
  /// In fr, this message translates to:
  /// **'IP locale'**
  String get addDeviceIpLabel;

  /// Label champ : pièce associée
  ///
  /// In fr, this message translates to:
  /// **'Pièce'**
  String get addDeviceRoomLabel;

  /// Label champ pièce optionnel dans les feuilles d'ajout
  ///
  /// In fr, this message translates to:
  /// **'Pièce (optionnel)'**
  String get addDeviceRoomOptionalLabel;

  /// Label champ modèle optionnel dans les feuilles d'ajout
  ///
  /// In fr, this message translates to:
  /// **'Modèle (optionnel)'**
  String get addDeviceModelOptionalLabel;

  /// Label case à cocher : ajouter aux favoris
  ///
  /// In fr, this message translates to:
  /// **'Favori'**
  String get addDeviceFavoriteLabel;

  /// Label case à cocher dans la feuille d'ajout CCT
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux favoris'**
  String get addDeviceAddToFavorites;

  /// Label du bouton Test quand le test de connexion réussit
  ///
  /// In fr, this message translates to:
  /// **'Connecté ✓'**
  String get addDeviceConnectedCheck;

  /// Titre de la feuille d'ajout LED CCT
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une lumière CCT'**
  String get cobLedCctAddTitle;

  /// Erreur validation : champ nom vide
  ///
  /// In fr, this message translates to:
  /// **'Nom requis'**
  String get validationNameRequired;

  /// Erreur validation : octets IP hors limites
  ///
  /// In fr, this message translates to:
  /// **'Adresse IP invalide'**
  String get validationIpInvalidRange;

  /// Erreur affichée quand le test de connexion échoue avec un message détaillé
  ///
  /// In fr, this message translates to:
  /// **'Connexion échouée : {error}'**
  String connectionFailedDetail(String error);

  /// Placeholder état vide dans les widgets graphique/historique
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée'**
  String get noData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
