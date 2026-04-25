import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/detail_page.dart';


class ShopData {
  final String id;
  final String name;
  final String description;
  final String couponAmount;
  final List<String> tags;
  final String? imageUrl;
  final int? rank;

  const ShopData({
    required this.id,
    required this.name,
    required this.description,
    required this.couponAmount,
    required this.tags,
    this.imageUrl,
    this.rank,
  });
}

class SmallCard extends StatelessWidget {
  final ShopData shopData;
  final ValueChanged<ShopData>? onClick;

  const SmallCard({
    super.key,
    required this.shopData,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AspectRatio(
      aspectRatio: 4 / 1,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: InkWell(
          onTap: () {
            if (onClick != null) {
              onClick!(shopData);
            }
            Get.to(() => const DetailPage());
          },
          child: Row(
            children: [
              // Image Section
              if (shopData.imageUrl != null)
                AspectRatio(
                  aspectRatio: 1, // 1:1 square image
                  child: Image.network(
                    shopData.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.store, color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),

              // Details Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0), // Reduced vertical padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute evenly, replacing Spacer
                    children: [
                      Row(
                        children: [
                          if (shopData.rank != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: Text(
                                '#${shopData.rank}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: colorScheme.primary,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              shopData.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                height: 1.1, // Tighter line height
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Flexible( // Allows description to shrink or be hidden if space is too tight
                        child: Text(
                          shopData.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Tags
                      if (shopData.tags.isNotEmpty)
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(), // Prevent scrolling conflict
                            child: Row(
                              children: shopData.tags.map((tag) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tag,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSecondaryContainer,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Coupon Amount Section
              Container(
                width: 55, // Smaller fixed width for the coupon section
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "${shopData.couponAmount}%",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'OFF',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
