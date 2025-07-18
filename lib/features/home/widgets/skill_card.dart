// lib/features/home/widgets/skill_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skillstack/data/models/skill.dart';

class SkillCard extends StatelessWidget {
  final Skill skill;
  const SkillCard({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias, // Important for rounded corners on images
      child: InkWell(
        onTap: () => context.go('/skill/${skill.id}'),
        child: Stack(
          children: [
            // Background Image
            if (skill.customImagePath != null || skill.prebuiltTheme != null)
              Positioned.fill(
                child: _buildBackgroundImage(),
              ),
            // Gradient Overlay for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          skill.title,
                          style: textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Lvl ${skill.level}',
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          shadows: [const Shadow(blurRadius: 2, color: Colors.black)]
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(skill.category),
                    backgroundColor: colorScheme.primaryContainer.withOpacity(0.8),
                    labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
                    side: BorderSide.none,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: skill.level / 100.0,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    if (skill.customImagePath != null) {
      return Image.file(
        File(skill.customImagePath!),
        fit: BoxFit.cover,
        // Error builder in case the file was moved/deleted
        errorBuilder: (context, error, stackTrace) {
          return Container(color: Colors.grey[800]);
        },
      );
    }
    if (skill.prebuiltTheme != null) {
      return Image.asset(
        'assets/images/${skill.prebuiltTheme!}',
        fit: BoxFit.cover,
      );
    }
    return const SizedBox.shrink();
  }
}
