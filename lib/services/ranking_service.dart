import 'dart:math';
import '../models/shop.dart';

class RankingService {
  /// Calculates ranking scores for a list of shops based on user parameters
  /// and returns the shop with the highest score as the referral.i
  Shop? getTopReferral({
    required DateTime time,
    required double rain,
    required double temperature,
    required List<double> payone_abnormality_in_500_m,
    required double speed,
    required bool oepnv,
    required (double, double) location,
    required List<Shop> shops,
  }) {
    if (shops.isEmpty) return null;

    Shop? bestShop;
    double highestScore = double.negativeInfinity;

    for (var shop in shops) {
      double score = _calculateShopScore(
        shop: shop,
        time: time,
        rain: rain,
        temperature: temperature,
        userLocation: location,
      );

      if (score > highestScore) {
        highestScore = score;
        bestShop = shop;
      }
    }

    return bestShop;
  }

  /// Calculates a single score for a given shop based on context
  double _calculateShopScore({
    required Shop shop,
    required DateTime time,
    required double rain,
    required double temperature,
    required (double, double) userLocation,
  }) {

    if shop.openingTime.hour > time.hour || shop.closingTime.hour < time.hour {
      return 0.0;
    }
    double distanceScore = 0.0;

    double weatherScore = 0.0;


    double payoneScore = shop.payone_variance;





    return distanceScore + weatherScore + payoneScore;
  }

  /// Simple Euclidean distance
  double _calculateDistance((double, double) loc1, (double, double) loc2) {
    final dx = loc1.$1 - loc2.$1;
    final dy = loc1.$2 - loc2.$2;
    return sqrt(dx * dx + dy * dy);
  }
}
