import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Simple rounded container used by the prototype-like screens.
///
/// Kept generic on purpose (not tied to equipment details) so we can reuse it
/// later in other tabs (e.g. stats).
class PrototypeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const PrototypeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        // Prototype design has no visible border. Keep it borderless.
      ),
      child: child,
    );
  }
}
