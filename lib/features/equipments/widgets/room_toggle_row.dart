import 'package:flutter/material.dart';

import '../../../core/design_system/buttons/mini_toggle.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class RoomToggleRow extends StatelessWidget {
  final String roomName;
  final VoidCallback onSelectRoom;
  final GlobalKey? anchorKey;

  final bool isOn;
  final bool loading;
  final VoidCallback? onTap;

  const RoomToggleRow({
    super.key,
    required this.roomName,
    required this.onSelectRoom,
    required this.isOn,
    this.loading = false,
    required this.onTap,
    this.anchorKey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            key: anchorKey,
            borderRadius: AppRadius.xlBR,
            onTap: onSelectRoom,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                children: [
                  Text(
                    roomName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  AppSpacing.gapHSm,
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        MiniToggle(isOn: isOn, loading: loading, onTap: onTap),
      ],
    );
  }
}
