import 'package:flutter/material.dart';
import 'package:front_end/core/i18n/loc.dart';
import 'package:provider/provider.dart';

import '../../../core/network/network_detector.dart';
import '../../../domain/repositories/equipment_repository.dart';
import '../../integrations/shelly/data/shelly_rpc_client.dart';
import '../../live/controller/live_polling_controller.dart';
import '../model/equipment.dart';
import 'edit_equipment_sheet.dart';
import '../../equipments/model/equipment_mappers.dart';

enum NetStatus {
  unknown,
  online,
  offline,
  notOnWifi,
  wrongWifi,
  permissionRequired,
}

class EquipmentDetailsPage extends StatefulWidget {
  final String equipmentId;
  const EquipmentDetailsPage({super.key, required this.equipmentId});

  @override
  State<EquipmentDetailsPage> createState() => _EquipmentDetailsPageState();
}

class _EquipmentDetailsPageState extends State<EquipmentDetailsPage> {
  Equipment? _eq;
  bool _loading = true;
  bool _dirty = false;

  late EquipmentRepository _equipmentRepo;
  late ShellyRpcClient _shellyRpc;
  late LivePollingController _liveCtl;

  bool _depsReady = false;

  NetworkSnapshot? _net;

  NetStatus _netStatus = NetStatus.unknown;

  String _netStatusLabel(BuildContext context, NetStatus s) {
    switch (s) {
      case NetStatus.online:
        return context.l10n.netStatusOnline;
      case NetStatus.offline:
        return context.l10n.netStatusOffline;
      case NetStatus.notOnWifi:
        return context.l10n.netStatusNotOnWifi;
      case NetStatus.wrongWifi:
        return context.l10n.netStatusWrongWifi;
      case NetStatus.permissionRequired:
        return context.l10n.netWifiPermissionRequired;
      case NetStatus.unknown:
        return context.l10n.valueUnknown;
    }
  }

  Map<String, dynamic>? _deviceInfo;

  final _detector = NetworkDetector();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    _deviceInfo = null;
    _net = null;
    _netStatus = NetStatus.unknown;

    final nav = Navigator.of(context);

    final all = await _equipmentRepo.loadAll();
    if (!mounted) return;

    final eq = all
        .where((e) => e.id == widget.equipmentId)
        .cast<Equipment?>()
        .firstWhere((e) => e != null, orElse: () => null);

    if (eq == null) {
      nav.pop(false);
      return;
    }

    _eq = eq;

    await _refreshNetworkAndStatus();
    await _refreshDeviceInfoWith(_shellyRpc);

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _refreshNetworkAndStatus() async {
    final eq = _eq;
    if (eq == null) return;

    final snap = await _detector.getSnapshot(requestPermissionIfNeeded: true);

    // Wi-Fi mais permission non accordée -> STOP
    if (snap.isWifi && !snap.permissionGranted) {
      if (!mounted) return;
      setState(() {
        _net = snap;
        _netStatus = NetStatus.permissionRequired;
      });
      return;
    }

    final sameSubnet = _detector.isSameSubnet24(
      deviceIp: eq.ip,
      wifiIp: snap.wifiIP,
    );
    final reachable = await _detector.isReachable(eq.ip);

    final NetStatus status;
    if (reachable) {
      status = NetStatus.online;
    } else if (!snap.isWifi) {
      status = NetStatus.notOnWifi;
    } else if (!sameSubnet) {
      status = NetStatus.wrongWifi;
    } else {
      status = NetStatus.offline;
    }

    if (!mounted) return;
    setState(() {
      _net = snap;
      _netStatus = status;
    });
  }

  Future<void> _onRefreshPressed() async {
    await _refreshNetworkAndStatus();
    if (!mounted) return;
    await _refreshDeviceInfoWith(_shellyRpc);
  }

  Future<void> _refreshDeviceInfoWith(ShellyRpcClient rpc) async {
    if (_eq == null) return;

    // Ne pas spammer si mauvais wifi / pas wifi
    if (_netStatus == NetStatus.wrongWifi ||
        _netStatus == NetStatus.notOnWifi ||
        _netStatus == NetStatus.permissionRequired) {
      return;
    }

    // Only Shelly types
    if (!(_eq!.type == EquipmentType.shellyPlusPlugS ||
        _eq!.type == EquipmentType.shellyPlugS)) {
      return;
    }

    try {
      final data = await rpc.getDeviceInfo(_eq!.ip);
      if (!mounted) return;
      setState(() => _deviceInfo = data);
    } catch (_) {
      // ignore
    }
  }

  Future<void> _edit() async {
    final eq = _eq;
    if (eq == null) return;

    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => EditEquipmentSheet(initial: eq),
    );

