import 'dart:math';
import '../UI/small_card/small_card.dart';
import 'package:geolocator/geolocator.dart';

class RankingService {
  /// Calculates ranking scores for a list of shops based on user parameters
  /// and returns the shop with the highest score as the referral.i
  ShopData? getTopReferral({
    required DateTime time,
    required double rain,
    required double temperature,
    required List<double> payone_abnormality_in_500_m,
    required double speed,
    required bool oepnv,
    required (double, double) location,
    required List<ShopData> shops,
  })  {
    if (shops.isEmpty) return null;

    ShopData? bestShop;
    double highestScore = -1.0;

    for (var shop in shops) {
      double currentScore = 0.0;

      double dist = Geolocator.distanceBetween(location.$1, location.$2, shop.location.$1, shop.location.$2);

      double distanceScore = (1.0 - (dist / 1000)).clamp(0.0, 1.0);
      currentScore += distanceScore * 0.40; // 40% weight

      if (rain > 0.5) {
        currentScore += 0.20; 
      }

      currentScore -= shop.payone_z_score * 0.30; // 30% weight

      // Operating hours score - bonus if shop is open
      if (time.hour < shop.openingTime.hour || time.hour >= shop.closingTime.hour) {
        continue; // Skip shops that are currently closed
      } 
        // Coupon score - bonus based on coupon amount
      double couponScore = shop.couponAmount;
      currentScore += couponScore; // 5% weight for coupon

      // Update Top Shop
      if (currentScore > highestScore) {
        highestScore = currentScore;
        bestShop = shop;
      }
    }

    return bestShop;
  }



}