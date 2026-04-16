import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_font_sizes.dart';
import '../../../core/design_system/layout/app_section_header.dart';

import '../../../domain/entities/equipment.dart';
import '../../../domain/entities/tv_device.dart';
import '../../../domain/entities/wled_device.dart';

import '../../live/controllers/live_polling_controller.dart';
import '../../equipments/pages/equipment_details_page.dart';
import '../../tv/pages/tv_details_page.dart';
import '../../wled/pages/wled_details_page.dart';
import '../../equipments/widgets/edit_equipment_sheet.dart';
import '../../tv/domain/tv_remote_command.dart';

import '../controllers/home_controller.dart';
import '../widgets/areas_section.dart';
import '../widgets/device_cards/plug_card.dart';
import '../widgets/device_cards/thermometer_card.dart';
import '../widgets/device_cards/tv_card.dart';
import '../widgets/device_cards/wled_card.dart';
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
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EquipmentDetailsPage(equipmentId: equipment.id),
      ),
    );
    if (changed == true) widget.refreshNotifier.value++;
  }

  Future<void> _openTvDetails(TvDevice tv) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TvDetailsPage(deviceId: tv.id)),
    );
    _reload();
  }

  Future<void> _openWledDetails(WledDevice device) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => WledDetailsPage(deviceId: device.id)),
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
          equipments: controller.allEquipments,
          tvDevices: controller.allTvDevices,
          wledDevices: controller.allWledDevices,
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
          equipments: controller.allEquipments,
          tvDevices: controller.allTvDevices,
          wledDevices: controller.allWledDevices,
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

    final favoriteEquipments = controller.favoriteEquipments(groupId);
    final favoriteTvs = controller.favoriteTvDevices(groupId);
    final favoriteWleds = controller.favoriteWledDevices(groupId);
    final hasFavorites =
        favoriteEquipments.isNotEmpty ||
        favoriteTvs.isNotEmpty ||
        favoriteWleds.isNotEmpty;

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
              child: const Text(
                'Today',
                style: TextStyle(
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
            else if (!hasFavorites)
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
                favoriteEquipments: favoriteEquipments,
                favoriteTvs: favoriteTvs,
                favoriteWleds: favoriteWleds,
                controller: controller,
                liveController: liveController,
                onOpenEquipment: _openEquipmentDetails,
                onOpenTv: _openTvDetails,
                onOpenWled: _openWledDetails,
                onEditEquipment: _editEquipment,
                onRemoveEquipment: (e) async {
                  await controller.removeEquipmentFromFavorites(e);
                  widget.refreshNotifier.value++;
                },
                onRemoveTv: (tv) async {
                  await controller.removeTvFromFavorites(tv);
                  widget.refreshNotifier.value++;
                },
                onRemoveWled: (w) async {
                  await controller.removeWledFromFavorites(w);
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
                  onOpenWled: (id) {
                    final w = controller.allWledDevices
                        .where((w) => w.id == id)
                        .firstOrNull;
                    if (w != null) _openWledDetails(w);
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
    required this.favoriteEquipments,
    required this.favoriteTvs,
    required this.favoriteWleds,
    required this.controller,
    required this.liveController,
    required this.onOpenEquipment,
    required this.onOpenTv,
    required this.onOpenWled,
    required this.onEditEquipment,
    required this.onRemoveEquipment,
    required this.onRemoveTv,
    required this.onRemoveWled,
  });

  final List<Equipment> favoriteEquipments;
  final List<TvDevice> favoriteTvs;
  final List<WledDevice> favoriteWleds;
  final HomeController controller;
  final LivePollingController liveController;
  final void Function(Equipment) onOpenEquipment;
  final void Function(TvDevice) onOpenTv;
  final void Function(WledDevice) onOpenWled;
  final void Function(Equipment) onEditEquipment;
  final void Function(Equipment) onRemoveEquipment;
  final void Function(TvDevice) onRemoveTv;
  final void Function(WledDevice) onRemoveWled;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[];

    for (final eq in favoriteEquipments) {
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

    for (final tv in favoriteTvs) {
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

    for (final wled in favoriteWleds) {
      final state = controller.wledStateFor(wled.id);
      final isOn = state?.isOn ?? false;
      final brightness = ((state?.brightness ?? 128) / 255.0).clamp(0.0, 1.0);
      final c = state?.primaryColor;
      final color = c != null ? Color.fromARGB(255, c.red, c.green, c.blue) : Colors.amber;
      cards.add(WledCard(
        device: wled,
        isOn: isOn,
        brightness: brightness,
        sceneName: '',
        color: color,
        onTap: () => onOpenWled(wled),
        onToggle: () => controller.toggleWled(wled),
        onBrightnessDrag: (v) => controller.setWledBrightness(wled, v),
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
