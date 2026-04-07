import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
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
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: rooms.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final room = rooms[index];
          final selected = room.id == controller.selectedRoomId;

          return ChoiceChip(
            label: Text(
              room.name,
              style: TextStyle(
                fontSize: 11,
                color: selected ? AppColors.bg : AppColors.textSecondary,
              ),
            ),
            selected: selected,
            selectedColor: AppColors.success,
            backgroundColor: AppColors.bg,
            side: BorderSide(
              color: selected
                  ? AppColors.success
                  : AppColors.stroke.withValues(alpha: 0.3),
            ),
            onSelected: (_) => controller.selectRoom(room.id),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }
}
