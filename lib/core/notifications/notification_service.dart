import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Thin wrapper around [FlutterLocalNotificationsPlugin].
///
/// Call [init] once from [main] before [runApp].
///
/// Platform setup required:
///  Android — add to AndroidManifest.xml:
///    uses-permission POST_NOTIFICATIONS
///    uses-permission VIBRATE
///  iOS — permissions are requested automatically on first call to [init].
///
/// On unsupported platforms (desktop, web) the service is silently disabled
/// so the app never throws a MissingPluginException.
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static int _idCounter = 0;

  static const _channelId = 'iot_device_alerts';
  static const _channelName = 'Device Alerts';
  static const _channelDesc =
      'Fired when a device metric exceeds a configured threshold.';

  /// True only on Android and iOS — the platforms that have native channels.
  static bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  // ── Init ─────────────────────────────────────────────────────────────────

  /// Initialises the plugin. Safe to call on any platform — silently
  /// no-ops on web and desktop.
  static Future<void> init() async {
    if (_initialized || !_supported) return;

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      await _plugin.initialize(
        const InitializationSettings(
            android: androidSettings, iOS: iosSettings),
      );

      // Android 13+ — request POST_NOTIFICATIONS at runtime.
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _initialized = true;
    } catch (e) {
      // Plugin unavailable (simulator without Google Play, unsupported build).
      // Alert banners still work; push is silently disabled.
      debugPrint('NotificationService: init skipped — $e');
    }
  }

  // ── Permission ───────────────────────────────────────────────────────────

  /// Checks the current notification permission status.
  ///
  /// Returns `true` if already granted.
  /// On Android 13+ and iOS this will show the system dialog the first time.
  /// If permanently denied it opens the app settings page so the user can
  /// enable it manually.
  static Future<bool> requestPermission() async {
    if (!_supported) return false;

    final status = await Permission.notification.status;
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      // Can't ask again — send the user to system settings.
      await openAppSettings();
      return false;
    }

    final result = await Permission.notification.request();
    return result.isGranted;
  }

  // ── Show ─────────────────────────────────────────────────────────────────

  /// Shows a high-priority system notification.
  /// Returns silently when the plugin is unavailable.
  static Future<void> showPush({
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      );

      await _plugin.show(
        _idCounter++ & 0x7FFFFFFF,
        title,
        body,
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
      );
    } catch (e) {
      debugPrint('NotificationService: showPush failed — $e');
    }
  }
}
