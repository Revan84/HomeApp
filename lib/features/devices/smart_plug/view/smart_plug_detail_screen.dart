import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/theme/device_accent_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/equipment.dart';
import '../../../../domain/repositories/equipment_repository.dart';
import '../../../../domain/repositories/room_repository.dart';
import '../../../home/controllers/home_controller.dart';
import '../../../live/controllers/live_polling_controller.dart';
import '../controllers/smart_plug_controller.dart';
import '../../../equipments/dialogs/equipment_edit_dialogs.dart';
import '../../shared/mixins/device_detail_mixin.dart';
import '../../shared/widgets/detail_header_card.dart';
import '../../shared/widgets/device_room_card.dart';
import '../../shared/widgets/detail_menu_item_row.dart';
import '../../shared/widgets/detail_offline_banner.dart';
import '../widgets/smart_plug_alert_sheet.dart';
import '../widgets/smart_plug_alerts_section.dart';
import '../widgets/smart_plug_consumption_section.dart';
import '../widgets/smart_plug_info_section.dart';
import '../widgets/smart_plug_kpi_card.dart';
import '../widgets/smart_plug_timeline_section.dart';

enum _MenuAction { refresh, edit, delete }

class SmartPlugDetailScreen extends StatefulWidget {
  const SmartPlugDetailScreen({super.key, required this.equipment});

  final Equipment equipment;

  @override
  State<SmartPlugDetailScreen> createState() => _SmartPlugDetailScreenState();
}

