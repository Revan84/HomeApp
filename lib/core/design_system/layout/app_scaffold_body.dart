import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Scrollable page body with consistent horizontal padding and bottom clearance.
///
/// Wraps a [ListView] so callers only declare their content list — no manual
/// padding boilerplate on every screen.
///
/// ```dart
/// Scaffold(
///   body: AppScaffoldBody(
///     children: [
///       _SummaryHeader(),
///       AppSpacing.gapX3l,
///       _DeviceSection(),
///     ],
///   ),
/// )
///
/// // With custom bottom clearance (e.g. FAB overlap)
/// AppScaffoldBody(bottomPadding: 96, children: [...])
/// ```
class AppScaffoldBody extends StatelessWidget {
  const AppScaffoldBody({
    super.key,
    required this.children,
    this.topPadding = AppSpacing.xl,
    this.bottomPadding = AppSpacing.x6l,
    this.horizontalPadding = AppSpacing.x3l,
  });

  final List<Widget> children;

  /// Top inset — defaults to 12 px.
  final double topPadding;

  /// Bottom inset — increase when a FAB floats above the content (e.g. 96).
  final double bottomPadding;

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topPadding,
        horizontalPadding,
        bottomPadding,
      ),
      children: children,
    );
  }
}
