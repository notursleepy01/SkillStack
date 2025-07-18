// lib/providers/skill_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillstack/data/models/skill.dart';
import 'package:skillstack/data/services/database_service.dart';

// 1. Provider for the database service itself
final databaseProvider = Provider<DatabaseService>((ref) => DatabaseService());

// 2. StreamProvider to watch for real-time changes in the skills list
final skillsStreamProvider = StreamProvider<List<Skill>>((ref) {
  final dbService = ref.watch(databaseProvider);
  return dbService.watchSkills();
});

// 3. Provider to get a single skill and its related data (like notes) by ID
final skillByIdProvider = StreamProvider.autoDispose.family<Skill?, int>((ref, id) {
  // CORRECTED LINE: Accessing static member 'isar' via the class name.
  return DatabaseService.isar.skills.watchObject(id, fireImmediately: true);
});

// 4. Provider for calculating statistics
final statsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(skillsStreamProvider).when(
    data: (skills) {
      if (skills.isEmpty) {
        return {
          'totalSkills': 0,
          'averageLevel': 0.0,
          'masteredSkills': 0,
          'categoryCounts': <String, int>{},
          'topCategory': 'N/A',
        };
      }
      final totalSkills = skills.length;
      final averageLevel = skills.map((s) => s.level).reduce((a, b) => a + b) / totalSkills;
      final masteredSkills = skills.where((s) => s.level == 100).length;
      final categoryCounts = <String, int>{};
      for (var skill in skills) {
        categoryCounts.update(skill.category, (value) => value + 1, ifAbsent: () => 1);
      }
      final topCategory = categoryCounts.entries.isEmpty ? 'N/A' : categoryCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      
      return {
        'totalSkills': totalSkills,
        'averageLevel': averageLevel,
        'masteredSkills': masteredSkills,
        'categoryCounts': categoryCounts,
        'topCategory': topCategory,
      };
    },
    loading: () => {}, // Return empty map while loading
    error: (_, __) => {}, // Return empty map on error
  );
});
