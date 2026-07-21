/// Model representing step data for a single day.
class StepData {
  final DateTime date;
  final int steps;
  final double calories;
  final double distanceKm;
  final int goal;
  final bool goalMet;

  StepData({
    required this.date,
    required this.steps,
    required this.calories,
    required this.distanceKm,
    required this.goal,
    required this.goalMet,
  });

  factory StepData.fromMap(DateTime date, Map<String, dynamic> data) {
    final steps = data['steps'] as int? ?? 0;
    final goal = data['goal'] as int? ?? 8000;
    return StepData(
      date: date,
      steps: steps,
      calories: data['calories'] as double? ?? steps * 0.04,
      distanceKm: data['distanceKm'] as double? ?? (steps * 0.76) / 1000,
      goal: goal,
      goalMet: steps >= goal,
    );
  }

  Map<String, dynamic> toMap() => {
        'steps': steps,
        'calories': calories,
        'distanceKm': distanceKm,
        'goal': goal,
        'goalMet': goalMet,
      };
}