    if (!mounted) return;

    if (changed == true) {
      _dirty = true;
      await _loadAll();
    }
  }

  Future<void> _delete() async {
    final eq = _eq;
    if (eq == null) return;

    final nav = Navigator.of(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.deleteEquipmentConfirmTitle),
        content: Text(context.l10n.deleteEquipmentConfirmBody(eq.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await _equipmentRepo.deleteById(eq.id);
    if (!mounted) return;

    nav.pop(true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_depsReady) return;

    _equipmentRepo = context.read<EquipmentRepository>();
    _shellyRpc = context.read<ShellyRpcClient>();
    _liveCtl = context.read<LivePollingController>();

    _depsReady = true;
  }

  String _dash(String? v) => (v == null || v.isEmpty) ? '—' : v;

  String _onOffLabel(bool? on) {
    if (on == null) return context.l10n.valueUnknown;
    return on ? context.l10n.valueOn : context.l10n.valueOff;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _eq == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final eq = _eq!;
    final liveCtlWatch = context.watch<LivePollingController>();
    final st = liveCtlWatch.live[eq.id];

    final ssid = _dash(_net?.ssid);
    final phoneIp = _dash(_net?.wifiIP);

    final on = st?.output;
    final powerW = st?.powerW;
    final energyWh = st?.energyWh;
    final rssi = st?.rssi;

    final showWifiPermissionCta = _netStatus == NetStatus.permissionRequired;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_dirty);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(eq.name),
          leading: BackButton(
            onPressed: () => Navigator.of(context).pop(_dirty),
          ),
          actions: [
            IconButton(
              tooltip: context.l10n.refresh,
              onPressed: _onRefreshPressed,
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: context.l10n.edit,
              onPressed: _edit,
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              tooltip: context.l10n.delete,
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _InfoCard(
              title: context.l10n.detailsNetworkTitle,
              lines: [
                context.l10n.detailsWifiLine(ssid),
                context.l10n.detailsPhoneIpLine(phoneIp),
                context.l10n.detailsEquipmentIpLine(eq.ip),
                context.l10n.detailsStatusLine(
                  _netStatusLabel(context, _netStatus),
                ),
              ],
            ),
            const SizedBox(height: 4),

            if (showWifiPermissionCta)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _refreshNetworkAndStatus(); // redemande la permission
                      if (!mounted) return;
                      await _onRefreshPressed();
                    },
                    icon: const Icon(Icons.lock_open),
                    label: Text(context.l10n.netGrantWifiAccess),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            if (_deviceInfo != null)
              _InfoCard(
                title: context.l10n.detailsDeviceInfoTitle,
                lines: [
                  context.l10n.detailsDeviceModelLine(
                    '${_deviceInfo!['model'] ?? '—'}',
                  ),
                  context.l10n.detailsDeviceGenLine(
                    '${_deviceInfo!['gen'] ?? '—'}',
                  ),
                  context.l10n.detailsDeviceFwLine(
                    '${_deviceInfo!['ver'] ?? '—'}',
                  ),
                  context.l10n.detailsDeviceMacLine(
                    '${_deviceInfo!['mac'] ?? '—'}',
                  ),
                ],
              ),

            const SizedBox(height: 12),

            _InfoCard(
              title: context.l10n.detailsLiveDataTitle,
              lines: [
                if (eq.showToggle)
                  context.l10n.detailsOnOffLine(_onOffLabel(on)),
                if (eq.showPower)
                  context.l10n.detailsPowerLine(
                    powerW == null
                        ? context.l10n.valueUnknown
                        : '${powerW.toStringAsFixed(0)} W',
                  ),
                if (eq.showEnergy)
                  context.l10n.detailsEnergyLine(
                    energyWh == null
                        ? context.l10n.valueUnknown
                        : '${energyWh.toStringAsFixed(0)} Wh',
                  ),
                if (eq.showRssi)
                  context.l10n.detailsRssiLine(
                    rssi == null ? context.l10n.valueUnknown : '$rssi dBm',
                  ),
                context.l10n.detailsLastUpdatedLine(
                  st?.lastUpdatedAt?.toLocal().toString() ??
                      context.l10n.valueUnknown,
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: (eq.showToggle == true)
            ? FloatingActionButton.extended(
                onPressed: (st == null || st.toggling || !(st.online))
                    ? null
                    : () => _liveCtl.toggle(eq.toEndpoint()),
                icon: const Icon(Icons.power),
                label: Text(
                  on == true
                      ? context.l10n.actionTurnOff
                      : context.l10n.actionTurnOn,
                ),
              )
            : null,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<String> lines;

  const _InfoCard({required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final l in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(l),
              ),
          ],
        ),
      ),
    );
  }
}
