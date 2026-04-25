import 'package:flutter/material.dart';
import '../small_card/small_card.dart';
import '../detail_card/detail_card.dart';

class DetailPage extends StatefulWidget {
  final ShopData shopData;

  const DetailPage({super.key, required this.shopData});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DetailCard(shopData: widget.shopData),
    );
  }
}
