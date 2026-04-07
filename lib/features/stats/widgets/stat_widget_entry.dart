import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/stat_widget.dart';

/// A single widget entry inside a device group card, with edit/delete actions.
class StatWidgetEntry extends StatelessWidget {
  final StatWidgetConfig config;
  final Widget child;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StatWidgetEntry({
    super.key,
    required this.config,
    required this.child,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 28,
                width: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 18,
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.textSecondary),
                  onPressed: onEdit,
                ),
              ),
              SizedBox(
                height: 28,
                width: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 18,
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.danger),
                  onPressed: onDelete,
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}
