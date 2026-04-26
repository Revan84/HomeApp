import 'package:flutter/material.dart';

import '../../../../core/design_system/cards/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';

/// Tappable card that displays the assigned room name and opens the room picker.
///
/// Used consistently across all device detail screens in place of the previously
/// duplicated inline [AppCard] room row.
class DeviceRoomCard extends StatelessWidget {
  const DeviceRoomCard({
    super.key,
    required this.roomName,
    required this.onTap,
  });

  final String roomName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.card,
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.meeting_room_outlined,
              color: AppColors.textSecondary, size: 18),
          AppSpacing.gapHSm,
          Text(
            roomName,
            style: const TextStyle(
              fontFamily: 'ShareTech',
              fontWeight: FontWeight.w600,
              fontSize: AppFontSizes.sectionTitle,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textSecondary, size: 22),
        ],
      ),
    );
  }
}
