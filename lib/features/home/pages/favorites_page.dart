import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/equipment.dart';
import '../../../domain/entities/tv_device.dart';
import '../../../domain/entities/wled_device.dart';
import '../../../features/equipments/pages/equipment_details_page.dart';
import '../../../features/live/controllers/live_polling_controller.dart';
import '../../../domain/entities/room.dart';
import '../controllers/home_controller.dart';
import '../widgets/favorite_pill_tile.dart';

/// Dedicated page for the favorites list.
///
/// The layout is intentionally closer to the provided mockup:
/// - custom top bar
/// - centered title
/// - pill-like rows
/// - trailing remove button
/// - floating add button at the bottom
class FavoritesPage extends StatefulWidget {
  final List<Equipment> equipments;
  final List<TvDevice> tvDevices;
  final List<WledDevice> wledDevices;
  final List<Room> rooms;

  const FavoritesPage({
    super.key,
    required this.equipments,
    required this.tvDevices,
    required this.wledDevices,
    required this.rooms,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late List<Equipment> _favoriteEquipments;
  late List<TvDevice> _favoriteTvs;
  late List<WledDevice> _favoriteWleds;

  @override
  void initState() {
    super.initState();
    _favoriteEquipments = widget.equipments.where((e) => e.isFavorite).toList();
    _favoriteTvs = widget.tvDevices.where((t) => t.isFavorite).toList();
    _favoriteWleds = widget.wledDevices.where((w) => w.isFavorite).toList();
  }

  Future<void> _openDetails(Equipment equipment) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EquipmentDetailsPage(equipmentId: equipment.id),
      ),
    );

    if (changed == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _removeFavorite(Equipment equipment) async {
    await context.read<HomeController>().removeEquipmentFromFavorites(equipment);

    if (!mounted) return;

    setState(() {
      _favoriteEquipments.removeWhere((item) => item.id == equipment.id);
    });
  }

  Future<void> _removeTv(TvDevice tv) async {
    await context.read<HomeController>().removeTvFromFavorites(tv);
    if (!mounted) return;
    setState(() => _favoriteTvs.removeWhere((t) => t.id == tv.id));
  }

  Future<void> _removeWled(WledDevice wled) async {
    await context.read<HomeController>().removeWledFromFavorites(wled);
    if (!mounted) return;
    setState(() => _favoriteWleds.removeWhere((w) => w.id == wled.id));
  }

  void _onAddPressed() {
    // No-op: the "add favorite" flow is not yet implemented.
  }

  IconData _leadingIconFor(Equipment equipment) {
    final normalizedName = equipment.name.toLowerCase();

    // Temporary heuristic while the model has no dedicated category/icon field.
    if (normalizedName.contains('hygro')) {
      return Icons.water_drop_outlined;
    }

    if (normalizedName.contains('thermo')) {
      return Icons.wb_sunny_outlined;
    }

    if (equipment.showPower) {
      return Icons.electrical_services_rounded;
    }

    return Icons.devices_other_outlined;
  }

  List<({String title, IconData icon, VoidCallback onTap, VoidCallback onRemove})> _buildRows(LivePollingController liveController) {
    final rows = <({String title, IconData icon, VoidCallback onTap, VoidCallback onRemove})>[];
    for (final e in _favoriteEquipments) {
      rows.add((
        title: e.name,
        icon: _leadingIconFor(e),
        onTap: () => _openDetails(e),
        onRemove: () => _removeFavorite(e),
      ));
    }
    for (final tv in _favoriteTvs) {
      rows.add((
        title: tv.name,
        icon: Icons.tv_rounded,
        onTap: () {},
        onRemove: () => _removeTv(tv),
      ));
    }
    for (final wled in _favoriteWleds) {
      rows.add((
        title: wled.name,
        icon: Icons.lightbulb_outline_rounded,
        onTap: () {},
        onRemove: () => _removeWled(wled),
      ));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final liveController = context.watch<LivePollingController>();
    final rows = _buildRows(liveController);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _FavoritesPageHeader(
              onBackPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: rows.isEmpty
                  ? Center(
                      child: Text(
                        context.l10n.noFavorites,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                      itemCount: rows.length + 1,
                      separatorBuilder: (_, _) => AppSpacing.gapX2l,
                      itemBuilder: (context, index) {
                        if (index == rows.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Center(
                              child: _FavoritesAddButton(
                                tooltip: context.l10n.favoritesAddTooltip,
                                onPressed: _onAddPressed,
                              ),
                            ),
                          );
                        }

                        final row = rows[index];
                        return FavoritePillTile(
                          icon: row.icon,
                          title: row.title,
                          statusColor: AppColors.textSecondary,
                          removeTooltip: context.l10n.favoriteRemoveTooltip,
                          onTap: row.onTap,
                          onRemove: row.onRemove,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom header to stay visually close to the provided mockup.
class _FavoritesPageHeader extends StatelessWidget {
  final VoidCallback onBackPressed;

  const _FavoritesPageHeader({
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: onBackPressed,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              const Spacer(),
              Text(
                context.l10n.favoritesActiveFilterLabel,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.gapHSm,
              IconButton(
                tooltip: context.l10n.favoritesFilterTooltip,
                onPressed: () {
                  // No-op: the filter sheet is not yet implemented.
                },
                icon: const Icon(Icons.tune_rounded, size: 18),
              ),
            ],
          ),
          AppSpacing.gapXs,
          Center(
            child: Text(
              context.l10n.favoritesPageTitle,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppSpacing.gapXl,
        ],
      ),
    );
  }
}

/// Bottom-centered add button matching the mockup spirit.
class _FavoritesAddButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onPressed;

  const _FavoritesAddButton({
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.pillBR,
          onTap: onPressed,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.bg,
              shape: BoxShape.circle,
              border: Border.all(
                width: 0.7,
                color: AppColors.border.withValues(alpha: 0.90),
              ),
              boxShadow: AppShadows.subtle,
            ),
            child: const Icon(
              Icons.add,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}