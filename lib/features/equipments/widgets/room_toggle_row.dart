import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class RoomToggleRow extends StatelessWidget {
  final String roomName;
  final VoidCallback onSelectRoom;

  final bool value;
  final ValueChanged<bool>? onChanged;

  const RoomToggleRow({
    super.key,
    required this.roomName,
    required this.onSelectRoom,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onSelectRoom,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    roomName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
