import 'package:flutter/material.dart';

import '../../../core/i18n/loc.dart';

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
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.power),
              title: Text(l.deviceTypePlug),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onTap: () =>
                  Navigator.of(context).pop(DeviceType.connectedPlug),
            ),
            ListTile(
              leading: const Icon(Icons.tv),
              title: Text(l.deviceTypeTv),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onTap: () => Navigator.of(context).pop(DeviceType.tv),
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb_outline_rounded),
              title: Text(l.deviceTypeWled),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onTap: () => Navigator.of(context).pop(DeviceType.wled),
            ),
          ],
        ),
      ),
    );
  }
}
