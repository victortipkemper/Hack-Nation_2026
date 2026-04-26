import 'package:hive_ce/hive.dart';

part 'shop_data_hive.g.dart';

@HiveType(typeId: 0)
class ShopDataHive {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double locationLat;

  @HiveField(4)
  final double locationLng;

  @HiveField(5)
  final DateTime openingTime;

  @HiveField(6)
  final DateTime closingTime;

  @HiveField(7)
  final double couponAmount;

  @HiveField(8)
  final List<String> tags;

  @HiveField(9)
  final String? imageUrl;

  @HiveField(10)
  final int? rank;

  @HiveField(11)
  final String category;

  @HiveField(12)
  final double payoneZScore;

  ShopDataHive({
    required this.id,
    required this.name,
    required this.description,
    required this.locationLat,
    required this.locationLng,
    required this.openingTime,
    required this.closingTime,
    required this.couponAmount,
    required this.tags,
    this.imageUrl,
    this.rank,
    required this.category,
    required this.payoneZScore,
  });
}
