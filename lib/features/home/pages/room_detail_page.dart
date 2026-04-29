import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/design_system/buttons/app_button.dart';
import '../../../core/design_system/tiles/device_list_tile.dart';
import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_font_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/cob_led_cct_device.dart';
import '../../../domain/entities/cob_led_rgb_device.dart';
import '../../../domain/entities/equipment.dart';
import '../../../domain/entities/live_state.dart';
import '../../../domain/entities/room.dart';
import '../../../domain/entities/tv_device.dart';
import '../../devices/cob_led_cct/view/cob_led_cct_detail_screen.dart';
import '../../devices/cob_led_rgb/pages/cob_led_rgb_details_page.dart';
import '../../devices/hygrometer/view/hygrometer_detail_screen.dart';
import '../../devices/smart_plug/view/smart_plug_detail_screen.dart';
import '../../devices/thermometer/view/thermometer_detail_screen.dart';
import '../../devices/tv/view/tv_detail_screen.dart';
import '../../equipments/pages/equipment_details_page.dart';
import '../../live/controllers/live_polling_controller.dart';
import '../controllers/home_controller.dart';

// ── Device display helpers (same as EquipmentsTab / FavoritesPage) ────────────

IconData _iconForType(EquipmentType type) => switch (type) {
      EquipmentType.shellyPlusPlugS ||
      EquipmentType.shellyPlugS =>
        Icons.power_rounded,
      EquipmentType.shellyHT => Icons.thermostat_rounded,
      EquipmentType.hygrometer => Icons.water_drop_outlined,
      _ => Icons.devices_other_rounded,
    };

Color _accentForType(EquipmentType type) => switch (type) {
      EquipmentType.shellyPlusPlugS ||
      EquipmentType.shellyPlugS =>
        AppColors.plugAccent,
      EquipmentType.shellyHT => AppColors.thermometerAccent,
      EquipmentType.hygrometer => AppColors.hygrometerAccent,
      _ => AppColors.primary,
    };

String _typeLabel(EquipmentType type, BuildContext context) => switch (type) {
      EquipmentType.shellyPlusPlugS => context.l10n.statsDeviceTypeSmartPlug,
      EquipmentType.shellyPlugS => 'Smart Plug S',
      EquipmentType.shellyHT => context.l10n.thermometerTypeLabel,
      EquipmentType.hygrometer => context.l10n.hygrometerTypeLabel,
      _ => context.l10n.statsDeviceTypeGeneric,
    };

String _equipmentValue(Equipment e, LiveState? st) {
  if (st == null) return '';
  if (e.type == EquipmentType.shellyHT) {
    return st.temperatureC != null
        ? '${st.temperatureC!.toStringAsFixed(1)} °C'
        : '';
  }
  if (e.type == EquipmentType.hygrometer) {
    return st.humidity != null ? '${st.humidity!.toStringAsFixed(0)} %' : '';
  }
  if (e.type.isPlug && st.powerW != null) {
    return '${st.powerW!.toStringAsFixed(0)} W';
  }
  return '';
}

Color _dotColor(bool? online) =>
    (online ?? false) ? AppColors.success : AppColors.textSecondary;

// ── Page ──────────────────────────────────────────────────────────────────────

/// Detail page for a single room — lists every device assigned to it and
/// lets the user remove devices (unlinks them from the room without deleting).
class RoomDetailPage extends StatefulWidget {
  final Room room;
  final String? groupId;

  const RoomDetailPage({
    super.key,
    required this.room,
    required this.groupId,
  });

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  bool _changed = false;

  // ── Navigation ───────────────────────────────────────────────────────────────

