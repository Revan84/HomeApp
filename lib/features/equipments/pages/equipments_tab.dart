import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/equipment.dart';

import '../../live/controllers/live_polling_controller.dart';
import '../../tv/pages/tv_details_page.dart';
import '../../wled/pages/wled_details_page.dart';
import '../controllers/equipments_controller.dart';
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
  @override
  void initState() {
    super.initState();
    _reload();
    widget.refreshNotifier.addListener(_reload);
    widget.selectedGroupIdNotifier.addListener(_onGroupChanged);
  }

  @override
  void dispose() {
    widget.refreshNotifier.removeListener(_reload);
    widget.selectedGroupIdNotifier.removeListener(_onGroupChanged);
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    context.read<EquipmentsController>().loadAll();
  }

  void _onGroupChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _onEquipmentTap(String equipmentId) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EquipmentDetailsPage(equipmentId: equipmentId),
      ),
    );
    if (changed == true) _reload();
  }

  Future<void> _onTvTap(String tvId) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TvDetailsPage(deviceId: tvId),
      ),
    );
    if (changed == true) _reload();
  }

  Future<void> _onWledTap(String wledId) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WledDetailsPage(deviceId: wledId),
      ),
    );
    if (changed == true) _reload();
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
    final controller = context.watch<EquipmentsController>();
    final liveCtl = context.watch<LivePollingController>();
    final groupId = widget.selectedGroupIdNotifier.value;

    if (controller.isLoading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    final equipments = controller.equipmentsForGroup(groupId);
    final tvDevices = controller.tvDevices;
    final wledDevices = controller.wledDevices;
    final totalCount = equipments.length + tvDevices.length + wledDevices.length;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: totalCount,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                if (i < equipments.length) {
                  final e = equipments[i];
                  final st =
                      controller.isSupported(e) ? liveCtl.live[e.id] : null;
                  final dotColor =
                      (st?.online ?? false) ? Colors.green : Colors.orange;
                  return _EquipmentPill(
                    title: e.name,
                    icon: _iconForType(e.type),
                    dotColor: dotColor,
                    onTap: () => _onEquipmentTap(e.id),
                  );
                }
                if (i < equipments.length + tvDevices.length) {
                  final tv = tvDevices[i - equipments.length];
                  return _EquipmentPill(
                    title: tv.name,
                    icon: Icons.tv,
                    dotColor: Colors.blueGrey,
                    onTap: () => _onTvTap(tv.id),
                  );
                }
                final wled =
                    wledDevices[i - equipments.length - tvDevices.length];
                return _EquipmentPill(
                  title: wled.name,
                  icon: Icons.lightbulb_outline_rounded,
                  dotColor: Colors.amber.shade600,
                  onTap: () => _onWledTap(wled.id),
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
