import 'dart:math';

class InterruptionService {
  /// Calculates if there is an abnormality by running a 1-layer linear model
  /// and mapping the predicted score (0 to 1) to a boolean.
  bool isAbnormality({
    required DateTime time,
    required double rain,
    required double temperature, // Fixed typo "tmeperature"
    required List<double> payone_abnormality_in_500_m,
    required double speed,
    required bool oepnv,
    required (double, double) location,
  }) {
    // 1. Normalize values to the same feature space (0.0 to 1.0)
    // Note: These min/max bounds are examples and should be tuned.
    double normRain = (rain.clamp(0.0, 50.0)) / 50.0;
    double normTemp = (temperature.clamp(-20.0, 40.0) + 20.0) / 60.0;
    double normSpeed = (speed.clamp(0.0, 130.0)) / 130.0;
    double normOepnv = oepnv ? 1.0 : 0.0;
    
    // Average payone abnormality as a feature
    double avgPayone = payone_abnormality_in_500_m.isEmpty 
        ? 0.0 
        : payone_abnormality_in_500_m.reduce((a, b) => a + b) / payone_abnormality_in_500_m.length;

    // Time feature (e.g., hour of day normalized 0-1)
    double normTime = time.hour / 24.0;

    // 2. One layer linear model (Weights and bias)
    // W = [w_rain, w_temp, w_speed, w_oepnv, w_payone, w_time]
    const weights = [0.1, -0.2, 0.3, 0.1, 0.8, -0.1];
    const bias = -0.5;

    double linearCombination = 
        (normRain * weights[0]) +
        (normTemp * weights[1]) +
        (normSpeed * weights[2]) +
        (normOepnv * weights[3]) +
        (avgPayone * weights[4]) +
        (normTime * weights[5]) + 
        bias;

    // 3. Sigmoid function to get a predicted score between 0 and 1
    double score = 1.0 / (1.0 + exp(-linearCombination));

    // 4. Map to True/False (using 0.5 as threshold)
    return score > 0.5;
  }
}
