import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/hive/water_log_hive.dart';
import 'models/hive/calorie_log_hive.dart';
import 'models/hive/sync_queue_item.dart';
import 'services/connectivity_service.dart';
import 'services/sync_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'theme/app_text_styles.dart';
import 'screens/landing_screen.dart';

// Matra@DEV
//mathradev_db_user
//mpfHYU5UlMuzWohx
//mongodb+srv://mathradev_db_user:mpfHYU5UlMuzWohx@matra.mezvfev.mongodb.net/?appName=Matra

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Animate.restartOnHotReload = true;

  // Initialize Hive for offline storage
  await Hive.initFlutter();
  Hive.registerAdapter(WaterLogHiveAdapter());
  Hive.registerAdapter(CalorieLogHiveAdapter());
  Hive.registerAdapter(SyncQueueItemAdapter());

  // Initialize core services
  await ConnectivityService().init();
  await SyncService().init();
  await NotificationService().init();

  runApp(
    const ProviderScope(
      child: StackSenseApp(),
    ),
  );
}

class StackSenseApp extends ConsumerWidget {
  const StackSenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);

    return MaterialApp(
      title: 'StackSense',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
        Locale('hi'), // Hindi
        Locale('fr'), // French
      ],
      locale: ref.watch(localeProvider),

      home: const LandingScreen(),
    );
  }
}
