// lib/data/services/database_service.dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skillstack/data/models/note.dart';
import 'package:skillstack/data/models/skill.dart';

class DatabaseService {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [SkillSchema, NoteSchema],
      directory: dir.path,
    );
  }

  // C.R.U.D. operations
  Future<List<Skill>> getSkills() => isar.skills.where().findAll();
  Stream<List<Skill>> watchSkills() => isar.skills.where().watch(fireImmediately: true);
  Future<Skill?> getSkillById(int id) => isar.skills.get(id);
  Future<void> saveSkill(Skill skill) => isar.writeTxn(() => isar.skills.put(skill));
  Future<void> deleteSkill(int skillId) => isar.writeTxn(() async {
    // Also delete associated notes
    await isar.notes.filter().skill((q) => q.idEqualTo(skillId)).deleteAll();
    await isar.skills.delete(skillId);
  });

  // Note Operations
  Future<void> saveNote(Note note, int skillId) => isar.writeTxn(() async {
    note.skill.value = await getSkillById(skillId);
    await isar.notes.put(note);
    await note.skill.save();
  });
  
  Future<void> deleteNote(int noteId) => isar.writeTxn(() => isar.notes.delete(noteId));

  // For settings screen
  Future<void> clearAllData() => isar.writeTxn(() => isar.clear());
}
