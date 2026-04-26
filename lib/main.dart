import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'UI/small_card/small_card.dart';
import 'UI/user/user_main.dart';
import 'UI/merchant/merchant_main.dart';
import 'UI/screens/startup_screen.dart';
import 'services/notification_service.dart';
import 'widget/main_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Update home screen widget
  ShopHomeWidget.update(
    shopData: widgetShop,
    weatherTemp: '22°C',
    weatherCategory: 'sunny',
    travelTime: '12 min',
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
      ],
    );
  }
}
