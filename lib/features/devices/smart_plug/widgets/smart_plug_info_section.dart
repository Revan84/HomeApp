import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/equipment.dart';
import '../../shared/widgets/detail_info_row.dart';
import '../../shared/widgets/detail_section_card.dart';

/// Informations section card: IP, model, connection type.
class SmartPlugInfoSection extends StatelessWidget {
  const SmartPlugInfoSection({super.key, required this.equipment});

  final Equipment equipment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final modelLabel = switch (equipment.type) {
      EquipmentType.shellyPlusPlugS => l10n.equipmentTypeShellyPlusPlugS,
      EquipmentType.shellyPlugS => l10n.equipmentTypeShellyPlugS,
      _ => '—',
    };

    return DetailSectionCard(
      title: l10n.deviceSectionInformations,
      child: Column(
        children: [
          DetailInfoRow(label: l10n.deviceInfoLocalIp, value: equipment.ip),
          AppSpacing.gapSm,
          DetailInfoRow(label: l10n.deviceInfoModelLabel, value: modelLabel),
          AppSpacing.gapSm,
          DetailInfoRow(
            label: l10n.deviceInfoConnection,
            value: l10n.deviceConnectionWifi,
          ),
        ],
      ),
    );
  }
}
