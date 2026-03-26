import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/widgets/curved_bottom_bar.dart';
import 'core/theme/app_colors.dart';
import 'core/i18n/loc.dart';

import 'domain/models/room_group.dart';
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

  /// Used to anchor the popup menu to the FAB.
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
    const StatsTab(),
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

  RelativeRect? _fabMenuPosition() {
    final overlayBox = Overlay.of(context).context.findRenderObject() as RenderBox?;
    final fabContext = _fabKey.currentContext;
    if (fabContext == null || overlayBox == null) return null;

    final fabBox = fabContext.findRenderObject() as RenderBox?;
    if (fabBox == null) return null;

    final fabPosition = fabBox.localToGlobal(Offset.zero);
    final fabSize = fabBox.size;

    return RelativeRect.fromRect(
      Rect.fromLTWH(
        fabPosition.dx,
        fabPosition.dy,
        fabSize.width,
        fabSize.height,
      ),
      Offset.zero & overlayBox.size,
    );
  }

  Future<_FabAction?> _showFabMenuForEquipments() async {
    final position = _fabMenuPosition();
    if (position == null) return null;

    return showMenu<_FabAction>(
      context: context,
      position: position,
      items: [
        PopupMenuItem<_FabAction>(
          value: _FabAction.addEquipment,
          child: Row(
            children: [
              const Icon(Icons.add),
              const SizedBox(width: 10),
              Text(context.l10n.addEquipmentTitle),
            ],
          ),
        ),
      ],
    );
  }

  Future<_FabAction?> _showFabMenuForHome() async {
    final position = _fabMenuPosition();
    if (position == null) return null;

    return showMenu<_FabAction>(
      context: context,
      position: position,
      items: [
        PopupMenuItem<_FabAction>(
          value: _FabAction.addRoom,
          child: Row(
            children: [
              const Icon(Icons.meeting_room_outlined),
              const SizedBox(width: 10),
              Text(context.l10n.addRoomTitle),
            ],
          ),
        ),
        PopupMenuItem<_FabAction>(
          value: _FabAction.addRoomGroup,
          child: Row(
            children: [
              const Icon(Icons.home_work_outlined),
              const SizedBox(width: 10),
              Text(context.l10n.roomsAddGroupTitle),
            ],
          ),
        ),
      ],
    );
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
      floatingActionButton: _index == 4
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
