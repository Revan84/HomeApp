import 'package:flutter/material.dart';

import 'core/i18n/app_strings.dart';
import 'core/widgets/curved_bottom_bar.dart';
import 'core/theme/app_colors.dart';

import 'features/home/view/home_tab.dart';
import 'features/data/view/data_tab.dart';
import 'features/equipments/view/equipments_tab.dart';
import 'features/automation/view/automation_tab.dart';
import 'features/profile/view/profile_tab.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final PageController _pageController = PageController();
  bool _isProgrammaticJump = false;

  final _tabs = const <Widget>[
    HomeTab(),
    DataTab(),
    EquipmentsTab(),
    AutomationTab(),
    ProfileTab(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 48),
        child: FloatingActionButton(
          backgroundColor: AppColors.bg,
          foregroundColor: AppColors.success,
          elevation: 0,
          onPressed: () {},
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