import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/device_accent_scope.dart';
import '../../../../core/utils/time_label.dart';
import '../../../../domain/entities/equipment.dart';
import '../../../../domain/entities/history_window.dart';
import '../../../../domain/entities/sensor_alert.dart';
import '../../../../domain/repositories/equipment_repository.dart';
import '../../../../domain/repositories/room_repository.dart';
import '../../../live/controllers/live_polling_controller.dart';
import '../../../live/widgets/charts/line_chart/history_range_chips.dart';
import '../../../live/widgets/charts/line_chart/interactive_line_chart.dart';
import '../../shared/mixins/device_detail_mixin.dart';
import '../../shared/widgets/detail_header_card.dart';
import '../../shared/widgets/device_room_card.dart';
import '../../shared/widgets/detail_info_row.dart';
import '../../shared/widgets/detail_menu_item_row.dart';
import '../../shared/widgets/detail_offline_banner.dart';
import '../../shared/widgets/detail_section_card.dart';
import '../../shared/widgets/device_alerts_section.dart';
import '../../shared/widgets/device_stat_box.dart';
import '../../shared/widgets/sensor_alert_sheet.dart';
import '../controllers/thermometer_controller.dart';

enum _MenuAction { refresh, editName, delete }

const _accentColor = AppColors.thermometerAccent;

class ThermometerDetailScreen extends StatefulWidget {
  final Equipment equipment;

  const ThermometerDetailScreen({super.key, required this.equipment});

  @override
  State<ThermometerDetailScreen> createState() =>
      _ThermometerDetailScreenState();
}

