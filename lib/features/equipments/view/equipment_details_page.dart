import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/network_detector.dart';
import '../../../domain/repositories/equipment_repository.dart';
import '../../integrations/shelly/data/shelly_rpc_client.dart';
import '../../live/controller/live_polling_controller.dart';
import '../model/equipment.dart';
import 'edit_equipment_sheet.dart';
import '../../equipments/model/equipment_mappers.dart';

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
  String _status = '...';

  Map<String, dynamic>? _deviceInfo;

  final _detector = NetworkDetector();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);

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
    if (_eq == null) return;

    final snap = await _detector.getSnapshot(requestPermissionIfNeeded: true);

    // Si Wi-Fi mais pas la permission: on STOP et on affiche un message clair
    if (snap.isWifi && !snap.permissionGranted) {
      if (!mounted) return;
      setState(() {
        _net = snap;
        _status = "Permission requise pour lire le Wi-Fi (SSID/IP)";
      });
      return;
    }

    final sameSubnet = _detector.isSameSubnet24(
      deviceIp: _eq!.ip,
      wifiIp: snap.wifiIP,
    );
    final reachable = await _detector.isReachable(_eq!.ip);

    String status;
    if (reachable) {
      status = "En ligne";
    } else if (!snap.isWifi) {
      status = "Pas en Wi-Fi (ou Wi-Fi non détectable)";
    } else if (!sameSubnet) {
      status = "Mauvais Wi-Fi (réseau différent)";
    } else {
      status = "Hors ligne";
    }

    if (!mounted) return;
    setState(() {
      _net = snap;
      _status = status;
    });
  }

  Future<void> _onRefreshPressed() async {
    await _refreshNetworkAndStatus();
    if (!mounted) return;
    await _refreshDeviceInfoWith(_shellyRpc);
  }

  Future<void> _refreshDeviceInfoWith(ShellyRpcClient rpc) async {
    if (_eq == null) return;

    if (_status.startsWith("Mauvais") || _status.startsWith("Pas en Wi")) {
      return;
    }

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
        title: const Text("Supprimer l’équipement ?"),
        content: Text("“${eq.name}” sera supprimé."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
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

  @override
  Widget build(BuildContext context) {
    if (_loading || _eq == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final eq = _eq!;
    final liveCtl = context.watch<LivePollingController>();

    final st = liveCtl.live[eq.id];

    final ssid = _net?.ssid ?? '—';
    final phoneIp = _net?.wifiIP ?? '—';

    final on = st?.output;
    final powerW = st?.powerW;
    final energyWh = st?.energyWh;
    final rssi = st?.rssi;

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
              tooltip: "Rafraîchir",
              onPressed: _onRefreshPressed,
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: "Modifier",
              onPressed: _edit,
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              tooltip: "Supprimer",
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _InfoCard(
              title: "Réseau",
              lines: [
                "Wi-Fi: $ssid",
                "IP téléphone: $phoneIp",
                "Équipement: ${eq.ip}",
                "Statut: $_status",
              ],
            ),
            const SizedBox(height: 4),
            if ((_net?.isWifi ?? false) && !(_net?.permissionGranted ?? true))
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
                    label: const Text("Autoriser l'accès Wi-Fi"),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            if (_deviceInfo != null)
              _InfoCard(
                title: "Device info",
                lines: [
                  "Model: ${_deviceInfo!['model'] ?? '—'}",
                  "Gen: ${_deviceInfo!['gen'] ?? '—'}",
                  "FW: ${_deviceInfo!['ver'] ?? '—'}",
                  "MAC: ${_deviceInfo!['mac'] ?? '—'}",
                ],
              ),
            const SizedBox(height: 12),
            _InfoCard(
              title: "Données live",
              lines: [
                if (eq.showToggle)
                  "On/Off: ${on == null ? '—' : (on == true ? 'ON' : 'OFF')}",
                if (eq.showPower)
                  "Puissance: ${powerW == null ? '—' : '${powerW.toStringAsFixed(0)} W'}",
                if (eq.showEnergy)
                  "Énergie: ${energyWh == null ? '—' : '${energyWh.toStringAsFixed(0)} Wh'}",
                if (eq.showRssi) "RSSI: ${rssi == null ? '—' : '$rssi dBm'}",
                "Dernière maj: ${st?.lastUpdatedAt?.toLocal().toString() ?? '—'}",
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
                label: Text(on == true ? "Éteindre" : "Allumer"),
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
