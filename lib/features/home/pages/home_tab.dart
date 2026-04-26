import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_font_sizes.dart';
import '../../../core/design_system/layout/app_section_header.dart';

import '../../../domain/entities/device_bundle.dart';
import '../../../domain/entities/cob_led_cct_device.dart';
import '../../../domain/entities/equipment.dart';
import '../../../domain/entities/tv_device.dart';
import '../../../domain/entities/cob_led_rgb_device.dart';

import '../../live/controllers/live_polling_controller.dart';
import '../../devices/thermometer/view/thermometer_detail_screen.dart';
import '../../equipments/pages/equipment_details_page.dart';
import '../../devices/smart_plug/view/smart_plug_detail_screen.dart';
import '../../devices/tv/view/tv_detail_screen.dart';
import '../../devices/cob_led_rgb/pages/cob_led_rgb_details_page.dart';
import '../../equipments/widgets/edit_equipment_sheet.dart';
import '../../devices/tv/domain/tv_remote_command.dart';

import '../controllers/home_controller.dart';
import '../widgets/areas_section.dart';
import '../widgets/device_cards/cob_led_cct_card.dart';
import '../widgets/device_cards/plug_card.dart';
import '../widgets/device_cards/thermometer_card.dart';
import '../widgets/device_cards/tv_card.dart';
import '../widgets/device_cards/cob_led_rgb_card.dart';
import '../../devices/cob_led_cct/view/cob_led_cct_detail_screen.dart';
import '../widgets/today/today_section.dart';
import 'rooms_page.dart';
import 'favorites_page.dart';

class HomeTab extends StatefulWidget {
  final ValueNotifier<int> refreshNotifier;
  final ValueNotifier<String?> selectedGroupIdNotifier;

  const HomeTab({
    super.key,
    required this.refreshNotifier,
    required this.selectedGroupIdNotifier,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String? get _selectedGroupId => widget.selectedGroupIdNotifier.value;

  @override
  void initState() {
    super.initState();
    _reload();
    widget.refreshNotifier.addListener(_reload);
    widget.selectedGroupIdNotifier.addListener(_onGroupChanged);
  }

  @override
  void dispose() {
    widget.refreshNotifier.removeListener(_reload);
    widget.selectedGroupIdNotifier.removeListener(_onGroupChanged);
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    context.read<HomeController>().loadAll(_selectedGroupId);
  }

  void _onGroupChanged() {
    if (!mounted) return;
    final controller = context.read<HomeController>();
    controller.syncLivePolling(_selectedGroupId);
    setState(() {});
  }

  // ---------------------------------------------------------------------------
  // Navigation helpers
  // ---------------------------------------------------------------------------

  Future<void> _openEquipmentDetails(Equipment equipment) async {
    final Widget page;
    if (equipment.type.isPlug) {
      page = SmartPlugDetailScreen(equipment: equipment);
    } else if (equipment.type == EquipmentType.shellyHT) {
      page = ThermometerDetailScreen(equipment: equipment);
    } else {
      page = EquipmentDetailsPage(equipmentId: equipment.id);
    }
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => page),
    );
    if (changed == true) widget.refreshNotifier.value++;
  }

