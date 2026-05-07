import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/design_system/chips/app_chip.dart';
import '../../../core/design_system/tiles/device_list_tile.dart';
import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_font_sizes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/cob_led_cct_device.dart';
import '../../../domain/entities/cob_led_rgb_device.dart';
import '../../../domain/entities/equipment.dart';
import '../../../domain/entities/live_state.dart';
import '../../../domain/entities/tv_device.dart';
import '../../devices/cob_led_cct/view/detail_screen.dart';
import '../../devices/cob_led_rgb/pages/cob_led_rgb_details_page.dart';
import '../../devices/hygrometer/view/hygrometer_detail_screen.dart';
import '../../devices/smart_plug/view/smart_plug_detail_screen.dart';
import '../../devices/thermometer/view/thermometer_detail_screen.dart';
import '../../devices/tv/view/tv_detail_screen.dart';
import '../../equipments/pages/equipment_details_page.dart';
import '../../equipments/widgets/equipments_search_bar.dart';
import '../../live/controllers/live_polling_controller.dart';
import '../controllers/home_controller.dart';

// ── Device display helpers (mirrors EquipmentsTab) ────────────────────────────

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

// ── Kind filter enum (same as EquipmentsTab) ──────────────────────────────────

enum _DeviceKind {
  all,
  equipment,
  tv,
  cobLedRgb,
  cobLedCct,
  thermometer,
  hygrometer,
}

// ── Page ──────────────────────────────────────────────────────────────────────

/// Full-screen device browser with per-row favorite toggle.
///
/// Layout mirrors [EquipmentsTab] exactly — same header style, same search bar,
/// same room chips, same [DeviceListTile] — with the single addition of a heart
/// [IconButton] on each row to toggle the favorite flag in real-time.
class FavoritesPage extends StatefulWidget {
  final String? groupId;

  const FavoritesPage({super.key, required this.groupId});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  String? _selectedRoomId;
  _DeviceKind _selectedKind = _DeviceKind.all;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.toLowerCase();
      if (q != _searchQuery) setState(() => _searchQuery = q);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ───────────────────────────────────────────────────────────────