class _ThermometerDetailScreenState extends State<ThermometerDetailScreen>
    with DeviceDetailMixin<ThermometerDetailScreen> {
  late final ThermometerController _ctrl; 
  HistoryWindow _historyWindow = HistoryWindow.d1;

  @override
  void initState() {
    super.initState();
    _ctrl = ThermometerController(
      equipment: widget.equipment,
      equipmentRepo: context.read<EquipmentRepository>(),
      roomRepo: context.read<RoomRepository>(),
      live: context.read<LivePollingController>(),
      storage: context.read<LocalStorage>(),
    );
    _ctrl.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onUpdate);
    _ctrl.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  // ── Menu ─────────────────────────────────────────────────────────────────────

  Future<void> _handleMenuAction(_MenuAction action) async {
    switch (action) {
      case _MenuAction.refresh:
        try {
          await _ctrl.refresh();
        } catch (err) {
          showDeviceError(err);
        }
      case _MenuAction.editName:
        await editDeviceName(
          currentName: _ctrl.equipment.name,
          onUpdate: _ctrl.updateName,
        );
      case _MenuAction.delete:
        if (await confirmDeviceDelete(_ctrl.equipment.name) != true) return;
        try {
          await _ctrl.delete();
        } catch (err) {
          showDeviceError(err);
          return;
        }
        if (!mounted) return;
        Navigator.of(context).pop(true);
    }
  }

  // ── Alerts ───────────────────────────────────────────────────────────────────

  Future<void> _addAlert() async {
    final alert = await SensorAlertSheet.show(
      context,
      equipmentId: _ctrl.equipment.id,
      isHumidity: false,
    );
    if (alert == null || !mounted) return;
    await _ctrl.addAlert(alert);
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final e = _ctrl.equipment;
    final liveState = _ctrl.liveState;
    final isOnline = liveState?.online ?? false;
    final temp = liveState?.temperatureC;
    final trendT = liveState?.trendTemperature ?? 0;
    final history = _ctrl.historyOf(_historyWindow);

    // Compute stats from history
    final todayHistory = _ctrl.historyOf(HistoryWindow.d1);
    final weekHistory = _ctrl.historyOf(HistoryWindow.w1);
    final monthHistory = _ctrl.historyOf(HistoryWindow.m1);

    final todayTemps = todayHistory.map((p) => p.powerW).toList();
    final double? todayMin = todayTemps.isEmpty
        ? null
        : todayTemps.reduce((a, b) => a < b ? a : b).toDouble();
    final double? todayMax = todayTemps.isEmpty
        ? null
        : todayTemps.reduce((a, b) => a > b ? a : b).toDouble();
    final double? amplitude =
        (todayMin != null && todayMax != null) ? todayMax - todayMin : null;

    final double? avgWeek = weekHistory.isEmpty
        ? null
        : weekHistory.map((p) => p.powerW).reduce((a, b) => a + b) /
            weekHistory.length;
    final double? avgMonth = monthHistory.isEmpty
        ? null
        : monthHistory.map((p) => p.powerW).reduce((a, b) => a + b) /
            monthHistory.length;

    // Chart bounds
    final chartValues = history.map((p) => p.powerW).toList();
    final minY = chartValues.isEmpty
        ? 0.0
        : (chartValues.reduce((a, b) => a < b ? a : b) - 2).toDouble();
    final maxY = chartValues.isEmpty
        ? 40.0
        : (chartValues.reduce((a, b) => a > b ? a : b) + 2).toDouble();

    return DeviceAccentScope(
      accentColor: _accentColor,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.card,
          surfaceTintColor: Colors.transparent,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.45),
          leading: const BackButton(),
          title: GestureDetector(
            onTap: () => editDeviceName(
              currentName: _ctrl.equipment.name,
              onUpdate: _ctrl.updateName,
            ),
            child: Text(
              e.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppFontSizes.heading,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          actions: [
            PopupMenuButton<_MenuAction>(
              icon: const Icon(Icons.more_vert),
              color: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBR),
              onSelected: _handleMenuAction,
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _MenuAction.refresh,
                  child: DetailMenuItemRow(
                    icon: Icons.refresh_rounded,
                    label: context.l10n.smartPlugMenuRefresh,
                  ),
                ),
                PopupMenuItem(
                  value: _MenuAction.editName,
                  child: DetailMenuItemRow(
                    icon: Icons.label_outline_rounded,
                    label: context.l10n.detailsEditNameTooltip,
                  ),
                ),
                PopupMenuItem(
                  value: _MenuAction.delete,
                  child: DetailMenuItemRow(
                    icon: Icons.delete_outline_rounded,
                    label: context.l10n.smartPlugMenuDelete,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            children: [
              // ── 1. Header card ───────────────────────────────────────────
              DetailHeaderCard(
                isFavorite: e.isFavorite,
                typeLabel: context.l10n.thermometerTypeLabel,
                icon: Icons.thermostat_rounded,
                accentColor: _accentColor,
                isOnline: isOnline,
                isOn: isOnline,
                toggling: false,
                lastUpdatedAt: liveState?.lastUpdatedAt,
                onToggle: () {},
                onFavorite: () => _ctrl.toggleFavorite(),
              ),
              AppSpacing.gapXl,

              // ── 2. Offline banner ────────────────────────────────────────
              if (!isOnline && liveState != null) ...[
                DetailOfflineBanner(label: context.l10n.smartPlugLastKnownValues),
                AppSpacing.gapMd,
              ],

              // ── 3. Live reading ──────────────────────────────────────────
              DetailSectionCard(
                title: context.l10n.detailSectionLive,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          temp != null
                              ? '${temp.toStringAsFixed(1)} °C'
                              : '— °C',
                          style: const TextStyle(
                            fontSize: AppFontSizes.kpi,
                            fontWeight: FontWeight.w700,
                            color: _accentColor,
                          ),
                        ),
                        if (trendT != 0) ...[
                          AppSpacing.gapHSm,
                          Icon(
                            trendT > 0
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 20,
                            color: trendT > 0
                                ? Colors.orange
                                : Colors.lightBlueAccent,
                          ),
                          AppSpacing.gapHXxs,
                          Text(
                            trendT > 0 ? context.l10n.detailTrendRising : context.l10n.detailTrendFalling,
                            style: const TextStyle(
                              fontSize: AppFontSizes.sm,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (liveState?.lastUpdatedAt != null) ...[
                      AppSpacing.gapXxs,
                      Text(
                        ageLabel(context, liveState!.lastUpdatedAt),
                        style: const TextStyle(
                          fontSize: AppFontSizes.sm,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],

                    // Stats row: avg week, avg month
                    if (avgWeek != null || avgMonth != null) ...[
                      AppSpacing.gapX2l,
                      Row(
                        children: [
                          if (avgWeek != null)
                            DeviceStatBox(
                              label: context.l10n.detailStatAvgWeek,
                              value: '${avgWeek.toStringAsFixed(1)} °C',
                            ),
                          if (avgWeek != null && avgMonth != null)
                            AppSpacing.gapHXl,
                          if (avgMonth != null)
                            DeviceStatBox(
                              label: context.l10n.detailStatAvgMonth,
                              value: '${avgMonth.toStringAsFixed(1)} °C',
                            ),
                        ],
                      ),
                    ],

                    // MIN / MAX / Amplitude row
                    if (todayMin != null) ...[
                      AppSpacing.gapX2l,
                      Row(
                        children: [
                          DeviceStatBox(
                            label: context.l10n.detailStatMin,
                            value: '${todayMin.toStringAsFixed(1)} °C',
                            valueColor: Colors.lightBlueAccent,
                          ),
                          AppSpacing.gapHXl,
                          DeviceStatBox(
                            label: context.l10n.detailStatMax,
                            value: '${todayMax!.toStringAsFixed(1)} °C',
                            valueColor: Colors.orange,
                          ),
                          if (amplitude != null) ...[
                            AppSpacing.gapHXl,
                            DeviceStatBox(
                              label: context.l10n.detailStatAmplitude,
                              value: '${amplitude.toStringAsFixed(1)}°',
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              AppSpacing.gapXl,

              // ── 4. Historic chart ────────────────────────────────────────
              DetailSectionCard(
                title: context.l10n.detailSectionHistoric,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HistoryRangeChips(
                      value: _historyWindow,
                      onChanged: (w) => setState(() => _historyWindow = w),
                    ),
                    AppSpacing.gapLg,
                    InteractiveLineChart(
                      points: history,
                      window: _historyWindow,
                      minY: minY,
                      maxY: maxY,
                      height: 160,
                      powerUnitLabel: '°C',
                    ),
                  ],
                ),
              ),

              AppSpacing.gapXl,

              // ── 5. Alerts ────────────────────────────────────────────────
              DeviceAlertsSection(
                alerts: _ctrl.alerts,
                unit: '°C',
                onAdd: _addAlert,
                onRemove: (id) => _ctrl.removeAlert(id),
                alertTitleBuilder: (a) => a.condition == SensorAlertCondition.above
                    ? 'Too hot if'
                    : 'Freeze if',
              ),

              AppSpacing.gapXl,

              // ── 6. Informations ──────────────────────────────────────────
              DetailSectionCard(
                title: context.l10n.detailSectionInformations,
                child: Column(
                  children: [
                    DetailInfoRow(
                      label: context.l10n.smartPlugInfoLocalIp,
                      value: e.ip,
                    ),
                    AppSpacing.gapSm,
                    DetailInfoRow(
                      label: context.l10n.smartPlugInfoModel,
                      value: context.l10n.thermometerTypeLabel,
                    ),
                    AppSpacing.gapSm,
                    DetailInfoRow(
                      label: context.l10n.smartPlugInfoConnection,
                      value: isOnline ? context.l10n.smartPlugWifi : context.l10n.netStatusOffline,
                    ),
                  ],
                ),
              ),

              AppSpacing.gapXl,

              // ── 7. Room picker ────────────────────────────────────────────
              DeviceRoomCard(
                roomName: _ctrl.roomName(context.l10n.none),
                onTap: () => pickDeviceRoom(
                  rooms: _ctrl.rooms,
                  currentRoomId: _ctrl.equipment.roomId,
                  onUpdate: _ctrl.updateRoom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

