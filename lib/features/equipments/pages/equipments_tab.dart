import 'package:flutter/material.dart';
import 'package:front_end/core/i18n/loc.dart';
import 'package:front_end/core/theme/app_colors.dart';
import 'package:front_end/core/theme/app_radius.dart';
import 'package:provider/provider.dart';

import '../../../core/design_system/chips/app_chip.dart';
import '../../../domain/entities/equipment.dart';
import '../../../core/theme/app_spacing.dart';

import '../../live/controllers/live_polling_controller.dart';
import '../../tv/pages/tv_details_page.dart';
import '../../wled/pages/wled_details_page.dart';
import '../controllers/equipments_controller.dart';
import 'equipment_details_page.dart';

enum _DeviceKind { all, equipment, tv, wled }

// Sentinel used to distinguish "All" selection from menu dismissal.
const _kAll = '__all__';

class EquipmentsTab extends StatefulWidget {
  final ValueNotifier<int> refreshNotifier;
  final ValueNotifier<String?> selectedGroupIdNotifier;

  const EquipmentsTab({
    super.key,
    required this.refreshNotifier,
    required this.selectedGroupIdNotifier,
  });

  @override
  State<EquipmentsTab> createState() => _EquipmentsTabState();
}

class _EquipmentsTabState extends State<EquipmentsTab> {
  String? _selectedRoomId;
  _DeviceKind _selectedKind = _DeviceKind.all;

