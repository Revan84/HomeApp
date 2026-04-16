import 'dart:math' show cos, sin;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/widgets/curved_bottom_bar.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_radius.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_font_sizes.dart';
import 'core/i18n/loc.dart';

import 'features/stats/domain/stat_widget.dart';

import 'features/shell/controllers/shell_controller.dart';
import 'features/home/pages/home_tab.dart';
import 'features/stats/pages/stats_tab.dart';
import 'features/equipments/pages/equipments_tab.dart';
import 'features/automation/pages/automation_tab.dart';
import 'features/profile/pages/profile_tab.dart';
import 'features/equipments/widgets/add_equipment_sheet.dart';
import 'features/tv/widgets/add_tv_sheet.dart';
import 'features/wled/widgets/add_wled_sheet.dart';
import 'features/home/widgets/add_room_sheet.dart';
import 'features/home/widgets/add_room_group_sheet.dart';
import 'features/home/widgets/home_summary_header.dart';
import 'features/equipments/controllers/equipments_controller.dart';
import 'features/live/controllers/live_polling_controller.dart';
import 'features/shell/widgets/device_type_picker_sheet.dart';

enum _FabAction {
  addDevice,
  addRoom,
  addRoomGroup,
  addChart,
  addTable,
  addHistory,
  addKpi,
}

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
  int _tabIndex = 0;
  final PageController _pageController = PageController();
  bool _isProgrammaticJump = false;

  final ValueNotifier<int> _equipmentsRefresh = ValueNotifier<int>(0);
  final ValueNotifier<int> _homeRefresh = ValueNotifier<int>(0);
  final ValueNotifier<int> _roomsRefresh = ValueNotifier<int>(0);
  final ValueNotifier<StatWidgetType?> _statsAddWidget =
      ValueNotifier<StatWidgetType?>(null);

  /// Bridge notifier: kept so child tabs (HomeTab, StatsTab, EquipmentsTab)
  /// can still listen via `ValueNotifier<String?>`. Synced from ShellController.
  final ValueNotifier<String?> _selectedGroupId = ValueNotifier<String?>(null);

  final GlobalKey _fabKey = GlobalKey();
  final GlobalKey _areaGroupKey = GlobalKey();

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

  @override
  void initState() {
    super.initState();
    final shell = context.read<ShellController>();
    shell.addListener(_syncGroupIdFromController);
    _homeRefresh.addListener(() => shell.loadRoomGroups());
    _roomsRefresh.addListener(() => shell.loadRoomGroups());
    shell.loadRoomGroups();
  }

  @override
  void dispose() {
    context.read<ShellController>().removeListener(_syncGroupIdFromController);
    _pageController.dispose();
    _selectedGroupId.dispose();
    _equipmentsRefresh.dispose();
    _homeRefresh.dispose();
    _roomsRefresh.dispose();
    _statsAddWidget.dispose();
    super.dispose();
  }

  /// Keeps the bridge [_selectedGroupId] notifier in sync with the controller.
  void _syncGroupIdFromController() {
    final shell = context.read<ShellController>();
    if (_selectedGroupId.value != shell.selectedGroupId) {
      _selectedGroupId.value = shell.selectedGroupId;
    }
  }

  // ---------------------------------------------------------------------------
  // Room-group picker
  // ---------------------------------------------------------------------------

  Future<void> _pickRoomGroup() async {
    final shell = context.read<ShellController>();
    if (shell.roomGroups.isEmpty) return;

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    final keyCtx = _areaGroupKey.currentContext;
    if (keyCtx == null || overlay == null) return;
    final box = keyCtx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;
    final position = RelativeRect.fromRect(
      Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height),
      Offset.zero & overlay.size,
    );

    final nextGroupId = await showMenu<String>(
      context: context,
      position: position,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBR),
      items: shell.roomGroups
          .map((g) => PopupMenuItem<String>(
                value: g.id,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (g.id == shell.selectedGroupId)
                      const Icon(Icons.check_rounded, color: AppColors.primary, size: 18)
                    else
                      const SizedBox(width: 18),
                    AppSpacing.gapHMd,
                    Text(g.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary)),
                  ],
                ),
              ))
          .toList(),
    );

    if (nextGroupId == null || nextGroupId == shell.selectedGroupId) return;
    shell.selectedGroupId = nextGroupId;
  }

  // ---------------------------------------------------------------------------
  // Tab navigation
  // ---------------------------------------------------------------------------

  Future<void> _goTo(int index) async {
    if (index == _tabIndex) return;
    setState(() => _tabIndex = index);
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

  Future<_FabAction?> _showFabPopup(List<_FabMenuOption> options) {
    final position = _fabMenuPosition();
    if (position == null) return Future.value(null);
    return showMenu<_FabAction>(
      context: context,
      position: position,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBR),
      items: options
          .map((o) => PopupMenuItem<_FabAction>(
                value: o.action,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(o.icon, color: AppColors.textPrimary, size: AppFontSizes.display),
                    AppSpacing.gapHLg,
                    Text(o.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary)),
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
          Icons.add, context.l10n.addEquipmentTitle, _FabAction.addDevice),
    ]);
  }

  Future<DeviceType?> _pickDeviceType() {
    return showModalBottomSheet<DeviceType>(
      context: context,
      useSafeArea: true,
      builder: (_) => const DeviceTypePickerSheet(),
    );
  }

  Future<void> _onFabPressed() async {
    switch (_tabIndex) {
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
        if (!mounted || action != _FabAction.addDevice) return;
        final deviceType = await _pickDeviceType();
        if (!mounted || deviceType == null) return;
        bool? added;
        switch (deviceType) {
          case DeviceType.connectedPlug:
            added = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => AddEquipmentSheet(
                roomsRefreshNotifier: _roomsRefresh,
              ),
            );
            break;
          case DeviceType.tv:
            added = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => const AddTvSheet(),
            );
            break;
          case DeviceType.wled:
            added = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => const AddWledSheet(),
            );
            break;
        }
        if (!mounted) return;
        if (added == true) {
          _equipmentsRefresh.value++;
          _homeRefresh.value++;
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
    final shell = context.watch<ShellController>();
    final liveController = context.watch<LivePollingController>();
    final equipCtl = context.watch<EquipmentsController>();

    // Count only devices that belong to the currently selected group.
    final groupId = shell.selectedGroupId;
    final groupDeviceIds = equipCtl
        .equipmentsForGroup(groupId)
        .map((e) => e.id)
        .toSet();
    final groupLive = liveController.live.entries
        .where((entry) => groupDeviceIds.contains(entry.key));
    final onlineCount = groupLive.where((e) => e.value.online == true).length;
    final offlineCount = groupLive.where((e) => e.value.online == false).length;

    return Scaffold(
      extendBody: true,
      floatingActionButton: (_tabIndex == 3 || _tabIndex == 4)
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: _DottedFab(
                key: _fabKey,
                onPressed: _onFabPressed,
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: HomeSummaryHeader(
                areaGroupKey: _areaGroupKey,
                areaGroupLabel: shell.activeRoomGroupLabel(
                  context.l10n.homeNoActiveRoomGroup,
                ),
                onlineCount: onlineCount,
                offlineCount: offlineCount,
                onTapAreaGroup: _pickRoomGroup,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  if (_isProgrammaticJump) return;
                  setState(() => _tabIndex = index);
                },
                children: _tabs,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CurvedBottomBar(
        index: _tabIndex,
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

// ---------------------------------------------------------------------------
// Dotted-border FAB
// ---------------------------------------------------------------------------

class _DottedFab extends StatelessWidget {
  const _DottedFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const double size = 64;
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.bg.withValues(alpha: 0.98),
            shape: BoxShape.circle,
          ),
          child: CustomPaint(
            painter: _DottedCirclePainter(
              color: AppColors.primary,
              dotRadius: 1.0,
              dotCount: 52,
            ),
            child: const Center(
              child: Icon(Icons.add, color: AppColors.primary, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  const _DottedCirclePainter({
    required this.color,
    this.dotRadius = 2.0,
    this.dotCount = 36,
  });

  final Color color;
  final double dotRadius;
  final int dotCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - dotRadius;
    const twoPi = 2 * 3.141592653589793;

    for (int i = 0; i < dotCount; i++) {
      final angle = twoPi * i / dotCount;
      final dx = center.dx + radius * cos(angle);
      final dy = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(dx, dy), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(_DottedCirclePainter old) =>
      old.color != color || old.dotRadius != dotRadius || old.dotCount != dotCount;
}
