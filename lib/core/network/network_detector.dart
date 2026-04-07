import 'dart:io';
import 'dart:async';
import 'dart:io' show Socket, Platform;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class NetworkSnapshot {
  final bool isWifi;
  final String? ssid;
  final String? wifiIP;
  final bool permissionGranted;

  const NetworkSnapshot({
    required this.isWifi,
    required this.ssid,
    required this.wifiIP,
    required this.permissionGranted,
  });
}

class NetworkDetector {
  final Connectivity _connectivity = Connectivity();
  final NetworkInfo _info = NetworkInfo();

  Future<NetworkSnapshot> getSnapshot({bool requestPermissionIfNeeded = true}) async {
    final result = await _connectivity.checkConnectivity();
    final isWifi = _isWifi(result);

    if (!isWifi) {
      return const NetworkSnapshot(
        isWifi: false,
        ssid: null,
        wifiIP: null,
        permissionGranted: true,
      );
    }

    final granted = await _ensureWifiPermission(
      requestIfNeeded: requestPermissionIfNeeded,
    );

    if (!granted) {
      return const NetworkSnapshot(
        isWifi: true,
        ssid: null,
        wifiIP: null,
        permissionGranted: false,
      );
    }

    String? ssid;
    String? ip;

    try {
      ssid = _cleanSsid(await _info.getWifiName());
    } catch (_) {
      ssid = null;
    }

    try {
      ip = await _info.getWifiIP();
    } catch (_) {
      ip = null;
    }

    return NetworkSnapshot(
      isWifi: true,
      ssid: ssid,
      wifiIP: ip,
      permissionGranted: true,
    );
  }

  bool _isWifi(dynamic result) {
    if (result is List<ConnectivityResult>) return result.contains(ConnectivityResult.wifi);
    if (result is ConnectivityResult) return result == ConnectivityResult.wifi;
    return false;
  }

  String? _cleanSsid(String? ssid) {
    if (ssid == null) return null;
    return ssid.replaceAll('"', '').trim();
  }

  Future<bool> _ensureWifiPermission({required bool requestIfNeeded}) async {
    if (!Platform.isAndroid) return true;

    // Simple and reliable: Location permission (works on most devices for SSID via network_info_plus).
    // Android 13+ "nearby wifi devices" permission can be added later if needed.
    final status = await Permission.locationWhenInUse.status;
    if (status.isGranted) return true;

    if (!requestIfNeeded) return false;

    final res = await Permission.locationWhenInUse.request();
    return res.isGranted;
  }

  bool isSameSubnet24({required String? deviceIp, required String? wifiIp}) {
    if (deviceIp == null || wifiIp == null) return false;
    final a = deviceIp.split('.');
    final b = wifiIp.split('.');
    if (a.length != 4 || b.length != 4) return false;
    return a[0] == b[0] && a[1] == b[1] && a[2] == b[2];
  }

  Future<bool> isReachable(String ip, {Duration timeout = const Duration(seconds: 2)}) async {
    try {
      final socket = await Socket.connect(ip, 80, timeout: timeout);
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}
