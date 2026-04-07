import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/utils/time_label.dart';
import '../../../core/design_system/layout/app_section_header.dart';

import '../../../domain/entities/equipment.dart';
import '../../../domain/entities/tv_device.dart';

import '../../live/controllers/live_polling_controller.dart';
import '../../equipments/pages/equipment_details_page.dart';
import '../../tv/pages/tv_details_page.dart';
import '../../equipments/widgets/edit_equipment_sheet.dart';

import '../controllers/home_controller.dart';
import '../widgets/areas_section.dart';
import '../widgets/favorite_card.dart';
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

  Future<void> _openDetails(Equipment equipment) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EquipmentDetailsPage(equipmentId: equipment.id),
      ),
    );
    if (changed == true) widget.refreshNotifier.value++;
  }

  Future<void> _openTvDetails(TvDevice tv) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TvDetailsPage(deviceId: tv.id),
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
          equipments: controller.allEquipments,
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
        ),
      ),
    );
    if (changed == true) widget.refreshNotifier.value++;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    final liveController = context.watch<LivePollingController>();
    final groupId = _selectedGroupId;

    final favoriteEquipments = controller.favoriteEquipments(groupId);
    final favoriteTvs = controller.favoriteTvDevices(groupId);
    final hasFavorites =
        favoriteEquipments.isNotEmpty || favoriteTvs.isNotEmpty;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => controller.loadAll(groupId),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
          children: [
            const SizedBox(height: 4),
            SectionHeader(
              title: context.l10n.favorites,
              onTap: _openFavoritesPage,
            ),
            const SizedBox(height: 10),
            if (controller.isLoading)
              const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (!hasFavorites)
              SizedBox(
                height: 150,
                child: Center(
                  child: Text(context.l10n.noFavorites),
                ),
              )
            else
              SizedBox(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...favoriteEquipments.map((equipment) {
                      final supported =
                          controller.isFavoriteSupported(equipment);
                      final state = supported
                          ? liveController.live[equipment.id]
                          : null;

                      final value = supported
                          ? (equipment.showPower
                              ? '${(state?.powerW ?? 0).toStringAsFixed(0)} ${context.l10n.unitWattShort}'
                              : (state?.output == true
                                  ? context.l10n.valueOn
                                  : context.l10n.valueOff))
                          : context.l10n.valueUnknown;

                      final roomLabel = controller.roomName(equipment.roomId);

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: FavoriteCard(
                          value: value,
                          label: equipment.name,
                          room: roomLabel.isNotEmpty
                              ? roomLabel
                              : context.l10n.valueUnknown,
                          icon: supported
                              ? Icons.power_rounded
                              : Icons.devices_other,
                          isOn: state?.output == true,
                          showPowerButton: supported,
                          powerLoading: state?.toggling ?? false,
                          powerEnabled: true,
                          onPowerPressed: supported
                              ? () => controller.togglePlug(equipment)
                              : null,
                          trend: state?.trendPower ?? 0,
                          updatedLabel:
                              ageLabel(context, state?.lastUpdatedAt),
                          onOpenDetails: () => _openDetails(equipment),
                          onToggleFavorite: () async {
                            await controller
                                .removeEquipmentFromFavorites(equipment);
                            widget.refreshNotifier.value++;
                          },
                          onEdit: () => _editEquipment(equipment),
                        ),
                      );
                    }),
                    ...favoriteTvs.map((tv) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: FavoriteCard(
                          value: tv.source,
                          label: tv.name,
                          room: controller.roomName(tv.roomId).isNotEmpty
                              ? controller.roomName(tv.roomId)
                              : context.l10n.valueUnknown,
                          icon: Icons.tv_rounded,
                          isOn: true,
                          showPowerButton: false,
                          powerEnabled: false,
                          trend: 0,
                          updatedLabel: '',
                          onOpenDetails: () => _openTvDetails(tv),
                          onToggleFavorite: () async {
                            await controller.removeTvFromFavorites(tv);
                            widget.refreshNotifier.value++;
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            SectionHeader(
              title: context.l10n.roomsSectionTitle,
              onTap: _openRoomsPage,
            ),
            const SizedBox(height: 10),
            AreasSection(
              rooms: controller.visibleRooms(groupId),
              onOpenEquipment: (equipmentId) {
                final equipment = controller.equipmentById(equipmentId);
                if (equipment != null) _openDetails(equipment);
              },
            ),
          ],
        ),
      ),
    );
  }
}
