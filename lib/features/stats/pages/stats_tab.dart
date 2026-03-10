import 'package:flutter/material.dart';
import 'package:front_end/core/i18n/loc.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(context.l10n.tabData));
  }
}
