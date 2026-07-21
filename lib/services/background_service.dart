import 'package:flutter_background_service/flutter_background_service.dart';

/// Foreground service to keep the Dart isolate alive for pedometer tracking
/// even when the app is in the background.
class StepBackgroundService {
  static const int _notificationId = 888;

  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'background_service',
        initialNotificationTitle: 'Stride',
        initialNotificationContent: 'Counting your steps...',
        foregroundServiceNotificationId: _notificationId,
        foregroundServiceTypes: const [AndroidForegroundType.health],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) {
    service.on('stop').listen((event) {
      service.stopSelf();
    });
  }

  /// iOS background callback (runs periodically, ~15 min intervals).
  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    return true;
  }

  static Future<void> stop() async {
    final service = FlutterBackgroundService();
    service.invoke('stop');
  }
}
