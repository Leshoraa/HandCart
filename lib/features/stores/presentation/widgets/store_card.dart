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
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                      height: 108.0,
                      width: double.infinity,
                      color:
                          colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
                      child: store.imageUrl != null
                          ? Image.network(
                              store.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: loadingProgress
                                                .expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress
                                                .expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                child: Icon(
                                  store.icon,
                                  size: 38,
                                  color: colorScheme.primary,
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                store.icon,
                                size: 38,
                                color: colorScheme.primary,
                              ),
                            ),
                    ),
                  ),

                  // Category Tag Badge
                  Positioned(
                    top: 8.0,
                    left: 8.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusFull),
                      ),
                      child: Text(
                        store.category,
                        style: const TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Store Information & Planned Metrics
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store Name
                      Text(
                        store.name,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 2.0),

                      // Store Description
                      Text(
                        store.description,
                        style: TextStyle(
                          fontSize: 11.0,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.85),
                        ),
                        maxLines: 1,
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
                                  Icons.shopping_basket_outlined,
                                  size: 13.0,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 3.0),
                                Flexible(
                                  child: Text(
                                    '$itemCount ${itemCount == 1 ? "item" : "items"}',
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
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
                              fontSize: 13.0,
                              fontWeight: FontWeight.w900,
                              color: itemCount > 0
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
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
}
