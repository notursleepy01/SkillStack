// lib/data/models/skill.dart
import 'package:isar/isar.dart';
import 'package:skillstack/data/models/note.dart';

part 'skill.g.dart';

@collection
class Skill {
  Id id = Isar.autoIncrement;

  late String title;
  late String description;
  late String category;
  
  @Index()
  late int level;

  // For card background
  String? prebuiltTheme; // e.g., 'dragon_fire.jpg'
  String? customImagePath; // path to user-selected image

  // Link to associated notes
  @Backlink(to: 'skill')
  final notes = IsarLinks<Note>();
}
