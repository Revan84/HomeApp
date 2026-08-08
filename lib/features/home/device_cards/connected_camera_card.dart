import 'package:flutter/material.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_font_sizes.dart';
import '../../../domain/entities/connected_camera_device.dart';
import 'card_shared.dart';

/// Home-grid card for a Connected Camera device.
///
/// [isOnline] reflects the latest probe result from [ConnectedCameraController].
/// null = probe pending (spinner); true/false = resolved state.
class ConnectedCameraCard extends StatelessWidget {
  const ConnectedCameraCard({
    super.key,
    required this.device,
    required this.onTap,
    this.isOnline,
  });

  final ConnectedCameraDevice device;
  final VoidCallback onTap;

  /// null = probe not yet run; true = reachable; false = unreachable.
  final bool? isOnline;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final online = isOnline ?? false;

    return CardShell(
      onTap: onTap,
      accentColor: AppColors.connectedCameraAccent,
      online: online,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            icon: Icons.videocam_rounded,
            name: device.name,
          ),
          const Spacer(),
          if (device.modelName.isNotEmpty)
            Text(
              device.modelName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppFontSizes.sm,
              ),
            ),
        ],
      ),
      footer: CardFooter(
        updatedLabel:
            online ? l.netStatusOnline : l.connectedCameraOffline,
        isOn: online,
        toggling: false,
        canToggle: false,
        onToggle: null,
      ),
    );
  }
}
