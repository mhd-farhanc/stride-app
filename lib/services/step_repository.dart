import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'package:stride/constants.dart';

/// Repository that wraps all Hive operations for the step tracker.
/// Single source of truth for all persisted data.
class StepRepository {
  final Box _box;

  StepRepository(this._box);

  // ─── Steps ────────────────────────────────────────────────────────

  int getStepsForDate(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    return _box.get(key, defaultValue: 0) as int;
  }

  void saveStepsForDate(DateTime date, int steps) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    _box.put(key, steps);
  }

  int getTodaySteps() => getStepsForDate(DateTime.now());

  // ─── Calories & Distance ──────────────────────────────────────────

  double getCaloriesForDate(DateTime date) {
    final key = '${DateFormat('yyyy-MM-dd').format(date)}_kcal';
    return (_box.get(key, defaultValue: 0.0) as num).toDouble();
  }

  void saveCaloriesForDate(DateTime date, double calories) {
    final key = '${DateFormat('yyyy-MM-dd').format(date)}_kcal';
    _box.put(key, calories);
  }

  // ─── Goal ─────────────────────────────────────────────────────────

  int getDailyGoal() =>
      _box.get(kDailyGoal, defaultValue: defaultDailyGoal) as int;

  void setDailyGoal(int goal) => _box.put(kDailyGoal, goal);

  // ─── Theme ────────────────────────────────────────────────────────

  bool getIsDarkMode() =>
      _box.get(kIsDarkMode, defaultValue: true) as bool;

  void setIsDarkMode(bool value) => _box.put(kIsDarkMode, value);

  // ─── Personal Best ────────────────────────────────────────────────

  int getPersonalBest() =>
      _box.get(kPersonalBestSteps, defaultValue: 0) as int;

  void setPersonalBest(int best) => _box.put(kPersonalBestSteps, best);

  // ─── Sensor State ─────────────────────────────────────────────────

  int getLastSensorTotal() =>
      _box.get(kLastSensorTotal, defaultValue: 0) as int;

  void setLastSensorTotal(int total) => _box.put(kLastSensorTotal, total);

  String getLastRunDate() =>
      _box.get(kLastRunDate, defaultValue: '') as String;

  void setLastRunDate(String date) => _box.put(kLastRunDate, date);

  // ─── Lifetime Steps ───────────────────────────────────────────────

  int getTotalLifetimeSteps() =>
      _box.get(kTotalLifetimeSteps, defaultValue: 0) as int;

  void setTotalLifetimeSteps(int total) =>
      _box.put(kTotalLifetimeSteps, total);

  // ─── Achievements ─────────────────────────────────────────────────

  List<String> getUnlockedAchievements() {
    final raw = _box.get(kAchievements, defaultValue: <String>[]) as List;
    return raw.cast<String>();
  }

  void unlockAchievement(String id) {
    final list = getUnlockedAchievements();
    if (!list.contains(id)) {
      list.add(id);
      _box.put(kAchievements, list);
    }
  }

  // ─── Reminders ────────────────────────────────────────────────────

  bool getRemindersEnabled() =>
      _box.get(kRemindersEnabled, defaultValue: false) as bool;

  void setRemindersEnabled(bool value) =>
      _box.put(kRemindersEnabled, value);

  // ─── Celebrated Today ─────────────────────────────────────────────

  bool getCelebratedToday() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final key = '${kCelebratedToday}_$today';
    return _box.get(key, defaultValue: false) as bool;
  }

  void setCelebratedToday(bool value) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final key = '${kCelebratedToday}_$today';
    _box.put(key, value);
  }

  // ─── History Queries ──────────────────────────────────────────────

  Map<String, int> getStepHistoryForRange(int days) {
    final result = <String, int>{};
    final today = DateTime.now();
    for (int i = days - 1; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(day);
      result[key] = getStepsForDate(day);
    }
    return result;
  }

  int getWeeklyTotal() {
    int total = 0;
    final today = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      total += getStepsForDate(today.subtract(Duration(days: i)));
    }
    return total;
  }

  int getWeeklyAverage() {
    int total = 0;
    int daysWithData = 0;
    final today = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final steps = getStepsForDate(today.subtract(Duration(days: i)));
      if (steps > 0) {
        total += steps;
        daysWithData++;
      }
    }
    if (daysWithData == 0) return 0;
    return (total / daysWithData).round();
  }

  // ─── Streak ───────────────────────────────────────────────────────

  int calculateStreak(int dailyGoal) {
    int streak = 0;
    final today = DateTime.now();

    for (int i = 1; i < maxStreakDays; i++) {
      final day = today.subtract(Duration(days: i));
      final steps = getStepsForDate(day);
      if (steps == -1 || steps < dailyGoal) break;
      streak++;
    }

    final todaySteps = getTodaySteps();
    if (todaySteps >= dailyGoal) streak++;

    return streak;
  }
}
