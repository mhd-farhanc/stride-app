import 'package:flutter/foundation.dart';

import 'package:stride/models/daily_stats.dart';
import 'package:stride/services/pedometer_service.dart';
import 'package:stride/services/step_repository.dart';
import 'package:stride/services/achievement_service.dart';
import 'package:stride/services/reminder_service.dart';
import 'package:stride/services/notification_service.dart';
import 'package:stride/services/csv_export_service.dart';
import 'package:stride/constants.dart';

/// Central provider for step-related state and business logic.
class StepProvider extends ChangeNotifier {
  final StepRepository _repository;
  final PedometerService _pedometerService;
  final AchievementService _achievementService;
  final ReminderService _reminderService;

  late DailyStats _stats;
  int _weeklyTotal = 0;
  int _weeklyAverage = 0;
  int _maxDailySteps = 0;
  List<String> _newlyUnlockedAchievements = [];

  StepProvider({
    required StepRepository repository,
    required PedometerService pedometerService,
    required AchievementService achievementService,
    required NotificationService notificationService,
  })  : _repository = repository,
        _pedometerService = pedometerService,
        _achievementService = achievementService,
        _reminderService = ReminderService(notificationService) {
    _stats = DailyStats.empty();
  }

  // ─── Getters ──────────────────────────────────────────────────────

  DailyStats get stats => _stats;
  int get weeklyTotal => _weeklyTotal;
  int get weeklyAverage => _weeklyAverage;
  List<String> get newlyUnlockedAchievements => _newlyUnlockedAchievements;
  bool get goalJustReached => _pedometerService.goalJustReached;
  int get currentStreak => _stats.streak;
  int get dailyGoal => _stats.dailyGoal;
  int get currentSteps => _stats.currentSteps;
  int get personalBest => _stats.personalBestSteps;
  double get kcal => _stats.kcal;
  double get distanceKm => _stats.distanceKm;
  int get totalLifetimeSteps => _stats.totalLifetimeSteps;

  // ─── Mascot Level ─────────────────────────────────────────────────

  int get mascotLevel {
    final lifetime = _stats.totalLifetimeSteps;
    if (lifetime >= mascotLevel6) return 6;
    if (lifetime >= mascotLevel5) return 5;
    if (lifetime >= mascotLevel4) return 4;
    if (lifetime >= mascotLevel3) return 3;
    if (lifetime >= mascotLevel2) return 2;
    return 1;
  }

  String get mascotDailyEmoji {
    final percent = _stats.percent;
    if (percent >= 1.0) return '🎉';
    if (percent >= 0.75) return '🏃';
    if (percent >= 0.50) return '🚶';
    if (percent >= 0.10) return '🤔';
    return '😴';
  }

  String get mascotLevelEmoji {
    switch (mascotLevel) {
      case 6:
        return '🦁';
      case 5:
        return '🦊';
      case 4:
        return '🐕';
      case 3:
        return '🐾';
      case 2:
        return '🐣';
      default:
        return '😴';
    }
  }

  // ─── Initialization ───────────────────────────────────────────────

  Future<void> initialize() async {
    await _pedometerService.initialize();

    _pedometerService.statsNotifier.addListener(_onStatsUpdated);

    _stats = _pedometerService.statsNotifier.value;
    _refreshWeeklyData();

    if (_repository.getRemindersEnabled()) {
      _reminderService.enable();
    }

    _checkAchievements();
    notifyListeners();
  }

  void _onStatsUpdated() {
    _stats = _pedometerService.statsNotifier.value;
    _refreshWeeklyData();
    _checkAchievements();
    _reminderService.onStepDetected(_stats.currentSteps);
    notifyListeners();
  }

  void _refreshWeeklyData() {
    _weeklyTotal = _repository.getWeeklyTotal();
    _weeklyAverage = _repository.getWeeklyAverage();
  }

  void _checkAchievements() {
    final range = _repository.getStepHistoryForRange(30);
    _maxDailySteps = range.values.fold(0, (max, s) => s > max ? s : max);

    final summary = DailyStatsSummary(
      maxDailySteps: _maxDailySteps,
      currentStreak: _stats.streak,
      totalLifetimeSteps: _stats.totalLifetimeSteps,
    );

    _newlyUnlockedAchievements =
        _achievementService.checkAndUnlock(summary);
  }

  void clearNewAchievements() {
    _newlyUnlockedAchievements = [];
    notifyListeners();
  }

  void clearGoalReached() {
    _pedometerService.clearGoalReached();
  }

  // ─── Goal ─────────────────────────────────────────────────────────

  void updateGoal(int newGoal) {
    _repository.setDailyGoal(newGoal);
    _stats = _stats.copyWith(dailyGoal: newGoal);
    _refreshWeeklyData();
    notifyListeners();
  }

  int? getSuggestedGoal() {
    final avg = _weeklyAverage;
    if (avg <= 0) return null;
    return ((avg * 1.1) / 500).round() * 500;
  }

  // ─── Reminder Toggle ──────────────────────────────────────────────

  void setRemindersEnabled(bool enabled) {
    _repository.setRemindersEnabled(enabled);
    if (enabled) {
      _reminderService.enable();
    } else {
      _reminderService.disable();
    }
    notifyListeners();
  }

  bool get remindersEnabled => _repository.getRemindersEnabled();

  // ─── Workout ──────────────────────────────────────────────────────

  bool _isWorkoutActive = false;
  DateTime? _workoutStartTime;
  int _workoutStartSteps = 0;

  bool get isWorkoutActive => _isWorkoutActive;
  DateTime? get workoutStartTime => _workoutStartTime;
  int get workoutSteps => _isWorkoutActive
      ? _stats.currentSteps - _workoutStartSteps
      : 0;

  Duration? get workoutDuration =>
      _isWorkoutActive && _workoutStartTime != null
          ? DateTime.now().difference(_workoutStartTime!)
          : null;

  void startWorkout() {
    _isWorkoutActive = true;
    _workoutStartTime = DateTime.now();
    _workoutStartSteps = _stats.currentSteps;
    notifyListeners();
  }

  void endWorkout() {
    _isWorkoutActive = false;
    _workoutStartTime = null;
    _workoutStartSteps = 0;
    notifyListeners();
  }

  // ─── CSV Export ───────────────────────────────────────────────────

  Future<String> exportCsv({int days = 30}) async {
    final csvService = CsvExportService(_repository);
    return csvService.exportToCsv(days: days);
  }

  // ─── History Data ─────────────────────────────────────────────────

  Map<String, int> getHistoryForRange(int days) {
    return _repository.getStepHistoryForRange(days);
  }

  Map<String, int> getHistoryForYear(int year) {
    final result = <String, int>{};
    for (int month = 1; month <= 12; month++) {
      int total = 0;
      final daysInMonth = DateTime(year, month + 1, 0).day;
      for (int day = 1; day <= daysInMonth; day++) {
        total += _repository.getStepsForDate(DateTime(year, month, day));
      }
      result['$month'] = total;
    }
    return result;
  }

  // ─── Lifecycle ────────────────────────────────────────────────────

  @override
  void dispose() {
    _pedometerService.statsNotifier.removeListener(_onStatsUpdated);
    _pedometerService.dispose();
    _reminderService.dispose();
    super.dispose();
  }
}
