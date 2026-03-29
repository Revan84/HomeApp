import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/widgets/curved_bottom_bar.dart';
import 'core/theme/app_colors.dart';
import 'core/i18n/loc.dart';

import 'domain/models/room_group.dart';
import 'domain/models/stat_widget.dart';
import 'domain/repositories/room_group_repository.dart';

import 'features/home/pages/home_tab.dart';
import 'features/stats/pages/stats_tab.dart';
import 'features/equipments/pages/equipments_tab.dart';
import 'features/automation/pages/automation_tab.dart';
import 'features/profile/pages/profile_tab.dart';
import 'features/equipments/widgets/add_equipment_sheet.dart';
import 'features/home/widgets/add_room_sheet.dart';
import 'features/home/widgets/add_room_group_sheet.dart';
import 'features/home/widgets/home_summary_header.dart';
import 'features/live/controllers/live_polling_controller.dart';

enum _FabAction {
  addEquipment,
  addRoom,
  addRoomGroup,
  addChart,
  addTable,
  addHistory,
  addKpi,
}

/// A single option in the FAB popup menu.
class _FabMenuOption {
  final IconData icon;
  final String label;
  final _FabAction action;
  const _FabMenuOption(this.icon, this.label, this.action);
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final PageController _pageController = PageController();
  bool _isProgrammaticJump = false;

  final ValueNotifier<int> _equipmentsRefresh = ValueNotifier<int>(0);
  final ValueNotifier<int> _homeRefresh = ValueNotifier<int>(0);
  final ValueNotifier<int> _roomsRefresh = ValueNotifier<int>(0);
  final ValueNotifier<StatWidgetType?> _statsAddWidget =
      ValueNotifier<StatWidgetType?>(null);

  /// Used to anchor the popup menu above the FAB.
  final GlobalKey _fabKey = GlobalKey();

  // ---------------------------------------------------------------------------
  // Shared state: selected room group (used by header + HomeTab)
  // ---------------------------------------------------------------------------
  final ValueNotifier<String?> _selectedGroupId = ValueNotifier<String?>(null);
  List<RoomGroup> _roomGroups = const [];