  final GlobalKey _roomKey = GlobalKey();
  final GlobalKey _typeKey = GlobalKey();

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
    context.read<EquipmentsController>().loadAll();
  }

  void _onGroupChanged() {
    if (mounted) setState(() => _selectedRoomId = null);
  }

  Future<void> _onEquipmentTap(String equipmentId) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EquipmentDetailsPage(equipmentId: equipmentId),
      ),
    );
    if (changed == true) _reload();
  }

  Future<void> _onTvTap(String tvId) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TvDetailsPage(deviceId: tvId)),
    );
    if (changed == true) _reload();
  }

  Future<void> _onWledTap(String wledId) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => WledDetailsPage(deviceId: wledId)),
    );
    if (changed == true) _reload();
  }

  IconData _iconForType(EquipmentType type) {
    switch (type) {
      case EquipmentType.shellyPlusPlugS:
      default:
        return Icons.devices_other;
    }
  }

  // ---------------------------------------------------------------------------
  // Locale helpers
  // ---------------------------------------------------------------------------

  static String _allLabel(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == 'fr' ? 'Toutes les pièces' : 'All rooms';
  }

  static String _allTypesLabel(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == 'fr' ? 'Tous les types' : 'All types';
  }

  // ---------------------------------------------------------------------------
  // Menu helpers
  // ---------------------------------------------------------------------------

  RelativeRect? _menuPosition(GlobalKey key) {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    final keyCtx = key.currentContext;
    if (keyCtx == null || overlay == null) return null;
    final box = keyCtx.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;
    return RelativeRect.fromRect(
      Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height),
      Offset.zero & overlay.size,
    );
  }

  Future<void> _showRoomMenu(EquipmentsController controller) async {
    final position = _menuPosition(_roomKey);
    if (position == null) return;

    final result = await showMenu<String>(
      context: context,
      position: position,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBR),
      items: [
        PopupMenuItem<String>(
          value: _kAll,
          child: _MenuRow(
            label: _allLabel(context),
            checked: _selectedRoomId == null,
          ),
        ),
        ...controller.rooms.map((r) => PopupMenuItem<String>(
              value: r.id,
              child: _MenuRow(label: r.name, checked: r.id == _selectedRoomId),
            )),
      ],
    );
    if (result == null || !mounted) return;
    setState(() => _selectedRoomId = result == _kAll ? null : result);
  }

  Future<void> _showTypeMenu() async {
    final position = _menuPosition(_typeKey);
    if (position == null) return;

    final l10n = context.l10n;
    final items = <({_DeviceKind kind, String label})>[
      (kind: _DeviceKind.all, label: _allTypesLabel(context)),
      (kind: _DeviceKind.equipment, label: l10n.tabEquipments),
      (kind: _DeviceKind.tv, label: 'TV'),
      (kind: _DeviceKind.wled, label: 'WLED'),
    ];

    final result = await showMenu<_DeviceKind>(
      context: context,
      position: position,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBR),
      items: items
          .map((e) => PopupMenuItem<_DeviceKind>(
                value: e.kind,
                child: _MenuRow(
                  label: e.label,
                  checked: _selectedKind == e.kind,
                ),
              ))
          .toList(),
    );
    if (result == null || !mounted) return;
    setState(() => _selectedKind = result);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EquipmentsController>();
    final liveCtl = context.watch<LivePollingController>();
    final groupId = widget.selectedGroupIdNotifier.value;

    if (controller.isLoading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    // Apply group filter
    var equipments = controller.equipmentsForGroup(groupId);
    var tvDevices = controller.tvDevicesForGroup(groupId);
    var wledDevices = controller.wledDevicesForGroup(groupId);

    // Apply room filter
    if (_selectedRoomId != null) {
      equipments =
          equipments.where((e) => e.roomId == _selectedRoomId).toList();
      tvDevices =
          tvDevices.where((tv) => tv.roomId == _selectedRoomId).toList();
      wledDevices =
          wledDevices.where((w) => w.roomId == _selectedRoomId).toList();
    }

    // Apply kind filter
    if (_selectedKind == _DeviceKind.equipment) {
      tvDevices = [];
      wledDevices = [];
    } else if (_selectedKind == _DeviceKind.tv) {
      equipments = [];
      wledDevices = [];
    } else if (_selectedKind == _DeviceKind.wled) {
      equipments = [];
      tvDevices = [];
    }

    final totalCount =
        equipments.length + tvDevices.length + wledDevices.length;

    // Room label
    final roomLabel = _selectedRoomId == null
        ? _allLabel(context)
        : controller.rooms
                .where((r) => r.id == _selectedRoomId)
                .firstOrNull
                ?.name ??
            _allLabel(context);

    // Type label
    final typeLabel = switch (_selectedKind) {
      _DeviceKind.all => _allTypesLabel(context),
      _DeviceKind.equipment => context.l10n.tabEquipments,
      _DeviceKind.tv => 'TV',
      _DeviceKind.wled => 'WLED',
    };

    return SafeArea(
      child: Column(
        children: [
          // Filter bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x3l,
              AppSpacing.x3l,
              AppSpacing.x3l,
              0,
            ),
            child: Row(
              children: [
                AppChip(
                  key: _roomKey,
                  label: roomLabel,
                  variant: AppChipVariant.outlined,
                  trailing: Icons.keyboard_arrow_down_rounded,
                  onTap: () => _showRoomMenu(controller),
                ),
                AppSpacing.gapHMd,
                AppChip(
                  key: _typeKey,
                  label: typeLabel,
                  variant: AppChipVariant.outlined,
                  trailing: Icons.keyboard_arrow_down_rounded,
                  onTap: () => _showTypeMenu(),
                ),
              ],
            ),
          ),
          AppSpacing.gapX3l,
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: totalCount,
              separatorBuilder: (_, _) => AppSpacing.gapX3l,
              itemBuilder: (_, i) {
                if (i < equipments.length) {
                  final e = equipments[i];
                  final st = controller.isSupported(e)
                      ? liveCtl.live[e.id]
                      : null;
                  final dotColor =
                      (st?.online ?? false) ? Colors.green : Colors.orange;
                  return _EquipmentPill(
                    title: e.name,
                    icon: _iconForType(e.type),
                    dotColor: dotColor,
                    onTap: () => _onEquipmentTap(e.id),
                  );
                }
                if (i < equipments.length + tvDevices.length) {
                  final tv = tvDevices[i - equipments.length];
                  return _EquipmentPill(
                    title: tv.name,
                    icon: Icons.tv,
                    dotColor: Colors.blueGrey,
                    onTap: () => _onTvTap(tv.id),
                  );
                }
                final wled =
                    wledDevices[i - equipments.length - tvDevices.length];
                return _EquipmentPill(
                  title: wled.name,
                  icon: Icons.lightbulb_outline_rounded,
                  dotColor: Colors.amber.shade600,
                  onTap: () => _onWledTap(wled.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Menu row
// ---------------------------------------------------------------------------

class _MenuRow extends StatelessWidget {
  final String label;
  final bool checked;

  const _MenuRow({required this.label, required this.checked});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (checked)
          const Icon(Icons.check_rounded, color: AppColors.primary, size: 18)
        else
          const SizedBox(width: 18),
        AppSpacing.gapHMd,
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Equipment pill tile
// ---------------------------------------------------------------------------

class _EquipmentPill extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color dotColor;
  final VoidCallback onTap;

  const _EquipmentPill({
    required this.title,
    required this.icon,
    required this.dotColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.x4lBR,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: AppRadius.x4lBR,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            AppSpacing.gapHXl,
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            AppSpacing.gapHLg,
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            AppSpacing.gapHLg,
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
