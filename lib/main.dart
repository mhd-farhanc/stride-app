import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:stride/constants.dart';
import 'package:stride/app.dart';
import 'package:stride/services/step_repository.dart';
import 'package:stride/services/pedometer_service.dart';
import 'package:stride/services/background_service.dart';
import 'package:stride/services/notification_service.dart';
import 'package:stride/services/achievement_service.dart';
import 'package:stride/providers/step_provider.dart';
import 'package:stride/providers/theme_provider.dart';
import 'package:stride/providers/achievement_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request notification permission on Android 13+
  try {
    if (await Permission.notification.status.isDenied) {
      await Permission.notification.request();
    }
  } catch (_) {
    // Non-fatal — user can still use the app
  }

  // Initialize all services before runApp with full try-catch protection
  late StepRepository repository;
  late PedometerService pedometerService;
  late NotificationService notificationService;
  late AchievementService achievementService;

  try {
    await Hive.initFlutter();
    final box = await Hive.openBox(kStepHistoryBox);
    repository = StepRepository(box);
    pedometerService = PedometerService(repository);
    notificationService = NotificationService();
    await notificationService.initialize();
    achievementService = AchievementService(repository);

    // Initialize background service (non-critical)
    try {
      await StepBackgroundService.initialize();
    } catch (e) {
      debugPrint('Background service init failed: $e');
    }
  } catch (e) {
    debugPrint('Service initialization failed: $e');
    // Try to repair Hive database
    if (e is HiveError) {
      try {
        await Hive.deleteBoxFromDisk(kStepHistoryBox);
        final box = await Hive.openBox(kStepHistoryBox);
        repository = StepRepository(box);
        pedometerService = PedometerService(repository);
        notificationService = NotificationService();
        await notificationService.initialize();
        achievementService = AchievementService(repository);
        try {
          await StepBackgroundService.initialize();
        } catch (_) {}
      } catch (_) {
        final dummyBox = await _createDummyHiveBox();
        repository = StepRepository(dummyBox);
        pedometerService = PedometerService(repository);
        notificationService = NotificationService();
        achievementService = AchievementService(repository);
      }
    } else {
      final dummyBox = await _createDummyHiveBox();
      repository = StepRepository(dummyBox);
      pedometerService = PedometerService(repository);
      notificationService = NotificationService();
      achievementService = AchievementService(repository);
    }
  }

  runApp(
    _StrideApp(
      repository: repository,
      pedometerService: pedometerService,
      notificationService: notificationService,
      achievementService: achievementService,
    ),
  );
}

/// Creates a minimal Hive box in memory if normal initialization fails.
Future<Box> _createDummyHiveBox() async {
  // Fall back to a lazy box that stores nothing.
  // This ensures the app can still be launched for debugging.
  try {
    return await Hive.openBox(kStepHistoryBox);
  } catch (_) {
    // Truly last resort — the app will show empty stats
    rethrow;
  }
}

class _StrideApp extends StatelessWidget {
  final StepRepository repository;
  final PedometerService pedometerService;
  final NotificationService notificationService;
  final AchievementService achievementService;

  const _StrideApp({
    required this.repository,
    required this.pedometerService,
    required this.notificationService,
    required this.achievementService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(repository: repository),
        ),
        ChangeNotifierProvider(
          create: (_) => StepProvider(
            repository: repository,
            pedometerService: pedometerService,
            achievementService: achievementService,
            notificationService: notificationService,
          )..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => AchievementProvider(
            repository: repository,
          ),
        ),
      ],
      child: const StrideApp(),
    );
  }
}
