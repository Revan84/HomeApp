import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/repositories/equipment_repository.dart';
import '../../../domain/models/equipment.dart';
import '../../../features/equipments/pages/equipment_details_page.dart';
import '../../../features/live/controllers/live_polling_controller.dart';
import '../../../domain/models/room.dart';

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
  final List<Room> rooms;

  const FavoritesPage({
    super.key,
    required this.equipments,
    required this.rooms,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late List<Equipment> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = widget.equipments.where((equipment) => equipment.isFavorite).toList();
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
    await context.read<EquipmentRepository>().update(
          equipment.copyWith(isFavorite: false),
        );

    if (!mounted) return;

    setState(() {
      _favorites.removeWhere((item) => item.id == equipment.id);
    });
  }

  void _onAddPressed() {
    // TODO: Hook this button to the future "add favorite" flow.
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

  Color _statusColorFor(bool isOnline) {
    return isOnline ? AppColors.success : Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final liveController = context.watch<LivePollingController>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _FavoritesPageHeader(
              onBackPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: _favorites.isEmpty
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
                      itemCount: _favorites.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        if (index == _favorites.length) {
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

                        final equipment = _favorites[index];
                        final liveState = liveController.live[equipment.id];
                        final isOnline = liveState?.online ?? false;

                        return _FavoritePillTile(
                          icon: _leadingIconFor(equipment),
                          title: equipment.name,
                          statusColor: _statusColorFor(isOnline),
                          removeTooltip: context.l10n.favoriteRemoveTooltip,
                          onTap: () => _openDetails(equipment),
                          onRemove: () => _removeFavorite(equipment),
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
              const SizedBox(width: 6),
              IconButton(
                tooltip: context.l10n.favoritesFilterTooltip,
                onPressed: () {
                  // TODO: Hook this icon to a future filter sheet.
                },
                icon: const Icon(Icons.tune_rounded, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              context.l10n.favoritesPageTitle,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Pill-shaped list item for a favorite device.
class _FavoritePillTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color statusColor;
  final String removeTooltip;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoritePillTile({
    required this.icon,
    required this.title,
    required this.statusColor,
    required this.removeTooltip,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    width: 0.7,
                    color: AppColors.stroke.withValues(alpha: 0.90),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 3,
                      spreadRadius: 1,
                      offset: const Offset(1, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: AppColors.textPrimary,
                      size: 21,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: removeTooltip,
          onPressed: onRemove,
          icon: Icon(
            Icons.remove,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ],
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
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.bg,
              shape: BoxShape.circle,
              border: Border.all(
                width: 0.7,
                color: AppColors.stroke.withValues(alpha: 0.90),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 3,
                  spreadRadius: 1,
                  offset: const Offset(1, 5),
                ),
              ],
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