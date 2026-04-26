import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'UI/user/user_main.dart';
import 'UI/merchant/merchant_main.dart';
import 'UI/qr_code_validation/validation.dart';
import 'UI/screens/startup_screen.dart';
import 'UI/screens/detail_page.dart';
import 'services/notification_service.dart';
import 'services/shop_service.dart';
import 'widget/main_widget.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    final notificationService = NotificationService();
    await notificationService.initialize(isBackground: true);

    final shops = ShopService.fetchShops();
    await notificationService.showGeneratedNotification(
      time: DateTime.now(),
      rain: 0.0,
      temperature: 20.0,
      recommendedShop: shops.first,
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  Workmanager().registerPeriodicTask(
    "background_notification_task",
    "simplePeriodicTask",
    frequency: const Duration(minutes: 15),
  );

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('settings');

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  notificationService.startTestNotifications();

  // Update home screen widget with first shop
  final shops = ShopService.fetchShops();
  if (shops.isNotEmpty) {
    ShopHomeWidget.update(
      shopData: shops.first,
      weatherTemp: '22°C',
      weatherCategory: 'sunny',
      travelTime: '12 min',
    );
  }

  // Determine initial route based on userType in Hive
  final box = Hive.box('settings');
  final userType = box.get('userType');

  String initialRoute;
  if (userType == null) {
    initialRoute = '/startup';
  } else if (userType == 1) {
    initialRoute = '/merchant';
  } else {
    initialRoute = '/user';
  }

  runApp(MyApp(initialRoute: initialRoute));
}

/// Handles the URI received from a home widget click.
void _handleWidgetUri(Uri? uri) {
  if (uri == null) return;
  // URI format: hacknation://shop/{shopId}
  if (uri.host == 'shop') {
    final shopId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    final shop = ShopService.findById(shopId);
    if (shop != null) {
      Get.to(() => DetailPage(shopData: shop));
    }
  }
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Check if app was cold-launched from a widget click
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_handleWidgetUri);

    // Listen for widget clicks while app is already running
    HomeWidget.widgetClicked.listen(_handleWidgetUri);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HackNation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: widget.initialRoute,
      getPages: [
        GetPage(name: '/startup', page: () => const StartupScreen()),
        GetPage(name: '/user', page: () => const UserMainPage()),
        GetPage(name: '/merchant', page: () => const MerchantMainPage()),
        GetPage(name: '/validation', page: () => const ValidationScreen()),
      ],
    );
  }
}
