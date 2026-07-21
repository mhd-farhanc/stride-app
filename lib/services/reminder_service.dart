import 'dart:async';
import 'package:flutter/services.dart';

import 'package:stride/services/notification_service.dart';
import 'package:stride/constants.dart';

/// Tracks inactivity and sends reminders if no steps detected for a period.
class ReminderService {
  final NotificationService _notificationService;
  Timer? _inactivityTimer;
  bool _enabled = false;
  int _notificationId = 0;

  ReminderService(this._notificationService);

  bool get enabled => _enabled;

  void enable() {
    _enabled = true;
    _resetTimer();
  }

  void disable() {
    _enabled = false;
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  void onStepDetected(int currentSteps) {
    if (_enabled) {
      _resetTimer();
    }
  }

  void _resetTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(
      const Duration(minutes: inactivityReminderMinutes),
      _onInactivity,
    );
  }

  Future<void> _onInactivity() async {
    if (!_enabled) return;

    _notificationId++;
    await HapticFeedback.lightImpact();
    await _notificationService.showNotification(
      id: _notificationId,
      title: 'Time to move! 🚶',
      body: 'You haven\'t moved in $inactivityReminderMinutes minutes. '
          'Take a quick walk!',
    );
  }

  void dispose() {
    _inactivityTimer?.cancel();
  }
}
