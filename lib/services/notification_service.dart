import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  Timer? _notificationTimer;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    // Request notification permission on Android 13+
    await _requestNotificationPermission();

    // Initialize for Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize for iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isDenied) {
      // Permission denied
      print('Notification permission denied');
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, open app settings
      openAppSettings();
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Channel for test notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      details,
    );
  }

  void startTestNotifications() {
    // Cancel any existing timer
    _notificationTimer?.cancel();

    // Publish first notification immediately
    showNotification(
      title: 'Test Notification',
      body: 'test notification',
      id: 1,
    );

    // Then publish every 30 seconds
    _notificationTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        showNotification(
          title: 'Test Notification',
          body: 'test notification',
          id: timer.tick,
        );
      },
    );
  }

  void stopTestNotifications() {
    _notificationTimer?.cancel();
    _notificationTimer = null;
  }

  Future<void> dispose() async {
    stopTestNotifications();
  }
}
