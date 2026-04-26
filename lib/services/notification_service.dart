import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'create_message.dart';
import '../UI/small_card/small_card.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  late MessageCreationService _messageService;
  Timer? _notificationTimer;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize({bool isBackground = false}) async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    _messageService = MessageCreationService();

    // Request notification permission on Android 13+ only when in foreground
    if (!isBackground) {
      await _requestNotificationPermission();
    }

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

  Future<void> showGeneratedNotification({
    required DateTime time,
    required double rain,
    required double temperature,
    required ShopData recommendedShop,
    int id = 0,
  }) async {
    final generatedMessage = await _messageService.generatePushNotification(
      time: time,
      rain: rain,
      temperature: temperature,
      recommendedShop: recommendedShop,
    );

    await showNotification(
      title: recommendedShop.name,
      body: generatedMessage,
      id: id,
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
        showGeneratedNotification(
          time: DateTime.now(),
          rain: 0.0,
          temperature: 20.0,
          recommendedShop: ShopData(
            id: 'test',
            name: 'Test Shop',
            description: 'Test shop description',
            location: (0.0, 0.0),
            openingTime: DateTime.now(),
            closingTime: DateTime.now(),
            tags: [],
            imageUrl: null,
            category: 'Cafe',
            payone_z_score: 0.0,
            couponAmount: 10.0,
          ),
          id: timer.tick,
        );
      },
    );
  }

  void stopTestNotifications() {
    _notificationTimer?.cancel();
    _notificationTimer = null;
  }

  /// Starts real notifications using actual shop data from main.dart
  /// Publishes first notification immediately, then every 30 seconds
  /// 
  /// [shopData] - The shop data to use for notifications
  /// [temperature] - Current temperature in Celsius (default: 22.0)
  /// [rain] - Rain amount in mm (default: 0.0)
  void startRealNotifications({
    required ShopData shopData,
    double temperature = 22.0,
    double rain = 0.0,
  }) {
    // Cancel any existing timer
    _notificationTimer?.cancel();

    // Publish first notification immediately
    showGeneratedNotification(
      time: DateTime.now(),
      rain: rain,
      temperature: temperature,
      recommendedShop: shopData,
      id: 1,
    );

    // Then publish every 30 seconds
    _notificationTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        showGeneratedNotification(
          time: DateTime.now(),
          rain: rain,
          temperature: temperature,
          recommendedShop: shopData,
          id: timer.tick,
        );
      },
    );
  }

  Future<void> dispose() async {
    stopTestNotifications();
  }
}
