import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/area_card.dart';

import '../../../features/live/controller/live_polling_controller.dart';

import '../model/room.dart';
import '../../equipments/model/equipment.dart';

class AreasSection extends StatefulWidget {
  const AreasSection({
    super.key,
    required this.rooms,
    required this.equipments,
    required this.onOpenEquipment,
  });

  final List<Room> rooms;
  final List<Equipment> equipments;
  final void Function(String equipmentId) onOpenEquipment;

  @override
  State<AreasSection> createState() => _AreasSectionState();
}

class _AreasSectionState extends State<AreasSection> {
  bool _expanded = false;

  bool _isPlug(Equipment e) => e.type == EquipmentType.shellyPlusPlugS;

  @override
  Widget build(BuildContext context) {
    final liveCtl = context.watch<LivePollingController>();

    final rooms = widget.rooms;
    final hasToggle = rooms.length > 2;

    final visibleRooms = (!hasToggle || _expanded)
        ? rooms
        : rooms.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: AppStrings.areas),
        const SizedBox(height: 10),

        if (rooms.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text("Aucune pièce pour le moment."),
          )
        else ...[
          ...visibleRooms.map((r) {
            final plugs = widget.equipments
                .where((e) => _isPlug(e) && e.roomId == r.id)
                .toList();

            final items = plugs.map((e) {
              final st = liveCtl.live[e.id];
              final on = st?.output;

              final value = e.showPower
                  ? (st?.powerW == null
                        ? '—'
                        : '${st!.powerW!.toStringAsFixed(0)} W')
                  : (on == true ? 'ON' : 'OFF');

              return AreaDeviceItem(
                id: e.id,
                label: e.name,
                value: value,
                isOn: on,
              );
            }).toList();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AreaCard(
                title: r.name,
                devices: items,
                onDeviceTap: (deviceId) => widget.onOpenEquipment(deviceId),
              ),
            );
          }),

          if (hasToggle) ...[
            const SizedBox(height: 14),
            Center(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(
                    color: AppColors.stroke.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? 'See less' : 'See all'),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
