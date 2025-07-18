// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillstack/core/routing/app_router.dart';
import 'package:skillstack/data/services/database_service.dart';
import 'package:skillstack/data/services/notification_service.dart';
import 'package:skillstack/core/theme/app_theme.dart';

Future<void> main() async {
  // Ensure all bindings are initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services concurrently for faster startup.
  final (prefs, _, _,) = await (
    SharedPreferences.getInstance(),
    DatabaseService.init(),
    NotificationService.init(),
  ).wait;
  
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  runApp(
    ProviderScope(
      child: SkillStackApp(isFirstLaunch: isFirstLaunch),
    ),
  );
}

class SkillStackApp extends ConsumerWidget {
  final bool isFirstLaunch;

  const SkillStackApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the router provider, passing the first-launch flag.
    final router = ref.watch(routerProvider(isFirstLaunch));
    
    // DynamicColorBuilder provides Material You colors from the user's wallpaper.
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp.router(
          title: 'SkillStack',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(lightDynamic),
          darkTheme: AppTheme.darkTheme(darkDynamic),
          themeMode: ThemeMode.system,
          routerConfig: router,
        );
      },
    );
  }
}
