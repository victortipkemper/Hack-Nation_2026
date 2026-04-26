import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import '../small_card/small_card.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({super.key});

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mockShop = ShopData(
      id: "shop_vibe_77",
      name: "Neon Espresso & Co.",
      description:
          "A futuristic coffee lounge featuring cyber-industrial aesthetics, premium roasts, and high-speed fiber for power users.",
      couponAmount: 15,
      location: (48.135122, 11.581981),
      openingTime: DateTime(2026, 4, 26, 08, 00),
      closingTime: DateTime(2026, 4, 26, 23, 30),
      tags: ["Premium", "Fast WiFi", "Quiet Zone", "Late Night"],
      imageUrl:
          "https://baristaroyal.de/cdn/shop/articles/2022-04-28-Cafe_Guide_Munchen-unsplash-218506.jpg?v=1719300386&width=1500",
      rank: 1,
      category: "Food & Beverage",
      payone_z_score: 2.84,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('HackNation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              final box = Hive.box('settings');
              await box.delete('userType');
              Get.offAllNamed('/startup');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Text(
              "Current recommendations",
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            SmallCard(
              shopData: mockShop,
              onClick: (ShopData value) {},
            ),
          ],
        ),
      ),
    );
  }
}
