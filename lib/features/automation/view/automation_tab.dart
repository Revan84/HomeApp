import 'package:flutter/material.dart';
import 'package:front_end/core/i18n/loc.dart';

class AutomationTab extends StatelessWidget {
  const AutomationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(context.l10n.tabAutomation));
  }
}
