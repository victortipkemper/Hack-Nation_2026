import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'UI/small_card/small_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HackNation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mockShop = ShopData(
      id: "shop_vibe_77",
      name: "Neon Espresso & Co.",
      description: "A futuristic coffee lounge featuring cyber-industrial aesthetics, premium roasts, and high-speed fiber for power users.",
      couponAmount: "15",
      location: (48.135122, 11.581981), // Latitude, Longitude
      openingTime: DateTime(2026, 4, 26, 08, 00),
      closingTime: DateTime(2026, 4, 26, 23, 30),
      tags: ["Premium", "Fast WiFi", "Quiet Zone", "Late Night"],
      imageUrl: "https://baristaroyal.de/cdn/shop/articles/2022-04-28-Cafe_Guide_Munchen-unsplash-218506.jpg?v=1719300386&width=1500",
      rank: 1,
      category: "Food & Beverage",
      payone_z_score: 2.84,
    );
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              SizedBox(height: 40,),
              Text(
                "Current recommendations",
                style: theme.textTheme.titleMedium
              ),
              SizedBox(height: 8,),
              SmallCard(
                shopData: mockShop,
                onClick: (ShopData value) {  },)
            ],

              ),
      )
    );
  }
}
