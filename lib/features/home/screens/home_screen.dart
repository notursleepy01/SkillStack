// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillstack/features/home/widgets/add_edit_skill_dialog.dart';
import 'package:skillstack/features/home/widgets/skill_card.dart';
import 'package:skillstack/providers/skill_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final skillsAsyncValue = ref.watch(skillsStreamProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const AddEditSkillDialog(),
        ),
        child: const Icon(Icons.add),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('SkillStack'),
            floating: true,
            snap: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.go('/settings'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search Skills...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  filled: true,
                ),
              ),
            ),
          ),
          skillsAsyncValue.when(
            data: (skills) {
              final allCategories = ['All', ...skills.map((s) => s.category).toSet().toList()..sort()];

              final filteredSkills = skills.where((skill) {
                final titleMatch = skill.title.toLowerCase().contains(_searchQuery.toLowerCase());
                final categoryMatch = _selectedCategory == null || _selectedCategory == 'All' || skill.category == _selectedCategory;
                return titleMatch && categoryMatch;
              }).toList();

              if (skills.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No skills yet!', style: TextStyle(fontSize: 22, color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('Tap the + button to add your first skill.'),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: allCategories.length,
                      itemBuilder: (context, index) {
                        final category = allCategories[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: _selectedCategory == category || (_selectedCategory == null && category == 'All'),
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? category : null;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...filteredSkills.map((skill) =>
                    SkillCard(skill: skill)
                      .animate()
                      .fade(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0)
                  ).toList(),
                  const SizedBox(height: 80), // Padding for FAB
                ]),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
          ),
        ],
      ),
    );
  }
}
