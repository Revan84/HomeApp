import 'package:flutter/material.dart';
import 'app_shell.dart';
import 'core/theme/app_theme.dart';
import 'core/i18n/app_strings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: AppTheme.dark(),
      home: const AppShell(),
    );
  }
}