  late final List<Widget> _tabs = <Widget>[
    HomeTab(
      refreshNotifier: _homeRefresh,
      selectedGroupIdNotifier: _selectedGroupId,
    ),
    StatsTab(
      selectedGroupIdNotifier: _selectedGroupId,
      addWidgetNotifier: _statsAddWidget,
    ),
    EquipmentsTab(
      refreshNotifier: _equipmentsRefresh,
      selectedGroupIdNotifier: _selectedGroupId,
    ),
    const AutomationTab(),
    const ProfileTab(),
  ];

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadRoomGroups();
    _homeRefresh.addListener(_loadRoomGroups);
    _roomsRefresh.addListener(_loadRoomGroups);
    _selectedGroupId.addListener(_onGroupChanged);
  }

  @override
  void dispose() {
    _homeRefresh.removeListener(_loadRoomGroups);
    _roomsRefresh.removeListener(_loadRoomGroups);
    _selectedGroupId.removeListener(_onGroupChanged);
    _pageController.dispose();
    _selectedGroupId.dispose();
    super.dispose();
  }

  void _onGroupChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadRoomGroups() async {
    final repo = context.read<RoomGroupRepository>();
    final groups = await repo.loadAll();

    if (!mounted) return;

    final sorted = [...groups]..sort((a, b) {
        final s = a.sortOrder.compareTo(b.sortOrder);
        return s != 0 ? s : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    final currentId = _selectedGroupId.value;
    if (!sorted.any((g) => g.id == currentId)) {
      _selectedGroupId.value =
          sorted.isNotEmpty ? sorted.first.id : null;
    }

    setState(() {
      _roomGroups = sorted;
    });
  }

  // ---------------------------------------------------------------------------
  // Header helpers
  // ---------------------------------------------------------------------------

  String get _activeRoomGroupLabel {
    final selectedId = _selectedGroupId.value;
    if (selectedId == null) return context.l10n.homeNoActiveRoomGroup;
    final group = _roomGroups.cast<RoomGroup?>().firstWhere(
          (g) => g?.id == selectedId,
          orElse: () => null,
        );
    return group?.name ?? context.l10n.homeNoActiveRoomGroup;
  }

  Future<void> _pickRoomGroup() async {
    if (_roomGroups.isEmpty) return;

    final nextGroupId = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.homeSelectRoomGroupTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                ..._roomGroups.map(
                  (group) => ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(group.name),
                    trailing: group.id == _selectedGroupId.value
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () => Navigator.of(context).pop(group.id),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (nextGroupId == null || nextGroupId == _selectedGroupId.value) return;

    _selectedGroupId.value = nextGroupId;
  }

  // ---------------------------------------------------------------------------
  // Tab navigation
  // ---------------------------------------------------------------------------

  Future<void> _goTo(int index) async {
    if (index == _index) return;

    setState(() => _index = index);

    _isProgrammaticJump = true;
    try {
      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } finally {
      _isProgrammaticJump = false;
    }
  }

  // ---------------------------------------------------------------------------
  // FAB menu
  // ---------------------------------------------------------------------------

  /// Computes the position rectangle of the FAB for anchoring popup menus.
  RelativeRect? _fabMenuPosition() {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    final fabCtx = _fabKey.currentContext;
    if (fabCtx == null || overlay == null) return null;

    final fabBox = fabCtx.findRenderObject() as RenderBox?;
    if (fabBox == null) return null;

    final pos = fabBox.localToGlobal(Offset.zero);
    final size = fabBox.size;

    return RelativeRect.fromRect(
      Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height),
      Offset.zero & overlay.size,
    );
  }

  /// Shows a dark popup menu anchored above the FAB.
  Future<_FabAction?> _showFabPopup(List<_FabMenuOption> options) {
    final position = _fabMenuPosition();
    if (position == null) return Future.value(null);

    return showMenu<_FabAction>(
      context: context,
      position: position,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: options
          .map((o) => PopupMenuItem<_FabAction>(
                value: o.action,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(o.icon, color: AppColors.textPrimary, size: 20),
                    const SizedBox(width: 10),
                    Text(o.label,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 13)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Future<_FabAction?> _showFabMenuForHome() {
    return _showFabPopup([
      _FabMenuOption(Icons.meeting_room_outlined, context.l10n.addRoomTitle,
          _FabAction.addRoom),
      _FabMenuOption(Icons.home_work_outlined,
          context.l10n.roomsAddGroupTitle, _FabAction.addRoomGroup),
    ]);
  }

  Future<_FabAction?> _showFabMenuForStats() {
    final l10n = context.l10n;
    return _showFabPopup([
      _FabMenuOption(Icons.show_chart, l10n.statsAddChart, _FabAction.addChart),
      _FabMenuOption(
          Icons.table_chart_outlined, l10n.statsAddTable, _FabAction.addTable),
      _FabMenuOption(Icons.history, l10n.statsAddHistory, _FabAction.addHistory),
      _FabMenuOption(
          Icons.bookmark_outline, l10n.statsAddKpi, _FabAction.addKpi),
    ]);
  }

  Future<_FabAction?> _showFabMenuForEquipments() {
    return _showFabPopup([
      _FabMenuOption(
          Icons.add, context.l10n.addEquipmentTitle, _FabAction.addEquipment),
    ]);
  }

  Future<void> _onFabPressed() async {
    switch (_index) {
      case 0:
        final action = await _showFabMenuForHome();
        if (!mounted) return;

        if (action == _FabAction.addRoom) {
          final added = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => const AddRoomSheet(),
          );

          if (!mounted) return;

          if (added == true) {
            _homeRefresh.value++;
            _roomsRefresh.value++;
          }
        }

        if (action == _FabAction.addRoomGroup) {
          final added = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => const AddRoomGroupSheet(),
          );

          if (!mounted) return;

          if (added == true) {
            _homeRefresh.value++;
            _roomsRefresh.value++;
          }
        }
        break;

      case 1:
        final statsAction = await _showFabMenuForStats();
        if (!mounted || statsAction == null) return;
        final typeMap = {
          _FabAction.addChart: StatWidgetType.chart,
          _FabAction.addTable: StatWidgetType.table,
          _FabAction.addHistory: StatWidgetType.history,
          _FabAction.addKpi: StatWidgetType.kpi,
        };
        _statsAddWidget.value = typeMap[statsAction];
        break;

      case 2:
        final action = await _showFabMenuForEquipments();
        if (!mounted) return;

        if (action == _FabAction.addEquipment) {
          final added = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => AddEquipmentSheet(
              roomsRefreshNotifier: _roomsRefresh,
            ),
          );

          if (!mounted) return;

          if (added == true) {
            _equipmentsRefresh.value++;
            _homeRefresh.value++;
          }
        }
        break;

      default:
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final liveController = context.watch<LivePollingController>();
    final onlineCount =
        liveController.live.values.where((s) => s.online == true).length;
    final offlineCount =
        liveController.live.values.where((s) => s.online == false).length;

    return Scaffold(
      extendBody: true,
      floatingActionButton: (_index == 3 || _index == 4)
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: FloatingActionButton(
                key: _fabKey,
                backgroundColor: AppColors.bg,
                foregroundColor: AppColors.success,
                elevation: 0,
                onPressed: _onFabPressed,
                child: const Icon(Icons.add),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Fixed header visible across all tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: HomeSummaryHeader(
                areaGroupLabel: _activeRoomGroupLabel,
                onlineCount: onlineCount,
                offlineCount: offlineCount,
                onTapAreaGroup: _pickRoomGroup,
              ),
            ),
            // Tab content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  if (_isProgrammaticJump) return;
                  setState(() => _index = index);
                },
                children: _tabs,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CurvedBottomBar(
        index: _index,
        onTap: (index) => _goTo(index),
        labels: [
          context.l10n.tabHome,
          context.l10n.tabData,
          context.l10n.tabEquipments,
          context.l10n.tabAutomation,
          context.l10n.tabProfile,
        ],
        icons: const [
          Icons.home_rounded,
          Icons.bar_chart_rounded,
          Icons.cast_connected_rounded,
          Icons.sync_rounded,
          Icons.person_rounded,
        ],
      ),
    );
  }
}
