import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:stride/constants.dart';
import 'package:stride/services/step_repository.dart';
import 'package:stride/models/daily_stats.dart';

/// Manages the pedometer stream lifecycle, permissions, and error recovery.
/// Emits [DailyStats] snapshots to listeners.
class PedometerService {
  final StepRepository _repository;
  StreamSubscription<StepCount>? _subscription;
  int _retryCount = 0;
  Timer? _hiveDebounceTimer;
  int _unwrittenStepDeltas = 0;
  bool _goalJustReached = false;

  final ValueNotifier<DailyStats> statsNotifier =
      ValueNotifier<DailyStats>(DailyStats.empty());

  PedometerService(this._repository);

  bool get goalJustReached => _goalJustReached;
  void clearGoalReached() => _goalJustReached = false;

  // ─── Init ─────────────────────────────────────────────────────────

  Future<void> initialize() async {
    try {
      _loadPersistedStats();
      await _initPedometer();
    } catch (e) {
      debugPrint('PedometerService init error: $e');
    }
  }

  void _loadPersistedStats() {
    final todaySteps = _repository.getTodaySteps();
    final goal = _repository.getDailyGoal();
    final kcal = todaySteps * caloriesPerStep;
    final distanceKm = (todaySteps * strideLengthMeters) / 1000;
    final pb = _repository.getPersonalBest();
    final streak = _repository.calculateStreak(goal);
    final lifetime = _repository.getTotalLifetimeSteps();

    statsNotifier.value = DailyStats(
      currentSteps: todaySteps,
      dailyGoal: goal,
      percent: goal > 0 ? (todaySteps / goal).clamp(0.0, 1.0) : 0.0,
      streak: streak,
      personalBestSteps: pb,
      kcal: kcal,
      distanceKm: distanceKm,
      totalLifetimeSteps: lifetime,
      goalCelebratedToday: _repository.getCelebratedToday(),
    );
  }

  // ─── Permissions ──────────────────────────────────────────────────

  Future<bool> _requestPermission() async {
    var status = await Permission.activityRecognition.status;
    if (status.isDenied) {
      status = await Permission.activityRecognition.request();
    }
    return status.isGranted;
  }

  // ─── Pedometer Stream ─────────────────────────────────────────────

  Future<void> _initPedometer() async {
    final granted = await _requestPermission();
    if (!granted) {
      _emitError('Activity recognition permission not granted');
      return;
    }

    _subscription?.cancel();
    try {
      _subscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
        cancelOnError: false,
      );
    } catch (e) {
      _onStepCountError(e);
    }
  }

  void _onStepCount(StepCount event) {
    try {
      _processStepCount(event);
    } catch (e) {
      debugPrint('Step processing error: $e');
    }
  }

  void _processStepCount(StepCount event) {
    final now = DateTime.now();
    final todayKey = _formatDate(now);
    final lastRunDate = _repository.getLastRunDate();
    final lastSensorTotal = _repository.getLastSensorTotal();

    int todayCalculatedSteps = _repository.getTodaySteps();
    int newSteps = 0;

    if (todayKey != lastRunDate) {
      todayCalculatedSteps = 0;
      newSteps = 0;
      _repository.setLastSensorTotal(0);
      _repository.setCelebratedToday(false);
    } else {
      if (event.steps < lastSensorTotal && lastSensorTotal > 0) {
        newSteps = event.steps;
      } else {
        newSteps = event.steps - lastSensorTotal;
      }
    }

    if (newSteps < 0) newSteps = 0;

    final totalForDay = todayCalculatedSteps + newSteps;
    final goal = _repository.getDailyGoal();

    if (!_repository.getCelebratedToday() && totalForDay >= goal) {
      _goalJustReached = true;
      _repository.setCelebratedToday(true);
    }

    final pb = _repository.getPersonalBest();
    if (totalForDay > pb) {
      _repository.setPersonalBest(totalForDay);
    }

    final oldLifetime = _repository.getTotalLifetimeSteps();
    final newLifetime = oldLifetime + newSteps;
    _repository.setTotalLifetimeSteps(newLifetime);

    _unwrittenStepDeltas += newSteps;
    _scheduleHiveFlush(todayKey, totalForDay, event.steps);

    final kcal = totalForDay * caloriesPerStep;
    final distanceKm = (totalForDay * strideLengthMeters) / 1000;
    final streak = _repository.calculateStreak(goal);

    statsNotifier.value = DailyStats(
      currentSteps: totalForDay,
      dailyGoal: goal,
      percent: goal > 0 ? (totalForDay / goal).clamp(0.0, 1.0) : 0.0,
      streak: streak,
      personalBestSteps: _repository.getPersonalBest(),
      kcal: kcal,
      distanceKm: distanceKm,
      totalLifetimeSteps: newLifetime,
      goalCelebratedToday: _repository.getCelebratedToday(),
    );
  }

  void _scheduleHiveFlush(String todayKey, int totalForDay, int sensorTotal) {
    _hiveDebounceTimer?.cancel();
    if (_unwrittenStepDeltas >= 10) {
      _flushToHive(todayKey, totalForDay, sensorTotal);
    } else {
      _hiveDebounceTimer = Timer(
        const Duration(milliseconds: 3000),
        () => _flushToHive(todayKey, totalForDay, sensorTotal),
      );
    }
  }

  void _flushToHive(String todayKey, int totalForDay, int sensorTotal) {
    try {
      _repository.saveStepsForDate(
        DateTime.now(),
        totalForDay,
      );
      _repository.setLastRunDate(todayKey);
      _repository.setLastSensorTotal(sensorTotal);
      _unwrittenStepDeltas = 0;
    } catch (e) {
      debugPrint('Hive flush error: $e');
    }
  }

  void _onStepCountError(Object error) {
    debugPrint('Pedometer error: $error');
    if (_retryCount < sensorErrorRetryCount) {
      _retryCount++;
      Timer(
        const Duration(milliseconds: sensorErrorRetryDelayMs),
        () {
          _retryCount = 0;
          _initPedometer();
        },
      );
    } else {
      _emitError('Pedometer unavailable after $_retryCount retries');
      Timer(
        const Duration(minutes: 5),
        () {
          _retryCount = 0;
          _initPedometer();
        },
      );
    }
  }

  void _emitError(String message) {
    statsNotifier.value = DailyStats.empty();
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ─── Lifecycle ────────────────────────────────────────────────────

  void dispose() {
    _subscription?.cancel();
    _hiveDebounceTimer?.cancel();
    statsNotifier.dispose();
  }
}
