/// Lightweight snapshot of today's stats for UI rendering.
class DailyStats {
  final int currentSteps;
  final int dailyGoal;
  final double percent;
  final int streak;
  final int personalBestSteps;
  final double kcal;
  final double distanceKm;
  final int totalLifetimeSteps;
  final bool goalCelebratedToday;

  DailyStats({
    required this.currentSteps,
    required this.dailyGoal,
    required this.percent,
    required this.streak,
    required this.personalBestSteps,
    required this.kcal,
    required this.distanceKm,
    required this.totalLifetimeSteps,
    this.goalCelebratedToday = false,
  });

  DailyStats copyWith({
    int? currentSteps,
    int? dailyGoal,
    double? percent,
    int? streak,
    int? personalBestSteps,
    double? kcal,
    double? distanceKm,
    int? totalLifetimeSteps,
    bool? goalCelebratedToday,
  }) {
    return DailyStats(
      currentSteps: currentSteps ?? this.currentSteps,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      percent: percent ?? this.percent,
      streak: streak ?? this.streak,
      personalBestSteps: personalBestSteps ?? this.personalBestSteps,
      kcal: kcal ?? this.kcal,
      distanceKm: distanceKm ?? this.distanceKm,
      totalLifetimeSteps: totalLifetimeSteps ?? this.totalLifetimeSteps,
      goalCelebratedToday: goalCelebratedToday ?? this.goalCelebratedToday,
    );
  }

  static DailyStats empty() => DailyStats(
        currentSteps: 0,
        dailyGoal: 8000,
        percent: 0.0,
        streak: 0,
        personalBestSteps: 0,
        kcal: 0,
        distanceKm: 0.0,
        totalLifetimeSteps: 0,
      );
}
