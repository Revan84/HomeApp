import 'package:flutter/material.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// The three device kinds a user can add.
enum DeviceType { connectedPlug, tv, wled }

/// Bottom sheet that lets the user pick what kind of device to add.
class DeviceTypePickerSheet extends StatelessWidget {
  const DeviceTypePickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.addDeviceTypeTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            AppSpacing.gapXl,
            ListTile(
              leading: const Icon(Icons.power),
              title: Text(l.deviceTypePlug),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.x2lBR,
              ),
              onTap: () =>
                  Navigator.of(context).pop(DeviceType.connectedPlug),
            ),
            ListTile(
              leading: const Icon(Icons.tv),
              title: Text(l.deviceTypeTv),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.x2lBR,
              ),
              onTap: () => Navigator.of(context).pop(DeviceType.tv),
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb_outline_rounded),
              title: Text(l.deviceTypeWled),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.x2lBR,
              ),
              onTap: () => Navigator.of(context).pop(DeviceType.wled),
            ),
          ],
        ),
      ),
    );
  }
}
