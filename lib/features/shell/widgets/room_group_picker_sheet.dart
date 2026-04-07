import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../controllers/shell_controller.dart';

/// Bottom sheet that lets the user switch the active room group.
class RoomGroupPickerSheet extends StatelessWidget {
  const RoomGroupPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellController>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.homeSelectRoomGroupTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            ...shell.roomGroups.map(
              (group) => ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(group.name),
                trailing: group.id == shell.selectedGroupId
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(context).pop(group.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
