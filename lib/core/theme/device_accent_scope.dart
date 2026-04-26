import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Provides a device-type accent colour down the widget tree.
///
/// Wrap each device detail screen with this widget, then read the accent
/// colour anywhere inside via [DeviceAccentScope.of].
///
/// ```dart
/// // In the detail screen:
/// DeviceAccentScope(
///   accentColor: AppColors.plugAccent,
///   child: Scaffold(...),
/// )
///
/// // In any descendant widget:
/// final accent = DeviceAccentScope.of(context);
/// ```
///
/// Falls back to [AppColors.primary] when no [DeviceAccentScope] ancestor
/// exists, so widgets using it are safe to use outside of a detail screen.
class DeviceAccentScope extends InheritedWidget {
  final Color accentColor;

  const DeviceAccentScope({
    super.key,
    required this.accentColor,
    required super.child,
  });

  /// Returns the accent colour from the nearest [DeviceAccentScope] ancestor,
  /// or [AppColors.primary] if no scope is in the tree.
  static Color of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<DeviceAccentScope>()
            ?.accentColor ??
        AppColors.primary;
  }

  @override
  bool updateShouldNotify(DeviceAccentScope old) =>
      accentColor != old.accentColor;
}
