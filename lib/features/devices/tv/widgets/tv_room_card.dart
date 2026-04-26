import 'package:flutter/material.dart';

import '../../../../core/design_system/cards/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';

/// Tappable card that shows the assigned room name and opens the room picker.
class TvRoomCard extends StatelessWidget {
  const TvRoomCard({
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
          const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ],
      ),
    );
  }
}
