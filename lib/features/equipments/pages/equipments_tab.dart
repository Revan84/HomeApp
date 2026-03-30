import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/repositories/equipment_repository.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/repositories/tv_repository.dart';
import '../../../domain/repositories/wled_repository.dart';
import '../../../domain/models/equipment.dart';
import '../../../domain/models/room.dart';
import '../../../domain/models/tv_device.dart';
import '../../../domain/models/wled_device.dart';
import '../../../data/mappers/equipment_mappers.dart';
import '../../live/controllers/live_polling_controller.dart';
import '../../tv/pages/tv_details_page.dart';
import '../../wled/pages/wled_details_page.dart';

import 'equipment_details_page.dart';

class EquipmentsTab extends StatefulWidget {
  final ValueNotifier<int> refreshNotifier;
  final ValueNotifier<String?> selectedGroupIdNotifier;
  const EquipmentsTab({
    super.key,
    required this.refreshNotifier,
    required this.selectedGroupIdNotifier,
  });

  @override
  State<EquipmentsTab> createState() => _EquipmentsTabState();
}

class _EquipmentsTabState extends State<EquipmentsTab> {
  bool _loading = true;
  List<Equipment> _allEquipments = [];
  List<Room> _rooms = [];
  List<TvDevice> _tvDevices = [];
  List<WledDevice> _wledDevices = [];

  @override
  void initState() {
    super.initState();
    _load();
    widget.refreshNotifier.addListener(_onRefreshRequested);
    widget.selectedGroupIdNotifier.addListener(_onGroupChanged);
  }

  @override
  void dispose() {
    widget.refreshNotifier.removeListener(_onRefreshRequested);
    widget.selectedGroupIdNotifier.removeListener(_onGroupChanged);
    super.dispose();
  }

  void _onRefreshRequested() => _load();

  void _onGroupChanged() {
    if (mounted) setState(() {});
  }

  bool _isSupported(Equipment e) => e.type == EquipmentType.shellyPlusPlugS;

  Set<String> get _visibleRoomIds {
    final groupId = widget.selectedGroupIdNotifier.value;
    if (groupId == null) return const {};
    return _rooms.where((r) => r.groupId == groupId).map((r) => r.id).toSet();
  }

  List<Equipment> get _equipments {
    final groupId = widget.selectedGroupIdNotifier.value;
    if (groupId == null) return _allEquipments;
    final roomIds = _visibleRoomIds;
    return _allEquipments
        .where((e) => roomIds.contains(e.roomId))
        .toList(growable: false);
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final equipmentRepo = context.read<EquipmentRepository>();
    final roomRepo = context.read<RoomRepository>();
    final tvRepo = context.read<TvRepository>();
    final wledRepo = context.read<WledRepository>();

    final results = await Future.wait([
      equipmentRepo.loadAll(),
      roomRepo.loadAll(),
      tvRepo.loadAll(),
      wledRepo.loadAll(),
    ]);

    if (!mounted) return;

    _allEquipments = results[0] as List<Equipment>;
    _rooms = results[1] as List<Room>;
    _tvDevices = results[2] as List<TvDevice>;
    _wledDevices = results[3] as List<WledDevice>;

    final liveCtl = context.read<LivePollingController>();
    final endpoints = _allEquipments
        .where(_isSupported)
        .map((e) => e.toEndpoint())
        .toList();
    liveCtl.syncFollowed(endpoints, forcePollNow: true);

    setState(() => _loading = false);
  }

  IconData _iconForType(EquipmentType type) {
    switch (type) {
      case EquipmentType.shellyPlusPlugS:
      default:
        return Icons.devices_other;
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveCtl = context.watch<LivePollingController>();

    if (_loading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text("Filtres", style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text(
                  "Actif(s) : Tous",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: () {}, icon: const Icon(Icons.tune)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _equipments.length + _tvDevices.length + _wledDevices.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                // Equipment items
                if (i < _equipments.length) {
                  final e = _equipments[i];
                  final st = _isSupported(e) ? liveCtl.live[e.id] : null;
                  final dotColor =
                      (st?.online ?? false) ? Colors.green : Colors.orange;

                  return _EquipmentPill(
                    title: e.name,
                    icon: _iconForType(e.type),
                    dotColor: dotColor,
                    onTap: () async {
                      final changed = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) =>
                              EquipmentDetailsPage(equipmentId: e.id),
                        ),
                      );
                      if (changed == true) _load();
                    },
                  );
                }

                // TV items
                if (i < _equipments.length + _tvDevices.length) {
                  final tv = _tvDevices[i - _equipments.length];
                  return _EquipmentPill(
                    title: tv.name,
                    icon: Icons.tv,
                    dotColor: Colors.blueGrey,
                    onTap: () async {
                      final changed = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => TvDetailsPage(deviceId: tv.id),
                        ),
                      );
                      if (changed == true) _load();
                    },
                  );
                }

                // WLED items
                final wled = _wledDevices[i - _equipments.length - _tvDevices.length];
                return _EquipmentPill(
                  title: wled.name,
                  icon: Icons.lightbulb_outline_rounded,
                  dotColor: Colors.amber.shade600,
                  onTap: () async {
                    final changed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => WledDetailsPage(deviceId: wled.id),
                      ),
                    );
                    if (changed == true) _load();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentPill extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color dotColor;
  final VoidCallback onTap;

  const _EquipmentPill({
    required this.title,
    required this.icon,
    required this.dotColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white12),
            color: Colors.white.withValues(alpha: 0.04),
          ),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
