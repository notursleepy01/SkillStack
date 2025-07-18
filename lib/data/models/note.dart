// lib/data/models/note.dart
import 'package:isar/isar.dart';
import 'package:skillstack/data/models/skill.dart';

part 'note.g.dart';

@collection
class Note {
  Id id = Isar.autoIncrement;
  late String content;
  late DateTime createdAt;

  // Link back to the parent skill
  final skill = IsarLink<Skill>();
}
