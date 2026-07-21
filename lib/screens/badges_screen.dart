import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:stride/providers/achievement_provider.dart';
import 'package:stride/providers/step_provider.dart';
import 'package:stride/services/achievement_service.dart';

/// Displays all achievement badges and their unlock status.
class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievementProvider = context.watch<AchievementProvider>();
    final stepProvider = context.watch<StepProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ACHIEVEMENTS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary
            Text(
              'Mascot Level ${stepProvider.mascotLevel} '
                  '${stepProvider.mascotLevelEmoji}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Total lifetime steps: '
                  '${NumberFormat.compact().format(stepProvider.totalLifetimeSteps)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: AchievementService.allAchievements.length,
                itemBuilder: (context, index) {
                  final achievement =
                      AchievementService.allAchievements[index];
                  final unlocked =
                      achievementProvider.isUnlocked(achievement.id);

                  return _buildBadgeCard(
                    context,
                    achievement,
                    unlocked,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeCard(
    BuildContext context,
    AchievementDef achievement,
    bool unlocked,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: unlocked
            ? (isDark ? Colors.grey[900] : Colors.grey[200])
            : (isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03)),
        borderRadius: BorderRadius.circular(16),
        border: unlocked
            ? Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                width: 1.5,
              )
            : Border.all(
                color: (isDark ? Colors.white12 : Colors.black12),
              ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            unlocked ? achievement.icon : '🔒',
            style: TextStyle(
              fontSize: 36,
              color: unlocked
                  ? null
                  : (isDark ? Colors.white24 : Colors.black26),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              achievement.title,
              style: TextStyle(
                color: unlocked
                    ? null
                    : (isDark ? Colors.white38 : Colors.black45),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              achievement.description,
              style: TextStyle(
                color: unlocked
                    ? (isDark ? Colors.white54 : Colors.black54)
                    : (isDark ? Colors.white24 : Colors.black38),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
