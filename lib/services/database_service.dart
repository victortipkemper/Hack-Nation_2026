import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/shop_data_hive.dart';
import '../UI/small_card/small_card.dart';

class DatabaseService {
  static const String _shopsBoxName = 'shops';
  late Box<ShopDataHive> _shopsBox;

  /// Initialize the Hive database
  Future<void> initialize() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocDir.path);
    
    // Register adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ShopDataHiveAdapter());
    }

    // Open the box
    _shopsBox = await Hive.openBox<ShopDataHive>(_shopsBoxName);
  }

  /// Add or update a shop in the database
  Future<void> addOrUpdateShop(ShopData shopData) async {
    final hiveShop = ShopDataHive(
      id: shopData.id,
      name: shopData.name,
      description: shopData.description,
      locationLat: shopData.location.$1,
      locationLng: shopData.location.$2,
      openingTime: shopData.openingTime,
      closingTime: shopData.closingTime,
      couponAmount: shopData.couponAmount,
      tags: shopData.tags,
      imageUrl: shopData.imageUrl,
      rank: shopData.rank,
      category: shopData.category,
      payoneZScore: shopData.payone_z_score,
    );

    await _shopsBox.put(shopData.id, hiveShop);
  }

  /// Add multiple shops to the database
  Future<void> addMultipleShops(List<ShopData> shops) async {
    for (var shop in shops) {
      await addOrUpdateShop(shop);
    }
  }

  /// Get a shop by its unique ID
  ShopData? getShopById(String id) {
    final hiveShop = _shopsBox.get(id);
    if (hiveShop == null) return null;

    return ShopData(
      id: hiveShop.id,
      name: hiveShop.name,
      description: hiveShop.description,
      location: (hiveShop.locationLat, hiveShop.locationLng),
      openingTime: hiveShop.openingTime,
      closingTime: hiveShop.closingTime,
      couponAmount: hiveShop.couponAmount,
      tags: hiveShop.tags,
      imageUrl: hiveShop.imageUrl,
      rank: hiveShop.rank,
      category: hiveShop.category,
      payone_z_score: hiveShop.payoneZScore,
    );
  }

  /// Get all shops from the database
  List<ShopData> getAllShops() {
    return _shopsBox.values
        .map((hiveShop) => ShopData(
              id: hiveShop.id,
              name: hiveShop.name,
              description: hiveShop.description,
              location: (hiveShop.locationLat, hiveShop.locationLng),
              openingTime: hiveShop.openingTime,
              closingTime: hiveShop.closingTime,
              couponAmount: hiveShop.couponAmount,
              tags: hiveShop.tags,
              imageUrl: hiveShop.imageUrl,
              rank: hiveShop.rank,
              category: hiveShop.category,
              payone_z_score: hiveShop.payoneZScore,
            ))
        .toList();
  }

  /// Delete a shop by its ID
  Future<void> deleteShop(String id) async {
    await _shopsBox.delete(id);
  }

  /// Clear all shops from the database
  Future<void> clearAllShops() async {
    await _shopsBox.clear();
  }

  /// Get the total number of shops in the database
  int getShopCount() {
    return _shopsBox.length;
  }

  /// Close the database
  Future<void> close() async {
    await _shopsBox.close();
  }
}
