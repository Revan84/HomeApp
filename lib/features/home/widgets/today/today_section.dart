import 'package:flutter/material.dart';
import 'package:front_end/core/theme/app_shadows.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../domain/entities/live_state.dart';
import '../../../live/controllers/live_polling_controller.dart';
import '../../controllers/home_controller.dart';
import '../../../../core/i18n/loc.dart';
import '../../domain/today_widget_type.dart';
import 'today_manage_sheet.dart';
import 'today_stat_tile.dart';

/// Horizontal scrollable row of aggregated today stats + "+" manage button.
///
/// Reads from [HomeController] and [LivePollingController]; no business logic.
class TodaySection extends StatelessWidget {
  const TodaySection({super.key, required this.groupId});

  final String? groupId;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    final live = context.watch<LivePollingController>().live;

    final tiles = _buildTiles(context, controller, live);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...tiles.map(
              (tile) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: tile,
              ),
            ),
            _AddTile(onTap: () => _openManageSheet(context)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTiles(
    BuildContext context,
    HomeController controller,
    Map<String, LiveState> live,
  ) {
    final visible = controller.visibleTodayWidgets;
    final tiles = <Widget>[];

    for (final type in visible) {
      switch (type) {
        case TodayWidgetType.consumption:
          final kwh = controller.totalEnergyKwh(groupId, live);
          final cost = controller.estimatedCost(kwh);
          tiles.add(
            TodayStatTile(
              icon: Icons.bolt_rounded,
              value: '${kwh.toStringAsFixed(1)} kWh',
              subValue: '${cost.toStringAsFixed(2)}€',
              label: context.l10n.homeTodayConsumptionLabel,
              accentColor: AppColors.plugAccent,
            ),
          );

        case TodayWidgetType.temperature:
          final temp = controller.averageTemperature(groupId, live);
          if (temp != null) {
            tiles.add(
              TodayStatTile(
                icon: Icons.thermostat_rounded,
                value: '${temp.toStringAsFixed(1)} °C',
                label: context.l10n.homeTodayAvgTempLabel,
                accentColor: AppColors.thermometerAccent,
              ),
            );
          }

        case TodayWidgetType.humidity:
          final hum = controller.averageHumidity(groupId, live);
          if (hum != null) {
            tiles.add(
              TodayStatTile(
                icon: Icons.water_drop_rounded,
                value: '${hum.toStringAsFixed(0)}%',
                label: context.l10n.homeTodayHumidityLabel,
                accentColor: AppColors.hygrometerAccent,
              ),
            );
          }
      }
    }

    return tiles;
  }

  void _openManageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTopBR),
      builder: (_) => const TodayManageSheet(),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: AppShadows.subtle,
          borderRadius: AppRadius.smBR,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: const Center(
          child: Icon(
            Icons.add_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }
}
