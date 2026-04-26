import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;

import 'app_shell.dart';

import 'core/theme/app_theme.dart';
import 'core/i18n/l10n/app_localizations.dart';
import 'core/i18n/locale_controller.dart';
import 'core/network/http_client.dart';
import 'core/storage/local_storage.dart';
import 'core/utils/id_generator.dart';

import 'domain/repositories/equipment_repository.dart';
import 'domain/repositories/room_group_repository.dart';
import 'domain/repositories/room_repository.dart';
import 'domain/repositories/cob_led_cct_repository.dart';
import 'domain/repositories/tv_repository.dart';
import 'domain/repositories/cob_led_rgb_repository.dart';

import 'data/repositories/equipment_repository_local.dart';
import 'data/repositories/room_group_repository_local.dart';
import 'data/repositories/room_repository_local.dart';
import 'features/integrations/samsung/data/samsung_tv_repository.dart';
import 'features/integrations/cob_led_cct/data/cob_led_cct_local_repository.dart';
import 'features/integrations/cob_led_rgb/data/cob_led_rgb_local_repository.dart';

import 'features/integrations/shelly/data/shelly_live_device_repository.dart';
import 'features/integrations/shelly/data/shelly_rpc_client.dart';

import 'features/live/controllers/live_polling_controller.dart';
import 'features/live/domain/live_polling_config.dart';

import 'features/stats/domain/stats_repository.dart';
import 'features/stats/data/mock_stats_repository.dart';
import 'features/stats/controller/stats_controller.dart';

import 'features/shell/controllers/shell_controller.dart';
import 'features/home/controllers/home_controller.dart';
import 'features/equipments/controllers/equipments_controller.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/alert_evaluation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
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
        Provider<IdGenerator>(create: (_) => const TimestampIdGenerator()),
        Provider<EquipmentRepository>(
          create: (_) => EquipmentRepositoryLocal(storage),
        ),
        Provider<RoomGroupRepository>(
          create: (_) => RoomGroupRepositoryLocal(storage),
        ),
        Provider<RoomRepository>(create: (_) => RoomRepositoryLocal(storage)),
        Provider<TvRepository>(
          create: (_) => SamsungTvRepository(storage),
        ),
        Provider<CobLedRgbRepository>(
          create: (_) => CobLedRgbLocalRepository(storage),
        ),
        Provider<CobLedCctRepository>(
          create: (_) => CobLedCctLocalRepository(storage),
        ),
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
        Provider<AlertEvaluationService>(
          create: (context) => AlertEvaluationService(
            live: context.read<LivePollingController>(),
            storage: context.read<LocalStorage>(),
          ),
          dispose: (_, svc) => svc.dispose(),
        ),
        Provider<StatsRepository>(
          create: (_) => MockStatsRepository(storage),
        ),
        ChangeNotifierProvider<StatsController>(
          create: (context) => StatsController(
            context.read<StatsRepository>(),
            roomRepo: context.read<RoomRepository>(),
            equipmentRepo: context.read<EquipmentRepository>(),
          ),
        ),
        ChangeNotifierProvider<ShellController>(
          create: (context) => ShellController(
            roomGroupRepo: context.read<RoomGroupRepository>(),
          ),
        ),
        ChangeNotifierProvider<HomeController>(
          create: (context) => HomeController(
            roomGroupRepo: context.read<RoomGroupRepository>(),
            roomRepo: context.read<RoomRepository>(),
            equipmentRepo: context.read<EquipmentRepository>(),
            tvRepo: context.read<TvRepository>(),
            cobLedRgbRepo: context.read<CobLedRgbRepository>(),
            cobLedCctRepo: context.read<CobLedCctRepository>(),
            liveController: context.read<LivePollingController>(),
            storage: context.read<LocalStorage>(),
            httpClient: context.read<http.Client>(),
          ),
        ),
        ChangeNotifierProvider<EquipmentsController>(
          create: (context) => EquipmentsController(
            equipmentRepo: context.read<EquipmentRepository>(),
            roomRepo: context.read<RoomRepository>(),
            tvRepo: context.read<TvRepository>(),
            cobLedRgbRepo: context.read<CobLedRgbRepository>(),
            cobLedCctRepo: context.read<CobLedCctRepository>(),
            liveController: context.read<LivePollingController>(),
            rpc: context.read<ShellyRpcClient>(),
            httpClient: context.read<http.Client>(),
          ),
        ),
      ],
      child: Consumer<LocaleController>(
        builder: (context, localeController, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'IOT Flutter App',
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
