import '../UI/small_card/small_card.dart';

/// Central service for fetching shop data.
/// Replace this with a real API call in production.
class ShopService {
  /// Returns a list of recommended shops.
  static List<ShopData> fetchShops() {
    return [
      ShopData(
        id: "shop_vibe_77",
        name: "Gym Cook",
        description:
            "Eat like an athlete, cook like a pro. We strip away the fluff to deliver high-protein, macro-balanced meals designed for performance. No guesswork, no wasted calories—just pure fuel for the gains you’ve earned.",
        couponAmount: 10,
        location: (48.1480123, 11.55445),
        openingTime: DateTime(2026, 4, 26, 08, 00),
        closingTime: DateTime(2026, 4, 26, 23, 30),
        tags: ["Premium", "Fast WiFi", "Quiet Zone", "Late Night"],
        imageUrl:
            "https://dtwaeonhht2im.cloudfront.net/d4273a63f7008b4d509ecd82fd71b7ae.jpg",
        rank: 1,
        category: "Food & Beverage",
        payone_z_score: 2.84,
      ),
    ];
  }

  /// Returns a shop by id, or null if not found.
  static ShopData? findById(String id) {
    final shops = fetchShops();
    try {
      return shops.firstWhere((s) => s.id == id);
    } catch (_) {
      return shops.isNotEmpty ? shops.first : null;
    }
  }
}
