// lib/main.dart
import 'package:dynamic_color/dynamic_color.dart'; // <--- ADDED THIS IMPORT
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillstack/core/routing/app_router.dart';
import 'package:skillstack/data/services/database_service.dart';
import 'package:skillstack/data/services/notification_service.dart';
import 'package:skillstack/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    final router = ref.watch(routerProvider(isFirstLaunch));
    
    return DynamicColorBuilder( // This will now be recognized
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
