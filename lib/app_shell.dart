import 'package:flutter/material.dart';

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

  final _tabs = const <Widget>[
    HomeTab(),
    DataTab(),
    EquipmentsTab(),
    AutomationTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.show_chart_outlined), label: 'Data'),
          NavigationDestination(icon: Icon(Icons.devices_outlined), label: 'Equipments'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), label: 'Automation'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
