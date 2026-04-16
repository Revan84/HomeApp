import 'package:flutter/material.dart';

import '../../../core/design_system/chips/app_chip.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/room.dart';
import '../controller/stats_controller.dart';

/// Horizontal chip row for picking the active room within a group.
class StatsRoomSelector extends StatelessWidget {
  final List<Room> rooms;
  final StatsController controller;

  const StatsRoomSelector({
    super.key,
    required this.rooms,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: rooms.length,
        separatorBuilder: (_, _) => AppSpacing.gapHMd,
        itemBuilder: (_, index) {
          final room = rooms[index];
          return AppChip(
            label: '${room.name} (${controller.equipmentsForRoom(room.id).length})',
            selected: room.id == controller.selectedRoomId,
            variant: AppChipVariant.outlined,
            onTap: () => controller.selectRoom(room.id),
          );
        },
      ),
    );
  }
}
