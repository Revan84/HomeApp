import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/device_accent_scope.dart';
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
import '../../shared/widgets/sensor_alert_sheet.dart';
import '../controllers/hygrometer_controller.dart';
import '../widgets/hygrometer_live_section.dart';

enum _MenuAction { refresh, editName, delete }

const _accentColor = AppColors.hygrometerAccent;

class HygrometerDetailScreen extends StatefulWidget {
  final Equipment equipment;

  const HygrometerDetailScreen({super.key, required this.equipment});

  @override
  State<HygrometerDetailScreen> createState() => _HygrometerDetailScreenState();
}

class _HygrometerDetailScreenState extends State<HygrometerDetailScreen>
    with DeviceDetailMixin<HygrometerDetailScreen> {
  late final HygrometerController _ctrl;
  HistoryWindow _historyWindow = HistoryWindow.d1;

  @override
  void initState() {
    super.initState();
    _ctrl = HygrometerController(
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
      isHumidity: true,
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
    final humidity = liveState?.humidity;
    final temp = liveState?.temperatureC;
    final double trendH = (liveState?.trendHumidity ?? 0).toDouble();
    final history = _ctrl.historyOf(_historyWindow);

    // Chart bounds: 0–100 for humidity
    final chartValues = history.map((p) => p.powerW).toList();
    final minY = chartValues.isEmpty
        ? 0.0
        : (chartValues.reduce((a, b) => a < b ? a : b) - 5).clamp(0.0, 100.0);
    final maxY = chartValues.isEmpty
        ? 100.0
        : (chartValues.reduce((a, b) => a > b ? a : b) + 5).clamp(0.0, 100.0);

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
                    label: context.l10n.deviceMenuRefresh,
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
                    label: context.l10n.deviceMenuDelete,
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
                typeLabel: 'Hygrometer',
                icon: Icons.water_drop_rounded,
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
                DetailOfflineBanner(label: context.l10n.deviceLastKnownValues),
                AppSpacing.gapMd,
              ],

              // ── 3. Live reading ──────────────────────────────────────────
              HygrometerLiveSection(
                humidity: humidity,
                trendH: trendH,
                liveState: liveState,
                todayHistory: _ctrl.historyOf(HistoryWindow.d1),
                weekHistory: _ctrl.historyOf(HistoryWindow.w1),
                monthHistory: _ctrl.historyOf(HistoryWindow.m1),
              ),

              AppSpacing.gapXl,

              // ── 4. Temperature (if available) ────────────────────────────
              if (temp != null) ...[
                DetailSectionCard(
                  title: context.l10n.detailSectionTemperature,
                  child: Text(
                    '${temp.toStringAsFixed(1)} °C',
                    style: const TextStyle(
                      fontSize: AppFontSizes.heading,
                      fontWeight: FontWeight.w600,
                      color: AppColors.thermometerAccent,
                    ),
                  ),
                ),
                AppSpacing.gapXl,
              ],

              // ── 5. Historic chart ────────────────────────────────────────
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
                      powerUnitLabel: '%',
                    ),
                  ],
                ),
              ),

              AppSpacing.gapXl,

              // ── 6. Alerts ────────────────────────────────────────────────
              DeviceAlertsSection(
                alerts: _ctrl.alerts,
                unit: '%',
                onAdd: _addAlert,
                onToggle: (id) => _ctrl.toggleAlert(id),
                onRemove: (id) => _ctrl.removeAlert(id),
                alertTitleBuilder: (a) => a.condition == SensorAlertCondition.above
                    ? 'Too wet if'
                    : 'Too dry if',
              ),

              AppSpacing.gapXl,

              // ── 7. Informations ──────────────────────────────────────────
              DetailSectionCard(
                title: context.l10n.detailSectionInformations,
                child: Column(
                  children: [
                    DetailInfoRow(
                      label: context.l10n.deviceInfoLocalIp,
                      value: e.ip,
                    ),
                    AppSpacing.gapSm,
                    DetailInfoRow(
                      label: context.l10n.deviceInfoModelLabel,
                      value: context.l10n.hygrometerTypeLabel,
                    ),
                    AppSpacing.gapSm,
                    DetailInfoRow(
                      label: context.l10n.deviceInfoConnection,
                      value: isOnline ? context.l10n.deviceConnectionWifi : context.l10n.netStatusOffline,
                    ),
                  ],
                ),
              ),

              AppSpacing.gapXl,

              // ── 8. Room picker ────────────────────────────────────────────
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


