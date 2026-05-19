import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/tv_device.dart';
import '../../../integrations/samsung/data/samsung_ws_client.dart';
import '../../shared/widgets/detail_info_row.dart';
import '../../shared/widgets/detail_section_card.dart';

/// Informations section card: IP, model, connection status.
class TvInfoSection extends StatelessWidget {
  const TvInfoSection({
    super.key,
    required this.device,
    required this.connectionState,
  });

  final TvDevice device;
  final TvConnectionState connectionState;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final connLabel = connectionState == TvConnectionState.connected
        ? l10n.tvStatusConnectedWifi
        : connectionState == TvConnectionState.connecting
            ? l10n.tvStatusConnecting
            : l10n.tvStatusDisconnected;

    return DetailSectionCard(
      title: l10n.deviceSectionInformations,
      child: Column(
        children: [
          DetailInfoRow(
              label: l10n.deviceInfoLocalIp, value: device.ipAddress),
          AppSpacing.gapSm,
          DetailInfoRow(
            label: l10n.deviceInfoModelLabel,
            value: device.modelName.isEmpty ? '—' : device.modelName,
          ),
          AppSpacing.gapSm,
          DetailInfoRow(label: l10n.deviceInfoConnection, value: connLabel),
        ],
      ),
    );
  }
}
