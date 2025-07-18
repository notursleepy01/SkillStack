// lib/core/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillstack/features/onboarding/screens/permission_screen.dart';
import 'package:skillstack/features/home/screens/home_screen.dart';
import 'package:skillstack/features/skill_detail/screens/skill_detail_screen.dart';
import 'package:skillstack/features/settings/screens/settings_screen.dart';
import 'package:skillstack/features/stats/screens/stats_screen.dart';
import 'package:skillstack/shared/widgets/main_scaffold_with_nav.dart';

// Provider to create the GoRouter instance
final routerProvider = Provider.family<GoRouter, bool>((ref, isFirstLaunch) {
  return GoRouter(
    initialLocation: isFirstLaunch ? '/onboarding' : '/home',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const PermissionScreen(),
      ),
      // ShellRoute for screens with the bottom navigation bar
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffoldWithNav(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/stats',
            pageBuilder: (context, state) => const NoTransitionPage(child: StatsScreen()),
          ),
        ],
      ),
      // Top-level route for the skill detail screen (no bottom nav)
      GoRoute(
        path: '/skill/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return SkillDetailScreen(skillId: id);
        },
      ),
       // Top-level route for settings screen (no bottom nav)
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
