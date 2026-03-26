import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;

import 'app_shell.dart';

import 'core/theme/app_theme.dart';
import 'core/i18n/app_strings.dart';
import 'core/i18n/l10n/app_localizations.dart';
import 'core/i18n/locale_controller.dart';
import 'core/network/http_client.dart';
import 'core/storage/local_storage.dart';

import 'domain/repositories/equipment_repository.dart';
import 'domain/repositories/room_group_repository.dart';
import 'domain/repositories/room_repository.dart';

import 'data/repositories/equipment_repository_local.dart';
import 'data/repositories/room_group_repository_local.dart';
import 'data/repositories/room_repository_local.dart';

import 'features/integrations/shelly/data/shelly_live_device_repository.dart';
import 'features/integrations/shelly/data/shelly_rpc_client.dart';

import 'features/live/controllers/live_polling_controller.dart';
import 'features/live/domain/live_polling_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final storage = SharedPrefsLocalStorage(prefs);

    return MultiProvider(
      providers: [
        Provider<LocalStorage>.value(value: storage),
        ChangeNotifierProvider<LocaleController>(
          create: (_) => LocaleController(prefs),
        ),
        Provider<EquipmentRepository>(
          create: (_) => EquipmentRepositoryLocal(storage),
        ),
        Provider<RoomGroupRepository>(
          create: (_) => RoomGroupRepositoryLocal(storage),
        ),
        Provider<RoomRepository>(create: (_) => RoomRepositoryLocal(storage)),
        Provider<http.Client>(
          create: (_) => http.Client(),
          dispose: (_, client) => client.close(),
        ),
        Provider<HttpClient>(
          create: (context) => HttpClient(context.read<http.Client>()),
        ),
        Provider<ShellyRpcClient>(
          create: (context) => ShellyRpcClient(context.read<HttpClient>()),
        ),
        Provider<ShellyLiveDeviceRepository>(
          create: (context) =>
              ShellyLiveDeviceRepository(context.read<ShellyRpcClient>()),
        ),
        ChangeNotifierProvider<LivePollingController>(
          create: (context) {
            final repo = context.read<ShellyLiveDeviceRepository>();
            final controller = LivePollingController(
              repo,
              const LivePollingConfig(),
            );
            controller.start();
            return controller;
          },
        ),
      ],
      child: Consumer<LocaleController>(
        builder: (context, localeController, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppStrings.appName,
            theme: AppTheme.dark(),
            home: const AppShell(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('fr'), Locale('en')],
            locale: localeController.locale,
          );
        },
      ),
    );
  }
}
