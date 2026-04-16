import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Small filled circle communicating device or connection status.
///
/// By default maps [online] to a semantic color:
///   true  → [AppColors.success] (green)
///   false → [AppColors.textSecondary] (grey)
///
/// Pass [color] to override for custom status semantics (e.g. accent colors).
///
/// ```dart
/// StatusDot(online: device.isConnected)
/// StatusDot(online: true, size: 8)
/// StatusDot(online: isActive, color: AppColors.primary)
/// ```
class StatusDot extends StatelessWidget {
  const StatusDot({
    super.key,
    required this.online,
    this.color,
    this.size = 10,
  });

  final bool online;

  /// Overrides the default semantic color.
  final Color? color;

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? (online ? AppColors.success : AppColors.textSecondary),
      ),
    );
  }
}
