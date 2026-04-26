import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import '../UI/small_card/small_card.dart';

/// Renders a Flutter widget as a PNG and pushes it to the Android home screen widget.
class ShopHomeWidget {
  static const String _androidWidgetName = 'ShopWidgetProvider';
  static const String _imageKey = 'shop_widget_image';

  /// Updates the home screen widget with a rendered image of the shop card.
  static Future<void> update({
    required ShopData shopData,
    String? weatherTemp,
    String? weatherCategory,
    String? travelTime,
    String? msg,
  }) async {
    // Save the shop id so the native side can build the click intent
    await HomeWidget.saveWidgetData<String>('shop_id', shopData.id);

    // Render the Flutter widget to an image file
    await HomeWidget.renderFlutterWidget(
      _ShopWidgetCard(
        shopData: shopData,
        weatherTemp: weatherTemp ?? '--°C',
        weatherCategory: weatherCategory ?? 'sunny',
        travelTime: travelTime ?? '-- min',
        message: msg ?? '',
      ),
      key: _imageKey,
      logicalSize: const Size(380, 200),
    );

    // Trigger native widget refresh
    await HomeWidget.updateWidget(androidName: _androidWidgetName);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// The Flutter widget that gets rendered to a PNG image for the home screen.
// This is never shown in-app — it's purely rendered off-screen.
// ─────────────────────────────────────────────────────────────────────────────
class _ShopWidgetCard extends StatelessWidget {
  final ShopData shopData;
  final String weatherTemp;
  final String weatherCategory;
  final String travelTime;
  final String message;

  const _ShopWidgetCard({
    required this.shopData,
    required this.weatherTemp,
    required this.weatherCategory,
    required this.travelTime,
    required this.message,
  });

  IconData _weatherIcon() {
    switch (weatherCategory.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny_rounded;
      case 'cloudy':
        return Icons.cloud_rounded;
      case 'rainy':
        return Icons.water_drop_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  Color _weatherColor() {
    switch (weatherCategory.toLowerCase()) {
      case 'sunny':
        return const Color(0xFFFFC107);
      case 'cloudy':
        return const Color(0xFFB0BEC5);
      case 'rainy':
        return const Color(0xFF64B5F6);
      default:
        return const Color(0xFFFFC107);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Subtle accent glow
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7C3AED).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: weather + travel
                  Row(
                    children: [
                      Icon(_weatherIcon(), size: 16, color: _weatherColor()),
                      const SizedBox(width: 4),
                      Text(
                        weatherTemp,
                        style: const TextStyle(
                          color: Color(0xAAFFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        weatherCategory[0].toUpperCase() + weatherCategory.substring(1),
                        style: const TextStyle(
                          color: Color(0x88FFFFFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.directions_walk_rounded,
                          size: 14, color: Color(0xAAFFFFFF)),
                      const SizedBox(width: 3),
                      Text(
                        travelTime,
                        style: const TextStyle(
                          color: Color(0xAAFFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Coupon pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${shopData.couponAmount.toStringAsFixed(0)}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    shopData.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    shopData.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xBBFFFFFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Message text from LLM
                  if (message.isNotEmpty)
                    Text(
                      message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xDDFFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Bottom label
                  Text(
                    'Tap to view deal →',
                    style: TextStyle(
                      color: const Color(0xFF7C3AED).withOpacity(0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