  Future<void> _onEquipmentTap(Equipment e) async {
    final Widget page;
    if (e.type.isPlug) {
      page = SmartPlugDetailScreen(equipment: e);
    } else if (e.type == EquipmentType.shellyHT) {
      page = ThermometerDetailScreen(equipment: e);
    } else if (e.type == EquipmentType.hygrometer) {
      page = HygrometerDetailScreen(equipment: e);
    } else {
      page = EquipmentDetailsPage(equipmentId: e.id);
    }
    final changed =
        await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => page));
    if (changed == true && mounted) {
      _changed = true;
      await context.read<HomeController>().loadAll(widget.groupId);
    }
  }

  Future<void> _onTvTap(TvDevice tv) async {
    final changed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => TvDetailScreen(device: tv)));
    if (changed == true && mounted) {
      _changed = true;
      await context.read<HomeController>().loadAll(widget.groupId);
    }
  }

  Future<void> _onCobLedRgbTap(String deviceId) async {
    final changed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => CobLedRgbDetailsPage(deviceId: deviceId)));
    if (changed == true && mounted) {
      _changed = true;
      await context.read<HomeController>().loadAll(widget.groupId);
    }
  }

  Future<void> _onCobLedCctTap(CobLedCctDevice cct) async {
    final changed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => CobLedCctDetailScreen(device: cct)));
    if (changed == true && mounted) {
      _changed = true;
      await context.read<HomeController>().loadAll(widget.groupId);
    }
  }

  // ── Remove from room ─────────────────────────────────────────────────────────

  /// Shows a confirmation sheet that makes it clear the device is only
  /// unlinked from the room and NOT deleted from the system.
  Future<bool> _confirmUnlink(String deviceName) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.roomDetailUnlinkTitle,
              style: const TextStyle(
                fontFamily: 'ShareTech',
                fontWeight: FontWeight.w600,
                fontSize: AppFontSizes.sectionTitle,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.x2l),
            Text(
              context.l10n.roomDetailUnlinkMessage(deviceName),
              style: const TextStyle(
                fontFamily: 'ShareTech',
                fontSize: AppFontSizes.body,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.x3l),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  label: context.l10n.cancel,
                  variant: AppButtonVariant.ghost,
                  compact: true,
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
                const SizedBox(width: AppSpacing.md),
                AppButton(
                  label: context.l10n.roomDetailUnlinkConfirm,
                  variant: AppButtonVariant.secondary,
                  compact: true,
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return confirmed == true;
  }

  Future<void> _removeEquipment(Equipment e) async {
    if (!await _confirmUnlink(e.name) || !mounted) return;
    await context.read<HomeController>().removeEquipmentFromRoom(e);
    _changed = true;
  }

  Future<void> _removeTv(TvDevice tv) async {
    if (!await _confirmUnlink(tv.name) || !mounted) return;
    await context.read<HomeController>().removeTvFromRoom(tv);
    _changed = true;
  }

  Future<void> _removeCobLedRgb(CobLedRgbDevice d) async {
    if (!await _confirmUnlink(d.name) || !mounted) return;
    await context.read<HomeController>().removeCobLedRgbFromRoom(d);
    _changed = true;
  }

  Future<void> _removeCobLedCct(CobLedCctDevice c) async {
    if (!await _confirmUnlink(c.name) || !mounted) return;
    await context.read<HomeController>().removeCobLedCctFromRoom(c);
    _changed = true;
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<HomeController>();
    final liveCtl = context.watch<LivePollingController>();
    final roomId = widget.room.id;

    final equipments = ctrl.equipmentsForRoom(roomId);
    final tvDevices = ctrl.tvDevicesForRoom(roomId);
    final cobLedRgbs = ctrl.cobLedRgbDevicesForRoom(roomId);
    final cobLedCcts = ctrl.cobLedCctDevicesForRoom(roomId);

    final totalCount =
        equipments.length + tvDevices.length + cobLedRgbs.length + cobLedCcts.length;
    final onlineCount =
        equipments.where((e) => liveCtl.live[e.id]?.online == true).length;

    // Each row: Expanded(DeviceListTile) + unlink button outside the card
    Widget removeRow({
      required Widget tile,
      required VoidCallback onRemove,
    }) =>
        Row(
          children: [
            Expanded(child: tile),
            IconButton(
              tooltip: context.l10n.roomDetailRemoveTooltip,
              onPressed: onRemove,
              icon: const Icon(
                Icons.link_off_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );

    final tiles = <Widget>[
      for (final e in equipments)
        removeRow(
          onRemove: () => _removeEquipment(e),
          tile: DeviceListTile(
            icon: _iconForType(e.type),
            iconColor: _accentForType(e.type),
            title: e.name,
            subtitle: _typeLabel(e.type, context),
            liveValue: _equipmentValue(e, liveCtl.live[e.id]).isNotEmpty
                ? _equipmentValue(e, liveCtl.live[e.id])
                : null,
            dotColor: _dotColor(liveCtl.live[e.id]?.online),
            onTap: () => _onEquipmentTap(e),
          ),
        ),
      for (final tv in tvDevices)
        removeRow(
          onRemove: () => _removeTv(tv),
          tile: DeviceListTile(
            icon: Icons.tv_rounded,
            iconColor: Colors.blueGrey,
            title: tv.name,
            subtitle: context.l10n.deviceTypeTv,
            dotColor: _dotColor(liveCtl.live[tv.id]?.online),
            onTap: () => _onTvTap(tv),
          ),
        ),
      for (final d in cobLedRgbs)
        removeRow(
          onRemove: () => _removeCobLedRgb(d),
          tile: DeviceListTile(
            icon: Icons.lightbulb_outline_rounded,
            iconColor: AppColors.cobLedRgbAccent,
            title: d.name,
            subtitle: context.l10n.cobLedRgbTypeLabel,
            dotColor: _dotColor(liveCtl.live[d.id]?.online),
            onTap: () => _onCobLedRgbTap(d.id),
          ),
        ),
      for (final cct in cobLedCcts)
        removeRow(
          onRemove: () => _removeCobLedCct(cct),
          tile: DeviceListTile(
            icon: Icons.wb_incandescent_outlined,
            iconColor: AppColors.cobLedCctAccent,
            title: cct.name,
            subtitle: context.l10n.cobLedCctTypeLabel,
            liveValue: cct.activeSceneId.isNotEmpty
                ? cct.scenes
                    .where((s) => s.id == cct.activeSceneId)
                    .firstOrNull
                    ?.name
                : null,
            dotColor: _dotColor(liveCtl.live[cct.id]?.online),
            onTap: () => _onCobLedCctTap(cct),
          ),
        ),
    ];

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && _changed) {
          // Already popped — caller checks return value via Navigator.pop.
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.card,
          surfaceTintColor: Colors.transparent,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.45),
          leading: BackButton(
            onPressed: () => Navigator.of(context).pop(_changed),
          ),
          title: Text(
            widget.room.name,
            style: const TextStyle(
              fontFamily: 'ShareTech',
              fontWeight: FontWeight.w600,
              fontSize: AppFontSizes.heading,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => context.read<HomeController>().loadAll(widget.groupId),
              icon: const Icon(Icons.refresh_rounded),
              color: AppColors.textSecondary,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Stats ────────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x3l,
                  AppSpacing.x3l,
                  AppSpacing.x3l,
                  0,
                ),
                child: Text(
                  '$onlineCount / $totalCount online',
                  style: const TextStyle(
                    fontFamily: 'ShareTech',
                    fontSize: AppFontSizes.sm,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              AppSpacing.gapX5l,

              // ── Device list ──────────────────────────────────────────────────
              Expanded(
                child: ctrl.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : tiles.isEmpty
                        ? Center(
                            child: Text(
                              context.l10n.statsNoDevicesInRoom,
                              style: const TextStyle(
                                fontFamily: 'ShareTech',
                                fontSize: AppFontSizes.body,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.x3l,
                              0,
                              AppSpacing.x3l,
                              100,
                            ),
                            itemCount: tiles.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.x3l),
                            itemBuilder: (_, i) => tiles[i],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
