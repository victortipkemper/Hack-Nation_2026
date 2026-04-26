import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'UI/small_card/small_card.dart';
import 'UI/user/user_main.dart';
import 'UI/merchant/merchant_main.dart';
import 'UI/qr_code_validation/validation.dart';
import 'UI/screens/startup_screen.dart';
import 'services/notification_service.dart';
import 'services/create_message.dart';
import 'widget/main_widget.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    final notificationService = NotificationService();
    await notificationService.initialize(isBackground: true);

    await notificationService.showGeneratedNotification(
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
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Mock shop data for the home screen widget
  final widgetShop = ShopData(
    id: "shop_vibe_77",
    name: "Neon Espresso & Co.",
    description: "A futuristic coffee lounge featuring cyber-industrial aesthetics, premium roasts, and high-speed fiber for power users.",
    couponAmount: 15,
    location: (48.135122, 11.581981),
    openingTime: DateTime(2026, 4, 26, 08, 00),
    closingTime: DateTime(2026, 4, 26, 23, 30),
    tags: ["Premium", "Fast WiFi", "Quiet Zone", "Late Night"],
    imageUrl: "https://baristaroyal.de/cdn/shop/articles/2022-04-28-Cafe_Guide_Munchen-unsplash-218506.jpg?v=1719300386&width=1500",
    rank: 1,
    category: "Food & Beverage",
    payone_z_score: 2.84,
  );

  // Generate widget text using the message creation service
  final messageService = MessageCreationService();
  String msg = await messageService.generateWidgetText(
    time: DateTime.now(),
    rain: 0.0,
    temperature: 22.0,
    recommendedShop: widgetShop,
  );

  // Update home screen widget
  ShopHomeWidget.update(
    shopData: widgetShop,
    weatherTemp: '22°C',
    weatherCategory: 'sunny',
    travelTime: '12 min',
    msg: msg,
  );

  // Determine initial route based on userType in Hive
  final box = Hive.box('settings');
  final userType = box.get('userType'); // null if not set, 0 = user, 1 = seller

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

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HackNation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/startup', page: () => const StartupScreen()),
        GetPage(name: '/user', page: () => const UserMainPage()),
        GetPage(name: '/merchant', page: () => const MerchantMainPage()),
        GetPage(name: '/validation', page: () => const ValidationScreen()),
      ],
    );
  }
}
