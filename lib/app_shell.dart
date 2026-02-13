import 'package:flutter/material.dart';
import 'package:front_end/features/home/view/add_room_sheet.dart';

import 'core/i18n/app_strings.dart';
import 'core/widgets/curved_bottom_bar.dart';
import 'core/theme/app_colors.dart';

import 'features/home/view/home_tab.dart';
import 'features/stats/view/stats_tab.dart';
import 'features/equipments/view/equipments_tab.dart';
import 'features/automation/view/automation_tab.dart';
import 'features/profile/view/profile_tab.dart';
import 'features/equipments/view/add_equipment_sheet.dart';

enum _FabAction { addEquipment, addRoom }

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

  // ✅ pour ancrer le menu au FAB
  final GlobalKey _fabKey = GlobalKey();

  late final List<Widget> _tabs = <Widget>[
    HomeTab(refreshNotifier: _homeRefresh),
    const StatsTab(),
    EquipmentsTab(refreshNotifier: _equipmentsRefresh),
    const AutomationTab(),
    const ProfileTab(),
  ];

  Future<void> _goTo(int i) async {
    if (i == _index) return;

    setState(() => _index = i);

    _isProgrammaticJump = true;
    try {
      await _pageController.animateToPage(
        i,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } finally {
      _isProgrammaticJump = false;
    }
  }

  Future<_FabAction?> _showFabMenu() async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final fabContext = _fabKey.currentContext;
    if (fabContext == null) return null;

    final fabBox = fabContext.findRenderObject() as RenderBox;
    final fabPos = fabBox.localToGlobal(Offset.zero);
    final fabSize = fabBox.size;

    final position = RelativeRect.fromRect(
      Rect.fromLTWH(fabPos.dx, fabPos.dy, fabSize.width, fabSize.height),
      Offset.zero & overlay.size,
    );

    return showMenu<_FabAction>(
      context: context,
      position: position,
      items: const [
        PopupMenuItem<_FabAction>(
          value: _FabAction.addEquipment,
          child: Row(
            children: [
              Icon(Icons.add),
              SizedBox(width: 10),
              Text("Ajouter un équipement"),
            ],
          ),
        ),
      ],
    );
  }

  Future<_FabAction?> _showFabMenuForHome() async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final fabContext = _fabKey.currentContext;
    if (fabContext == null) return null;

    final fabBox = fabContext.findRenderObject() as RenderBox;
    final fabPos = fabBox.localToGlobal(Offset.zero);
    final fabSize = fabBox.size;

    final position = RelativeRect.fromRect(
      Rect.fromLTWH(fabPos.dx, fabPos.dy, fabSize.width, fabSize.height),
      Offset.zero & overlay.size,
    );
    return showMenu<_FabAction>(
      context: context,
      position: position,
      items: const [
        PopupMenuItem<_FabAction>(
          value: _FabAction.addRoom,
          child: Row(
            children: [
              Icon(Icons.meeting_room_outlined),
              SizedBox(width: 10),
              Text("Ajouter une pièce"),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onFabPressed() async {
    // Capture ce qui dépend de context immédiatement

    switch (_index) {
      case 0: // Home
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
            _equipmentsRefresh.value++;
            _homeRefresh.value++;
          } else {
            // optionnel: rien
          }
        }
        break;

      case 2: // EquipmentsTab
        final action = await _showFabMenu();
        if (!mounted) return;

        if (action == _FabAction.addEquipment) {
          final added = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) =>
                AddEquipmentSheet(roomsRefreshNotifier: _roomsRefresh),
          );

          if (!mounted) return;

          if (added == true) {
            _equipmentsRefresh.value++;
            _homeRefresh.value++;
          }
        }
        break;

      default:
        // On évite l’avertissement "unused" si tu ne l’utilises pas.
        // nav; // <- pas besoin, mais si ton lint râle, supprime nav.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: _index == 4
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: FloatingActionButton(
                key: _fabKey, // ✅ important
                backgroundColor: AppColors.bg,
                foregroundColor: AppColors.success,
                elevation: 0,
                onPressed: _onFabPressed,
                child: const Icon(Icons.add),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (i) {
          if (_isProgrammaticJump) return;
          setState(() => _index = i);
        },
        children: _tabs,
      ),
      bottomNavigationBar: CurvedBottomBar(
        index: _index,
        onTap: (i) => _goTo(i),
        labels: const [
          AppStrings.tabHome,
          AppStrings.tabData,
          AppStrings.tabEquipments,
          AppStrings.tabAutomation,
          AppStrings.tabProfile,
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
