// lib/features/skill_detail/screens/skill_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skillstack/data/models/note.dart';
import 'package:skillstack/data/models/skill.dart';
import 'package:skillstack/data/services/notification_service.dart';
import 'package:skillstack/features/home/widgets/add_edit_skill_dialog.dart';
import 'package:skillstack/providers/skill_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SkillDetailScreen extends ConsumerWidget {
  final int skillId;
  const SkillDetailScreen({super.key, required this.skillId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillAsyncValue = ref.watch(skillByIdProvider(skillId));

    return skillAsyncValue.when(
      data: (skill) {
        if (skill == null) {
          return const Scaffold(body: Center(child: Text('Skill not found.')));
        }
        return _SkillDetailView(skill: skill);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

class _SkillDetailView extends ConsumerStatefulWidget {
  final Skill skill;
  const _SkillDetailView({required this.skill});

  @override
  ConsumerState<_SkillDetailView> createState() => _SkillDetailViewState();
}

class _SkillDetailViewState extends ConsumerState<_SkillDetailView> {
  late double _currentLevel;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.skill.level.toDouble();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
  
  void _addNote() {
    if (_noteController.text.isNotEmpty) {
      final db = ref.read(databaseProvider);
      final newNote = Note()
        ..content = _noteController.text
        ..createdAt = DateTime.now();
      
      db.saveNote(newNote, widget.skill.id);
      _noteController.clear();
      FocusScope.of(context).unfocus(); // Dismiss keyboard
    }
  }
  
  Future<void> _setReminder() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1))),
    );
    if (time == null) return;

    final scheduledTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    await NotificationService.scheduleReminder(widget.skill, scheduledTime);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder set for ${DateFormat.yMd().add_jm().format(scheduledTime)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final skill = widget.skill;
    final db = ref.read(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(skill.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AddEditSkillDialog(skill: skill),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Skill?'),
                  content: Text('Are you sure you want to delete "${skill.title}"? This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await db.deleteSkill(skill.id);
                context.pop();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Level Control
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mastery Level: ${_currentLevel.toInt()}', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Slider(
                    value: _currentLevel,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: _currentLevel.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentLevel = value;
                      });
                    },
                    // Update DB only when user finishes sliding
                    onChangeEnd: (double value) {
                      final updatedSkill = skill..level = value.toInt();
                      db.saveSkill(updatedSkill);
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _currentLevel == 100 ? 'Mastered! 🎉' : '${100 - _currentLevel.toInt()} levels to go!',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Description
          if (skill.description.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description', style: Theme.of(context).textTheme.titleMedium),
                    const Divider(),
                    Text(skill.description),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Reminders
          Card(
            child: ListTile(
              leading: const Icon(Icons.alarm_add_outlined),
              title: const Text('Set Practice Reminder'),
              onTap: _setReminder,
            ),
          ),
          const SizedBox(height: 24),
          // Notes Section
          Text('Notes', style: Theme.of(context).textTheme.headlineSmall).animate().fade(),
          const SizedBox(height: 8),
          ...skill.notes.map((note) => Card(
            child: ListTile(
              title: Text(note.content),
              subtitle: Text(DateFormat.yMd().add_jm().format(note.createdAt)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent),
                onPressed: () => db.deleteNote(note.id),
              ),
            ),
          ).animate().slideX()).toList(),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Add a new note...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _addNote,
              ),
            ),
            onSubmitted: (_) => _addNote(),
          ),
        ],
      ),
    );
  }
}