class _SmartPlugDetailScreenState extends State<SmartPlugDetailScreen>
    with DeviceDetailMixin<SmartPlugDetailScreen> {
  late final SmartPlugController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = SmartPlugController(
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

  // ── Menu actions ─────────────────────────────────────────────────────────────

  Future<void> _handleMenuAction(_MenuAction action) async {
    switch (action) {
      case _MenuAction.refresh:
        try {
          await _ctrl.refresh();
        } catch (err) {
          showDeviceError(err);
        }
      case _MenuAction.edit:
        await _showEditSheet();
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

  // ── Edit sheet ───────────────────────────────────────────────────────────────

  Future<void> _showEditSheet() async {
    final l10n = context.l10n;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTopBR),
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (_, setSheetState) {
          final e = _ctrl.equipment;

          Future<void> run(Future<void> Function() action) async {
            await action();
            setSheetState(() {});
          }

          Widget sheetRow({
            required IconData icon,
            required String label,
            required String value,
            required VoidCallback onTap,
          }) =>
              ListTile(
                leading: Icon(icon, color: AppColors.textSecondary, size: 20),
                title: Text(label,
                    style: const TextStyle(
                        fontSize: AppFontSizes.sm,
                        color: AppColors.textSecondary)),
                subtitle: Text(value,
                    style: const TextStyle(
                        fontSize: AppFontSizes.body,
                        color: AppColors.textPrimary)),
                trailing: const Icon(Icons.edit_outlined,
                    size: 15, color: AppColors.textSecondary),
                onTap: onTap,
              );

          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSpacing.gapXl,
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: AppRadius.xsBR,
                  ),
                ),
                AppSpacing.gapX2l,
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.x2l),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(l10n.smartPlugMenuEdit,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: AppFontSizes.sectionTitle,
                            color: AppColors.textPrimary)),
                  ),
                ),
                AppSpacing.gapMd,
                const Divider(height: 1, color: AppColors.border),
                sheetRow(
                  icon: Icons.label_outline_rounded,
                  label: l10n.detailsEditNameTooltip,
                  value: e.name,
                  onTap: () => run(() async {
                    final next = await EquipmentEditDialogs.editName(
                        context, currentName: e.name);
                    if (next == null) return;
                    await _ctrl.updateName(next);
                  }),
                ),
                const Divider(indent: 56, height: 1, color: AppColors.border),
                sheetRow(
                  icon: Icons.router_outlined,
                  label: l10n.smartPlugInfoLocalIp,
                  value: e.ip,
                  onTap: () => run(() async {
                    final next = await EquipmentEditDialogs.editLocalIp(
                        context, currentIp: e.ip);
                    if (next == null) return;
                    await _ctrl.updateIp(next);
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── kWh price editor ─────────────────────────────────────────────────────────

  Future<void> _editKwhPrice() async {
    final homeCtl = context.read<HomeController>();
    final l10n = context.l10n;
    final controller =
        TextEditingController(text: homeCtl.kwhPrice.toStringAsFixed(2));

    final result = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.smartPlugEditKwhPriceTitle),
        content: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            suffixText: '€/kWh',
            hintText: '0.20',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final val =
                  double.tryParse(controller.text.replaceAll(',', '.'));
              if (val != null && val > 0) Navigator.pop(context, val);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    controller.dispose();
    if (result == null || !mounted) return;
    try {
      await homeCtl.setKwhPrice(result);
    } catch (err) {
      showDeviceError(err);
    }
  }

  // ── Alert add ────────────────────────────────────────────────────────────────

  Future<void> _addAlert() async {
    final alert = await SmartPlugAlertSheet.show(
      context,
      equipmentId: _ctrl.equipment.id,
    );
    if (alert == null || !mounted) return;
    try {
      await _ctrl.addAlert(alert);
    } catch (err) {
      showDeviceError(err);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final e = _ctrl.equipment;

    final liveCtl = context.watch<LivePollingController>();
    final liveState = liveCtl.live[e.id];
    final kwhPrice = context.watch<HomeController>().kwhPrice;

    final isOnline = liveState?.online ?? false;
    final isOn = liveState?.output ?? false;
    final toggling = liveState?.toggling ?? false;
    final todayWh = _ctrl.todayEnergyWh;

    final SmartPlugLiveData? liveData = liveState == null
        ? null
        : SmartPlugLiveData(
            watts: liveState.powerW?.toStringAsFixed(0) ?? '—',
            costPerHour: liveState.powerW != null
                ? (liveState.powerW! / 1000 * kwhPrice).toStringAsFixed(2)
                : '—',
            costToday: todayWh > 0
                ? (todayWh / 1000 * kwhPrice).toStringAsFixed(2)
                : '—',
            kwhCumulated: liveState.energyWh != null
                ? (liveState.energyWh! / 1000).toStringAsFixed(3)
                : '—',
            trendPower: liveState.trendPower,
          );

    return DeviceAccentScope(
      accentColor: AppColors.plugAccent,
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
            child: Flexible(
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
                      label: l10n.smartPlugMenuRefresh),
                ),
                PopupMenuItem(
                  value: _MenuAction.edit,
                  child: DetailMenuItemRow(
                      icon: Icons.edit_outlined,
                      label: l10n.smartPlugMenuEdit),
                ),
                PopupMenuItem(
                  value: _MenuAction.delete,
                  child: DetailMenuItemRow(
                    icon: Icons.delete_outline_rounded,
                    label: l10n.smartPlugMenuDelete,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              DetailHeaderCard(
                isFavorite: e.isFavorite,
                typeLabel: l10n.smartPlugSubtitle,
                icon: Icons.bolt_rounded,
                accentColor: AppColors.plugAccent,
                isOnline: isOnline,
                isOn: isOn,
                toggling: toggling,
                lastUpdatedAt: liveState?.lastUpdatedAt,
                onToggle: _ctrl.toggle,
                onFavorite: _ctrl.toggleFavorite,
              ),
              AppSpacing.gapXl,
              if (!isOnline && liveData != null) ...[
                DetailOfflineBanner(label: l10n.smartPlugLastKnownValues),
                AppSpacing.gapMd,
              ],
              liveData == null
                  ? const SmartPlugKpiLoading()
                  : SmartPlugKpiCard(
                      live: liveData,
                      kwhPrice: kwhPrice,
                      isOffline: !isOnline,
                      onEditKwhPrice: _editKwhPrice,
                    ),
              AppSpacing.gapXl,
              SmartPlugConsumptionSection(
                  equipmentId: e.id, unitLabel: l10n.smartPlugKpiUnit),
              AppSpacing.gapXl,
              SmartPlugTimelineSection(
                  equipmentId: e.id, unitLabel: l10n.smartPlugKpiUnit),
              AppSpacing.gapXl,
              SmartPlugAlertsSection(
                alerts: _ctrl.alerts,
                onAdd: _addAlert,
                onToggle: _ctrl.toggleAlert,
                onDelete: _ctrl.deleteAlert,
              ),
              AppSpacing.gapXl,
              SmartPlugInfoSection(equipment: e),
              AppSpacing.gapXl,
              DeviceRoomCard(
                roomName: _ctrl.roomName(l10n.none),
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
