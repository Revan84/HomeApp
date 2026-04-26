import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/notifications/alert_evaluation_service.dart';
import 'core/notifications/notification_service.dart';
import 'core/widgets/curved_bottom_bar.dart';
import 'core/widgets/dotted_fab.dart';
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
import 'features/home/widgets/add_room_sheet.dart';
import 'features/home/widgets/add_room_group_sheet.dart';
import 'features/home/widgets/home_summary_header.dart';
import 'features/equipments/controllers/equipments_controller.dart';
import 'features/equipments/widgets/add_device_dialog.dart';
import 'features/live/controllers/live_polling_controller.dart';

enum _FabAction {
  addDevice,
  scanDevice,
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

  StreamSubscription<AlertBannerEvent>? _bannerSub;

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

    // Subscribe to in-app alert banners.
    _bannerSub = context
        .read<AlertEvaluationService>()
        .bannerStream
        .listen(_showAlertBanner);

    // Request notification permission after the first frame so the system
    // dialog appears on top of a fully-rendered screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.requestPermission();
    });
  }

  @override
  void dispose() {
    _bannerSub?.cancel();
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

  Future<_FabAction?> _showFabMenu(List<_FabMenuOption> options) {
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
                    Icon(o.icon,
                        color: AppColors.textPrimary,
                        size: AppFontSizes.display),
                    AppSpacing.gapHLg,
                    Text(
                      o.label,
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
  }

  void _showAlertBanner(AlertBannerEvent event) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xlBR,
          side: const BorderSide(color: AppColors.danger, width: 0.8),
        ),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(Icons.warning_amber_rounded,
                  color: AppColors.danger, size: 18),
            ),
            AppSpacing.gapHMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontFamily: 'ShareTech',
                      fontWeight: FontWeight.w600,
                      fontSize: AppFontSizes.body,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.body,
                    style: const TextStyle(
                      fontFamily: 'ShareTech',
                      fontSize: AppFontSizes.sm,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScanDeviceInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Wi-Fi scan coming soon',
          style: TextStyle(fontFamily: 'ShareTech'),
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBR),
      ),
    );
  }

  Future<void> _onFabPressed() async {
    final l10n = context.l10n;
    switch (_tabIndex) {
      // ── Home: add room / room group ──────────────────────────────────────
      case 0:
        final action = await _showFabMenu([
          _FabMenuOption(
              Icons.meeting_room_outlined, l10n.addRoomTitle, _FabAction.addRoom),
          _FabMenuOption(
              Icons.home_work_outlined, l10n.roomsAddGroupTitle, _FabAction.addRoomGroup),
        ]);
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

      // ── Stats: add widget ────────────────────────────────────────────────
      case 1:
        final statsAction = await _showFabMenu([
          _FabMenuOption(Icons.show_chart, l10n.statsAddChart, _FabAction.addChart),
          _FabMenuOption(
              Icons.table_chart_outlined, l10n.statsAddTable, _FabAction.addTable),
          _FabMenuOption(Icons.history, l10n.statsAddHistory, _FabAction.addHistory),
          _FabMenuOption(
              Icons.bookmark_outline, l10n.statsAddKpi, _FabAction.addKpi),
        ]);
        if (!mounted || statsAction == null) return;
        _statsAddWidget.value = {
          _FabAction.addChart: StatWidgetType.chart,
          _FabAction.addTable: StatWidgetType.table,
          _FabAction.addHistory: StatWidgetType.history,
          _FabAction.addKpi: StatWidgetType.kpi,
        }[statsAction];
        break;

      // ── Equipments: add / scan device ────────────────────────────────────
      case 2:
        final action = await _showFabMenu([
          _FabMenuOption(
              Icons.add_rounded, l10n.addEquipmentTitle, _FabAction.addDevice),
          _FabMenuOption(
              Icons.wifi_find_rounded, 'Scan on Wi-Fi', _FabAction.scanDevice),
        ]);
        if (!mounted || action == null) return;
        if (action == _FabAction.scanDevice) {
          _showScanDeviceInfo();
          return;
        }
        final added = await AddDeviceDialog.show(context);
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
              child: DottedFab(
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