  Future<void> _onEquipmentTap(Equipment equipment) async {
    final Widget page;
    if (equipment.type.isPlug) {
      page = SmartPlugDetailScreen(equipment: equipment);
    } else if (equipment.type == EquipmentType.shellyHT) {
      page = ThermometerDetailScreen(equipment: equipment);
    } else if (equipment.type == EquipmentType.hygrometer) {
      page = HygrometerDetailScreen(equipment: equipment);
    } else {
      page = EquipmentDetailsPage(equipmentId: equipment.id);
    }
    final changed = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => page));
    if (changed == true && mounted) {
      await context.read<HomeController>().loadAll(widget.groupId);
    }
  }

  Future<void> _onTvTap(TvDevice tv) async {
    final changed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => TvDetailScreen(device: tv)));
    if (changed == true && mounted) {
      await context.read<HomeController>().loadAll(widget.groupId);
    }
  }

  Future<void> _onCobLedRgbTap(String deviceId) async {
    final changed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => CobLedRgbDetailsPage(deviceId: deviceId)));
    if (changed == true && mounted) {
      await context.read<HomeController>().loadAll(widget.groupId);
    }
  }

  Future<void> _onCobLedCctTap(CobLedCctDevice device) async {
    final changed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => CobLedCctDetailScreen(device: device)));
    if (changed == true && mounted) {
      await context.read<HomeController>().loadAll(widget.groupId);
    }
  }

  // ── Type filter menu ─────────────────────────────────────────────────────────

  Future<void> _showTypeMenu() async {
    final l10n = context.l10n;
    final items = [
      (_DeviceKind.all, l10n.equipmentsFilterAllTypes),
      (_DeviceKind.equipment, l10n.statsDeviceTypeSmartPlug),
      (_DeviceKind.tv, l10n.deviceTypeTv),
      (_DeviceKind.cobLedRgb, l10n.cobLedRgbTypeLabel),
      (_DeviceKind.cobLedCct, l10n.cobLedCctTypeLabel),
      (_DeviceKind.thermometer, l10n.thermometerTypeLabel),
      (_DeviceKind.hygrometer, l10n.hygrometerTypeLabel),
    ];

    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    final size = overlay.size;
    final pos = RelativeRect.fromLTRB(
      size.width - 220,
      140,
      16,
      size.height - 140,
    );

    final result = await showMenu<_DeviceKind>(
      context: context,
      position: pos,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBR),
      items: items
          .map((e) => PopupMenuItem<_DeviceKind>(
                value: e.$1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedKind == e.$1)
                      const Icon(Icons.check_rounded,
                          color: AppColors.primary, size: 18)
                    else
                      const SizedBox(width: 18),
                    AppSpacing.gapHMd,
                    Text(
                      e.$2,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
    if (result != null && mounted) setState(() => _selectedKind = result);
  }

  // ── Room count helper ────────────────────────────────────────────────────────

  int _countForRoom(
    String roomId,
    List<Equipment> equips,
    List<TvDevice> tvs,
    List<CobLedRgbDevice> rgbs,
    List<CobLedCctDevice> ccts,
  ) =>
      equips.where((e) => e.roomId == roomId).length +
      tvs.where((t) => t.roomId == roomId).length +
      rgbs.where((d) => d.roomId == roomId).length +
      ccts.where((d) => d.roomId == roomId).length;

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<HomeController>();
    final liveCtl = context.watch<LivePollingController>();

    if (ctrl.isLoading) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    // ── Unfiltered lists (used for counts + room chips) ──────────────────────
    final roomIds = ctrl.visibleRoomIds(widget.groupId);
    final rooms = ctrl.visibleRooms(widget.groupId);

    final allEquipments =
        ctrl.allEquipments.where((e) => roomIds.contains(e.roomId)).toList();
    final allTvDevices =
        ctrl.allTvDevices.where((t) => roomIds.contains(t.roomId)).toList();
    final allCobLedRgbDevices =
        ctrl.allCobLedRgbDevices.where((d) => roomIds.contains(d.roomId)).toList();
    final allCobLedCctDevices =
        ctrl.allCobLedCctDevices.where((c) => roomIds.contains(c.roomId)).toList();

    // ── Header stats ─────────────────────────────────────────────────────────
    final onlineCount =
        allEquipments.where((e) => liveCtl.live[e.id]?.online == true).length;
    final totalCount = allEquipments.length +
        allTvDevices.length +
        allCobLedRgbDevices.length +
        allCobLedCctDevices.length;
    final roomsWithDevices = {
      ...allEquipments.where((e) => e.roomId != null).map((e) => e.roomId!),
      ...allTvDevices.where((t) => t.roomId != null).map((t) => t.roomId!),
      ...allCobLedRgbDevices.where((d) => d.roomId != null).map((d) => d.roomId!),
      ...allCobLedCctDevices.where((d) => d.roomId != null).map((d) => d.roomId!),
    }.length;

    // ── Apply room filter ────────────────────────────────────────────────────
    var equipments = _selectedRoomId == null
        ? allEquipments
        : allEquipments.where((e) => e.roomId == _selectedRoomId).toList();
    var tvDevices = _selectedRoomId == null
        ? allTvDevices
        : allTvDevices.where((t) => t.roomId == _selectedRoomId).toList();
    var cobLedRgbDevices = _selectedRoomId == null
        ? allCobLedRgbDevices
        : allCobLedRgbDevices
            .where((d) => d.roomId == _selectedRoomId)
            .toList();
    var cobLedCctDevices = _selectedRoomId == null
        ? allCobLedCctDevices
        : allCobLedCctDevices
            .where((c) => c.roomId == _selectedRoomId)
            .toList();

    // ── Apply kind filter ────────────────────────────────────────────────────
    switch (_selectedKind) {
      case _DeviceKind.equipment:
        tvDevices = [];
        cobLedRgbDevices = [];
        cobLedCctDevices = [];
      case _DeviceKind.tv:
        equipments = [];
        cobLedRgbDevices = [];
        cobLedCctDevices = [];
      case _DeviceKind.cobLedRgb:
        equipments = [];
        tvDevices = [];
        cobLedCctDevices = [];
      case _DeviceKind.cobLedCct:
        equipments = [];
        tvDevices = [];
        cobLedRgbDevices = [];
      case _DeviceKind.thermometer:
        equipments =
            equipments.where((e) => e.type == EquipmentType.shellyHT).toList();
        tvDevices = [];
        cobLedRgbDevices = [];
        cobLedCctDevices = [];
      case _DeviceKind.hygrometer:
        equipments = equipments
            .where((e) => e.type == EquipmentType.hygrometer)
            .toList();
        tvDevices = [];
        cobLedRgbDevices = [];
        cobLedCctDevices = [];
      case _DeviceKind.all:
        break;
    }

    // ── Apply search filter ──────────────────────────────────────────────────
    if (_searchQuery.isNotEmpty) {
      equipments = equipments
          .where((e) => e.name.toLowerCase().contains(_searchQuery))
          .toList();
      tvDevices = tvDevices
          .where((t) => t.name.toLowerCase().contains(_searchQuery))
          .toList();
      cobLedRgbDevices = cobLedRgbDevices
          .where((d) => d.name.toLowerCase().contains(_searchQuery))
          .toList();
      cobLedCctDevices = cobLedCctDevices
          .where((d) => d.name.toLowerCase().contains(_searchQuery))
          .toList();
    }

    // ── Room name helper ─────────────────────────────────────────────────────
    String roomName(String? id) {
      if (id == null) return '';
      return rooms.where((r) => r.id == id).firstOrNull?.name ?? '';
    }

    // ── Pre-build flat tile list ─────────────────────────────────────────────
    // Each entry is a Row[ Expanded(DeviceListTile) | heart IconButton ] so
    // the heart sits outside the card's tap / ink area.
    Widget heartRow({
      required Widget tile,
      required bool isFavorite,
      required VoidCallback onToggle,
    }) =>
        Row(
          children: [
            Expanded(child: tile),
            IconButton(
              onPressed: onToggle,
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 22,
                color: isFavorite
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        );

    final tiles = <Widget>[
      for (final e in equipments)
        heartRow(
          isFavorite: e.isFavorite,
          onToggle: () => ctrl.toggleEquipmentFavorite(e),
          tile: DeviceListTile(
            icon: _iconForType(e.type),
            iconColor: _accentForType(e.type),
            title: e.name,
            subtitle: [
              if (roomName(e.roomId).isNotEmpty) roomName(e.roomId),
              _typeLabel(e.type, context),
            ].join(' · '),
            liveValue: _equipmentValue(e, liveCtl.live[e.id]).isNotEmpty
                ? _equipmentValue(e, liveCtl.live[e.id])
                : null,
            dotColor: _dotColor(liveCtl.live[e.id]?.online),
            onTap: () => _onEquipmentTap(e),
          ),
        ),
      for (final tv in tvDevices)
        heartRow(
          isFavorite: tv.isFavorite,
          onToggle: () => ctrl.toggleTvFavorite(tv),
          tile: DeviceListTile(
            icon: Icons.tv_rounded,
            iconColor: Colors.blueGrey,
            title: tv.name,
            subtitle: [
              if (roomName(tv.roomId).isNotEmpty) roomName(tv.roomId),
              context.l10n.deviceTypeTv,
            ].join(' · '),
            dotColor: _dotColor(liveCtl.live[tv.id]?.online),
            onTap: () => _onTvTap(tv),
          ),
        ),
      for (final d in cobLedRgbDevices)
        heartRow(
          isFavorite: d.isFavorite,
          onToggle: () => ctrl.toggleCobLedRgbFavorite(d),
          tile: DeviceListTile(
            icon: Icons.lightbulb_outline_rounded,
            iconColor: AppColors.cobLedRgbAccent,
            title: d.name,
            subtitle: [
              if (roomName(d.roomId).isNotEmpty) roomName(d.roomId),
              context.l10n.cobLedRgbTypeLabel,
            ].join(' · '),
            dotColor: _dotColor(liveCtl.live[d.id]?.online),
            onTap: () => _onCobLedRgbTap(d.id),
          ),
        ),
      for (final cct in cobLedCctDevices)
        heartRow(
          isFavorite: cct.isFavorite,
          onToggle: () => ctrl.toggleCobLedCctFavorite(cct),
          tile: DeviceListTile(
            icon: Icons.wb_incandescent_outlined,
            iconColor: AppColors.cobLedCctAccent,
            title: cct.name,
            subtitle: [
              if (roomName(cct.roomId).isNotEmpty) roomName(cct.roomId),
              context.l10n.cobLedCctTypeLabel,
            ].join(' · '),
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.45),
        leading: const BackButton(),
        title: Text(
          context.l10n.favoritesPageTitle,
          style: const TextStyle(
            fontFamily: 'ShareTech',
            fontWeight: FontWeight.w600,
            fontSize: AppFontSizes.heading,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => ctrl.loadAll(widget.groupId),
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.textSecondary,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stats line ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x3l,
                AppSpacing.x3l,
                AppSpacing.x3l,
                0,
              ),
              child: Text(
                '$onlineCount / $totalCount online'
                '${roomsWithDevices > 0 ? ' · $roomsWithDevices rooms' : ''}',
                style: const TextStyle(
                  fontFamily: 'ShareTech',
                  fontSize: AppFontSizes.sm,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            AppSpacing.gapX2l,

            // ── Search + filter ───────────────────────────────────────────────
            EquipmentsSearchBar(
              controller: _searchCtrl,
              isFiltered: _selectedKind != _DeviceKind.all,
              onFilterTap: _showTypeMenu,
              hintText: context.l10n.favoritesSearchHint,
            ),

            AppSpacing.gapX2l,

            // ── Room chips ────────────────────────────────────────────────────
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.x3l),
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.md),
                itemCount: rooms.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return AppChip(
                      label: context.l10n.equipmentsRoomAll(totalCount),
                      selected: _selectedRoomId == null,
                      variant: AppChipVariant.filter,
                      onTap: () => setState(() => _selectedRoomId = null),
                    );
                  }
                  final room = rooms[i - 1];
                  final count = _countForRoom(
                    room.id,
                    allEquipments,
                    allTvDevices,
                    allCobLedRgbDevices,
                    allCobLedCctDevices,
                  );
                  return AppChip(
                    label: context.l10n.equipmentsRoomItem(room.name, count),
                    selected: _selectedRoomId == room.id,
                    variant: AppChipVariant.filter,
                    onTap: () => setState(() => _selectedRoomId = room.id),
                  );
                },
              ),
            ),

            AppSpacing.gapX5l,

            // ── Device list ───────────────────────────────────────────────────
            Expanded(
              child: tiles.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'No results for "$_searchQuery"'
                            : context.l10n.noFavorites,
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
    );
  }
}
