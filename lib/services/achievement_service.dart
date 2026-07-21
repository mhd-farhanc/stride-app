import 'package:stride/services/step_repository.dart';
import 'package:stride/constants.dart';

/// Service for checking and unlocking achievement badges.
class AchievementService {
  final StepRepository _repository;

  AchievementService(this._repository);

  /// All available achievements with their criteria.
  static const List<AchievementDef> allAchievements = [
    AchievementDef(
      id: 'first_steps',
      title: 'First Steps',
      description: 'Walk 1,000 steps in a single day',
      icon: '👣',
    ),
    AchievementDef(
      id: 'ten_k_club',
      title: '10K Club',
      description: 'Walk 10,000+ steps in a single day',
      icon: '🏆',
    ),
    AchievementDef(
      id: 'marathoner',
      title: 'Marathoner',
      description: 'Walk 42,000+ steps in a single day',
      icon: '🏅',
    ),
    AchievementDef(
      id: 'week_warrior',
      title: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      icon: '🔥',
    ),
    AchievementDef(
      id: 'month_warrior',
      title: 'Month Warrior',
      description: 'Maintain a 30-day streak',
      icon: '💪',
    ),
    AchievementDef(
      id: 'century',
      title: 'Century',
      description: 'Walk 100,000 steps in total',
      icon: '🎯',
    ),
  ];

  /// Check all achievements against current stats and unlock any that are met.
  /// Returns list of newly unlocked achievement IDs.
  List<String> checkAndUnlock(DailyStatsSummary stats) {
    final unlocked = _repository.getUnlockedAchievements();
    final newlyUnlocked = <String>[];

    for (final achievement in allAchievements) {
      if (unlocked.contains(achievement.id)) continue;

      bool earned = false;
      switch (achievement.id) {
        case 'first_steps':
          earned = stats.maxDailySteps >= achievementFirstSteps;
          break;
        case 'ten_k_club':
          earned = stats.maxDailySteps >= achievement10K;
          break;
        case 'marathoner':
          earned = stats.maxDailySteps >= achievementMarathon;
          break;
        case 'week_warrior':
          earned = stats.currentStreak >= achievementWeekStreak;
          break;
        case 'month_warrior':
          earned = stats.currentStreak >= achievementMonthStreak;
          break;
        case 'century':
          earned = stats.totalLifetimeSteps >= achievementCentury;
          break;
      }

      if (earned) {
        _repository.unlockAchievement(achievement.id);
        newlyUnlocked.add(achievement.id);
      }
    }

    return newlyUnlocked;
  }
}

/// Data needed by [AchievementService] to check criteria.
class DailyStatsSummary {
  final int maxDailySteps;
  final int currentStreak;
  final int totalLifetimeSteps;

  DailyStatsSummary({
    required this.maxDailySteps,
    required this.currentStreak,
    required this.totalLifetimeSteps,
  });
}

class AchievementDef {
  final String id;
  final String title;
  final String description;
  final String icon;

  const AchievementDef({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}
