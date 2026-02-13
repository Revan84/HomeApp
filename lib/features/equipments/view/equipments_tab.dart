import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/repositories/equipment_repository.dart';
import '../../live/controller/live_polling_controller.dart';
import '../model/equipment_mappers.dart';

import '../model/equipment.dart';
import 'equipment_details_page.dart';

class EquipmentsTab extends StatefulWidget {
  final ValueNotifier<int> refreshNotifier;
  const EquipmentsTab({super.key, required this.refreshNotifier});

  @override
  State<EquipmentsTab> createState() => _EquipmentsTabState();
}

class _EquipmentsTabState extends State<EquipmentsTab> {
  bool _loading = true;
  List<Equipment> _equipments = [];

  @override
  void initState() {
    super.initState();
    _load();
    widget.refreshNotifier.addListener(_onRefreshRequested);
  }

  @override
  void dispose() {
    widget.refreshNotifier.removeListener(_onRefreshRequested);
    super.dispose();
  }

  void _onRefreshRequested() => _load();

  bool _isSupported(Equipment e) => e.type == EquipmentType.shellyPlusPlugS;

  Future<void> _load() async {
    setState(() => _loading = true);

    final items = await context.read<EquipmentRepository>().loadAll();
    if (!mounted) return;

    _equipments = items;

    final liveCtl = context.read<LivePollingController>();
    final endpoints = _equipments
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
              itemCount: _equipments.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final e = _equipments[i];

                final st = _isSupported(e) ? liveCtl.live[e.id] : null;
                final dotColor = (st?.online ?? false)
                    ? Colors.green
                    : Colors.orange;

                return _EquipmentPill(
                  title: e.name,
                  icon: _iconForType(e.type),
                  dotColor: dotColor,
                  onTap: () async {
                    final changed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => EquipmentDetailsPage(equipmentId: e.id),
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
