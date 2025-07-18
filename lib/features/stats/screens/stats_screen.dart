// lib/features/stats/screens/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillstack/providers/skill_providers.dart';
import 'package:flutter_animate/flutter_animate.dart'; // <<< THIS IMPORT IS THE KEY

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (stats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: (stats['totalSkills'] as int) == 0
          ? const Center(child: Text('Add some skills to see your stats!'))
          : ListView(
              padding: const EdgeInsets.all(16),
              // The .animate() call on the list of children will now work correctly
              children: <Widget>[
                _StatCard(
                  icon: Icons.stacked_line_chart,
                  title: 'Total Skills',
                  value: stats['totalSkills'].toString(),
                  color: colorScheme.primary,
                ),
                _StatCard(
                  icon: Icons.star_half,
                  title: 'Average Level',
                  value: (stats['averageLevel'] as double).toStringAsFixed(1),
                  color: colorScheme.secondary,
                ),
                _StatCard(
                  icon: Icons.workspace_premium,
                  title: 'Mastered Skills',
                  value: stats['masteredSkills'].toString(),
                  color: Colors.amber.shade700,
                ),
                _StatCard(
                  icon: Icons.category,
                  title: 'Top Category',
                  value: stats['topCategory'].toString(),
                  color: colorScheme.tertiary,
                ),
                const SizedBox(height: 24),
                // REPLACED '.p(8)' with a standard Padding widget for robustness
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Category Breakdown', style: textTheme.headlineSmall),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: (stats['categoryCounts'] as Map<String, int>).entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Text(entry.key, style: textTheme.titleMedium),
                              const Spacer(),
                              Text(entry.value.toString(), style: textTheme.titleMedium?.copyWith(color: colorScheme.primary)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ].animate(interval: 100.ms).fade(duration: 500.ms).slideY(begin: 0.5),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
