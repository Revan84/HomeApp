import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'app_shell.dart';
import 'core/theme/app_theme.dart';
import 'core/i18n/app_strings.dart';
import 'core/network/http_client.dart';
import 'core/storage/local_storage.dart';

import 'domain/repositories/equipment_repository.dart';
import 'domain/repositories/room_repository.dart';

import 'features/equipments/data/equipment_repository_local.dart';
import 'features/home/data/room_repository_local.dart';

import 'features/integrations/shelly/data/shelly_rpc_client.dart';
import 'features/integrations/shelly/data/shelly_live_device_repository.dart';

import 'features/live/controller/live_polling_controller.dart';
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

        Provider<EquipmentRepository>(
          create: (_) => EquipmentRepositoryLocal(storage),
        ),
        Provider<RoomRepository>(create: (_) => RoomRepositoryLocal(storage)),

        Provider<http.Client>(
          create: (_) => http.Client(),
          dispose: (_, c) => c.close(),
        ),

        Provider<HttpClient>(
          create: (ctx) => HttpClient(ctx.read<http.Client>()),
        ),

        // Shelly stack
        Provider<ShellyRpcClient>(
          create: (ctx) => ShellyRpcClient(ctx.read<HttpClient>()),
        ),
        Provider<ShellyLiveDeviceRepository>(
          create: (ctx) =>
              ShellyLiveDeviceRepository(ctx.read<ShellyRpcClient>()),
        ),

        // Live polling (singleton app)
        ChangeNotifierProvider<LivePollingController>(
          create: (ctx) {
            final repo = ctx.read<ShellyLiveDeviceRepository>();
            final ctl = LivePollingController(repo, const LivePollingConfig());
            ctl.start();
            return ctl;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appName,
        theme: AppTheme.dark(),
        home: const AppShell(),
      ),
    );
  }
}
