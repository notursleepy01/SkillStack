// lib/features/onboarding/screens/permission_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  Future<void> _requestAndContinue(BuildContext context) async {
    // Request permissions. The user can deny them, but we still proceed.
    await [
      Permission.notification,
      // For Android 13+, photos permission is needed for image_picker
      Permission.photos, 
    ].request();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
    if (context.mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.shield_moon_outlined, size: 80).animate().fade().scale(),
              const SizedBox(height: 24),
              Text(
                'Welcome to SkillStack!',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'To get the most out of the app, we need a couple of permissions.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _PermissionInfoTile(
                icon: Icons.notifications_active_outlined,
                title: 'Notifications',
                subtitle: 'To send you practice reminders for your skills.',
              ),
              const SizedBox(height: 16),
              _PermissionInfoTile(
                icon: Icons.image_outlined,
                title: 'Photo Library Access',
                subtitle: 'To allow you to set custom background images for your skill cards.',
              ),
              const Spacer(),
              FilledButton.tonal(
                onPressed: () => _requestAndContinue(context),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Grant Permissions & Start'),
              ).animate().slideInUp(delay: 300.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _PermissionInfoTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      contentPadding: EdgeInsets.zero,
    );
  }
}
