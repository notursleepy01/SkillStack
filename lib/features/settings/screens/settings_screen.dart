// lib/features/settings/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillstack/providers/skill_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Reset All Data', style: TextStyle(color: Colors.red)),
            subtitle: const Text('This will permanently delete all skills and notes.'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Are you absolutely sure?'),
                  content: const Text('This action is irreversible. All your data will be lost.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Yes, Delete Everything'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(databaseProvider).clearAllData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data has been reset.')));
                  context.pop();
                }
              }
            },
          ),
          const Divider(),
          // Add more settings here in the future (e.g., theme selection, export/import)
        ],
      ),
    );
  }
}