  Future<void> _openTvDetails(TvDevice tv) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TvDetailScreen(device: tv)),
    );
    _reload();
  }

  Future<void> _openCobLedRgbDetails(CobLedRgbDevice device) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CobLedRgbDetailsPage(deviceId: device.id)),
    );
    _reload();
  }

  Future<void> _openCobLedCctDetails(CobLedCctDevice device) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CobLedCctDetailScreen(device: device),
      ),
    );
    _reload();
  }

  Future<void> _editEquipment(Equipment equipment) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => EditEquipmentSheet(initial: equipment),
    );
    if (changed == true) widget.refreshNotifier.value++;
  }

  Future<void> _openFavoritesPage() async {
    final controller = context.read<HomeController>();
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FavoritesPage(
          devices: controller.allDevices,
          rooms: controller.allRooms,
        ),
      ),
    );
    if (changed == true) widget.refreshNotifier.value++;
  }

  Future<void> _openRoomsPage() async {
    final controller = context.read<HomeController>();
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RoomsPage(
          activeGroup: controller.activeRoomGroup(_selectedGroupId),
          rooms: controller.visibleRooms(_selectedGroupId),
          devices: controller.allDevices,
        ),
      ),
    );
    if (changed == true) widget.refreshNotifier.value++;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    final liveController = context.watch<LivePollingController>();
    final groupId = _selectedGroupId;

    final favorites = DeviceBundle(
      equipments: controller.favoriteEquipments(groupId),
      tvDevices: controller.favoriteTvDevices(groupId),
      cobLedRgbDevices: controller.favoriteCobLedRgbDevices(groupId),
      cobLedCctDevices: controller.favoriteCobLedCctDevices(groupId),
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => controller.loadAll(groupId),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
          children: [
            // ----------------------------------------------------------------
            // TODAY SECTION
            // ----------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Text(
                context.l10n.homeSectionToday,
                style: const TextStyle(
                  fontFamily: 'ShareTech',
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: AppFontSizes.sectionTitle,
                ),
              ),
            ),
            AppSpacing.gapX3l,
            if (controller.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 60,
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else
              TodaySection(groupId: groupId),

            AppSpacing.gapX5l,

            // ----------------------------------------------------------------
            // FAVORITES SECTION
            // ----------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: SectionHeader(
                title: context.l10n.favorites,
                onTap: _openFavoritesPage,
              ),
            ),
            AppSpacing.gapX3l,

            if (controller.isLoading)
              const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (favorites.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 80,
                  child: Center(
                    child: Text(
                      context.l10n.noFavorites,
                      style: const TextStyle(
                        fontFamily: 'ShareTech',
                        color: AppColors.textSecondary,
                        fontSize: AppFontSizes.body,
                      ),
                    ),
                  ),
                ),
              )
            else
              _FavoritesSlider(
                favorites: favorites,
                controller: controller,
                liveController: liveController,
                onOpenEquipment: _openEquipmentDetails,
                onOpenTv: _openTvDetails,
                onOpenCobLedRgb: _openCobLedRgbDetails,
                onOpenCobLedCct: _openCobLedCctDetails,
                onEditEquipment: _editEquipment,
                onRemoveEquipment: (e) async {
                  await controller.removeEquipmentFromFavorites(e);
                  widget.refreshNotifier.value++;
                },
                onRemoveTv: (tv) async {
                  await controller.removeTvFromFavorites(tv);
                  widget.refreshNotifier.value++;
                },
                onRemoveCobLedRgb: (w) async {
                  await controller.removeCobLedRgbFromFavorites(w);
                  widget.refreshNotifier.value++;
                },
                onRemoveCobLedCct: (c) async {
                  await controller.removeCobLedCctFromFavorites(c);
                  widget.refreshNotifier.value++;
                },
              ),

            // ----------------------------------------------------------------
            // AREAS SECTION
            // ----------------------------------------------------------------
            AppSpacing.gapX5l,
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: SectionHeader(
                title: context.l10n.roomsSectionTitle,
                onTap: _openRoomsPage,
              ),
            ),

            if (controller.isLoading)
              const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AreasSection(
                  rooms: controller.visibleRooms(groupId),
                  groupId: groupId,
                  onOpenEquipment: (id) {
                    final eq = controller.equipmentById(id);
                    if (eq != null) _openEquipmentDetails(eq);
                  },
                  onOpenTv: (id) {
                    final tv = controller.allTvDevices
                        .where((t) => t.id == id)
                        .firstOrNull;
                    if (tv != null) _openTvDetails(tv);
                  },
                  onOpenCobLedRgb: (id) {
                    final w = controller.allCobLedRgbDevices
                        .where((w) => w.id == id)
                        .firstOrNull;
                    if (w != null) _openCobLedRgbDetails(w);
                  },
                  onOpenCobLedCct: (id) {
                    final c = controller.allCobLedCctDevices
                        .where((c) => c.id == id)
                        .firstOrNull;
                    if (c != null) _openCobLedCctDetails(c);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Favorites horizontal slider (single row)
// ---------------------------------------------------------------------------

class _FavoritesSlider extends StatelessWidget {
  const _FavoritesSlider({
    required this.favorites,
    required this.controller,
    required this.liveController,
    required this.onOpenEquipment,
    required this.onOpenTv,
    required this.onOpenCobLedRgb,
    required this.onOpenCobLedCct,
    required this.onEditEquipment,
    required this.onRemoveEquipment,
    required this.onRemoveTv,
    required this.onRemoveCobLedRgb,
    required this.onRemoveCobLedCct,
  });

  final DeviceBundle favorites;
  final HomeController controller;
  final LivePollingController liveController;
  final void Function(Equipment) onOpenEquipment;
  final void Function(TvDevice) onOpenTv;
  final void Function(CobLedRgbDevice) onOpenCobLedRgb;
  final void Function(CobLedCctDevice) onOpenCobLedCct;
  final void Function(Equipment) onEditEquipment;
  final void Function(Equipment) onRemoveEquipment;
  final void Function(TvDevice) onRemoveTv;
  final void Function(CobLedRgbDevice) onRemoveCobLedRgb;
  final void Function(CobLedCctDevice) onRemoveCobLedCct;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[];

    for (final eq in favorites.equipments) {
      final state = eq.type.isPlug ? liveController.live[eq.id] : null;
      if (eq.type.isThermometer) {
        cards.add(
          ThermometerCard(
            equipment: eq,
            liveState: liveController.live[eq.id],
            onTap: () => onOpenEquipment(eq),
          ),
        );
      } else {
        cards.add(
          PlugCard(
            equipment: eq,
            liveState: state,
            onTap: () => onOpenEquipment(eq),
            onToggle: eq.showToggle ? () => controller.togglePlug(eq) : null,
          ),
        );
      }
    }

    for (final tv in favorites.tvDevices) {
      final isOn = controller.tvIsOn(tv.id);
      cards.add(TvCard(
        tv: tv,
        isOn: isOn,
        onTap: () => onOpenTv(tv),
        onHome: () => controller.sendTvCommand(tv, TvRemoteCommand.home),
        onVolumeUp: () => controller.sendTvCommand(tv, TvRemoteCommand.volumeUp),
        onVolumeDown: () => controller.sendTvCommand(tv, TvRemoteCommand.volumeDown),
      ));
    }

    for (final device in favorites.cobLedRgbDevices) {
      final state = controller.cobLedRgbStateFor(device.id);
      final isOn = state?.isOn ?? false;
      final brightness = ((state?.brightness ?? 128) / 255.0).clamp(0.0, 1.0);
      final c = state?.primaryColor;
      final color = c != null ? Color.fromARGB(255, c.red, c.green, c.blue) : Colors.amber;
      cards.add(CobLedRgbCard(
        device: device,
        isOn: isOn,
        brightness: brightness,
        sceneName: '',
        color: color,
        onTap: () => onOpenCobLedRgb(device),
        onToggle: () => controller.toggleCobLedRgb(device),
        onBrightnessDrag: (v) => controller.setCobLedRgbBrightness(device, v),
      ));
    }

    for (final cct in favorites.cobLedCctDevices) {
      final state = controller.cctStateFor(cct.id);
      final isOn = state?.isOn ?? false;
      final brightness = state?.brightness ?? 200;
      final colorTempK = state?.colorTempK ?? 3000;
      cards.add(CobLedCctCard(
        device: cct,
        isOn: isOn,
        brightness: brightness,
        colorTempK: colorTempK,
        onTap: () => onOpenCobLedCct(cct),
        onToggle: () => controller.toggleCobLedCct(cct),
        onBrightnessDrag: (v) => controller.setCobLedCctBrightness(cct, v),
      ));
    }

    // Match the exact card size produced by the 2-column grid in AreasSection:
    // width  = (screenWidth − 2×pagePadding − crossAxisSpacing) / 2
    // height = width × (150 / 155)
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth - 16 * 2 - 12) / 2;
    final cardHeight = cardWidth * (150 / 155);

    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cards.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => SizedBox(width: cardWidth, child: cards[i]),
      ),
    );
  }
}
