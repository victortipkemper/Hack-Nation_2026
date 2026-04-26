import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import '../small_card/small_card.dart';
import '../../services/shop_service.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({super.key});

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shops = ShopService.fetchShops();

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
            ...shops.map((shop) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SmallCard(
                shopData: shop,
                onClick: (ShopData value) {},
              ),
            )),
          ],
        ),
      ),
    );
  }
}
