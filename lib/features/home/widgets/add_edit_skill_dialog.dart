// lib/features/home/widgets/add_edit_skill_dialog.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skillstack/core/constants/constants.dart';
import 'package:skillstack/data/models/skill.dart';
import 'package:skillstack/providers/skill_providers.dart';
import 'package:path/path.dart' as p;

class AddEditSkillDialog extends ConsumerStatefulWidget {
  final Skill? skill; // If skill is provided, it's an edit dialog
  const AddEditSkillDialog({super.key, this.skill});

  @override
  ConsumerState<AddEditSkillDialog> createState() => _AddEditSkillDialogState();
}

class _AddEditSkillDialogState extends ConsumerState<AddEditSkillDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  
  String? _selectedPrebuiltTheme;
  String? _customImagePath;

  @override
  void initState() {
    super.initState();
    final s = widget.skill;
    _titleController = TextEditingController(text: s?.title ?? '');
    _descriptionController = TextEditingController(text: s?.description ?? '');
    _categoryController = TextEditingController(text: s?.category ?? 'General');
    _selectedPrebuiltTheme = s?.prebuiltTheme;
    _customImagePath = s?.customImagePath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = p.basename(pickedFile.path);
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
      setState(() {
        _customImagePath = savedImage.path;
        _selectedPrebuiltTheme = null; // Custom image overrides prebuilt
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final db = ref.read(databaseProvider);
      final newSkill = widget.skill ?? Skill();
      
      newSkill
        ..title = _titleController.text
        ..description = _descriptionController.text
        ..category = _categoryController.text.isEmpty ? 'General' : _categoryController.text
        ..level = widget.skill?.level ?? 1
        ..customImagePath = _customImagePath
        ..prebuiltTheme = _selectedPrebuiltTheme;
      
      db.saveSkill(newSkill);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.skill == null ? 'Add New Skill' : 'Edit Skill'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Skill Title'),
                validator: (value) => (value == null || value.isEmpty) ? 'Title cannot be empty' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (Optional)'),
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 20),
              Text('Card Background', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              // Pre-built themes
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: AppConstants.prebuiltCardThemes.map((theme) {
                  return ChoiceChip(
                    label: Text(theme.split('.').first.replaceAll('_', ' ').capitalize()),
                    avatar: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/$theme'),
                    ),
                    selected: _selectedPrebuiltTheme == theme,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedPrebuiltTheme = theme;
                          _customImagePath = null; // Clear custom image
                        } else {
                          _selectedPrebuiltTheme = null;
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              // Custom theme
              ListTile(
                leading: _customImagePath != null ? Image.file(File(_customImagePath!), width: 40, height: 40, fit: BoxFit.cover) : const Icon(Icons.image),
                title: const Text('Custom Image'),
                onTap: _pickImage,
                trailing: _customImagePath != null ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _customImagePath = null),
                ) : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: Text(widget.skill == null ? 'Add' : 'Save')),
      ],
    );
  }
}

extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }
}
