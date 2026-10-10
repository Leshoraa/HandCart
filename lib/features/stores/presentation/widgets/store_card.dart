import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/store_model.dart';

class StoreCard extends StatelessWidget {
  final Store store;
  final int itemCount;
  final double totalPrice;
  final VoidCallback onTap;

  const StoreCard({
    super.key,
    required this.store,
    required this.itemCount,
    required this.totalPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.0),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Photo / Icon Banner
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(19.0),
                    ),
                    child: Container(
                      height: 114.0,
                      width: double.infinity,
                      color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                      child: store.imageUrl != null
                          ? Image.network(
                              store.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildFallbackBanner(colorScheme),
                            )
                          : _buildFallbackBanner(colorScheme),
                    ),
                  ),

                  // Frosted Glass Category Tag
                  Positioned(
                    top: 8.0,
                    left: 8.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.5,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.75)
                            : Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        store.category,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF191C1E),
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Store Information & Planned Metrics
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store Name (Up to 2 lines for clear readability)
                      Text(
                        store.name,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Metrics: Item Count & Total Planned Expense
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  itemCount > 0
                                      ? Icons.shopping_bag_rounded
                                      : Icons.shopping_bag_outlined,
                                  size: 13.0,
                                  color: itemCount > 0
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 4.0),
                                Flexible(
                                  child: Text(
                                    '$itemCount ${itemCount == 1 ? "item" : "items"}',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: itemCount > 0
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: itemCount > 0
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            CurrencyFormatter.format(totalPrice),
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: itemCount > 0
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackBanner(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.5),
            colorScheme.surfaceContainerHigh,
          ],
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.85),
            shape: BoxShape.circle,
          ),
          child: Icon(
            store.icon,
            size: 26,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
