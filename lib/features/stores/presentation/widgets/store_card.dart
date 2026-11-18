import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/store_model.dart';

/// Displays a summary card for a shopping store with its image banner, category,
/// planning metrics, and action options.
class StoreCard extends StatelessWidget {
  final Store store;
  final int itemCount;
  final double totalPrice;
  final VoidCallback onTap;
  final VoidCallback? onPin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const StoreCard({
    super.key,
    required this.store,
    required this.itemCount,
    this.totalPrice = 0.0,
    required this.onTap,
    this.onPin,
    this.onEdit,
    this.onDelete,
  });

  String _formatPrice(num amount) {
    try {
      return CurrencyFormatter.formatNumber(amount);
    } catch (_) {
      if (amount == 0) return '0';
      if (amount % 1 == 0) return amount.toInt().toString();
      return amount.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainer
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          onTap: onTap,
          child: SizedBox(
            height: 246.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 124.0,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (store.imageUrl != null)
                        Image.network(
                          store.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildFallbackIcon(colorScheme),
                        )
                      else
                        _buildFallbackIcon(colorScheme),

                      Positioned(
                        top: 8.0,
                        left: 8.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withValues(alpha: 0.88),
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusFull),
                          ),
                          child: Text(
                            store.category,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 6.0,
                        right: 6.0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (store.isPinned)
                              Container(
                                width: 28.0,
                                height: 28.0,
                                margin: const EdgeInsets.only(right: 4.0),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface
                                      .withValues(alpha: 0.88),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.push_pin_rounded,
                                  size: 15.0,
                                  color: colorScheme.primary,
                                ),
                              ),
                            Container(
                              width: 28.0,
                              height: 28.0,
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.surface.withValues(alpha: 0.88),
                                shape: BoxShape.circle,
                              ),
                              child: PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                iconSize: 18.0,
                                tooltip: 'Store options',
                                icon: Icon(
                                  Icons.more_vert_rounded,
                                  size: 18.0,
                                  color: colorScheme.onSurface,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                elevation: 2,
                                onSelected: (value) {
                                  switch (value) {
                                    case 'pin':
                                      onPin?.call();
                                      break;
                                    case 'edit':
                                      onEdit?.call();
                                      break;
                                    case 'delete':
                                      onDelete?.call();
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem<String>(
                                    value: 'pin',
                                    child: Row(
                                      children: [
                                        Icon(
                                          store.isPinned
                                              ? Icons.push_pin_outlined
                                              : Icons.push_pin_rounded,
                                          size: 18.0,
                                          color: store.isPinned
                                              ? colorScheme.primary
                                              : colorScheme.onSurface,
                                        ),
                                        const SizedBox(width: 10.0),
                                        Text(
                                          store.isPinned
                                              ? 'Unpin Store'
                                              : 'Pin Store',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.edit_outlined,
                                            size: 18.0),
                                        const SizedBox(width: 10.0),
                                        Text(
                                          'Rename / Edit',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline_rounded,
                                          size: 18.0,
                                          color: colorScheme.error,
                                        ),
                                        const SizedBox(width: 10.0),
                                        Text(
                                          'Delete Store',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        if (store.description.isNotEmpty) ...[
                          const SizedBox(height: 3.0),
                          Text(
                            store.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11.5,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        const Spacer(),

                        Row(
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 14.0,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4.0),
                            Expanded(
                              child: Text(
                                itemCount > 0
                                    ? '$itemCount ${itemCount == 1 ? "item" : "items"}'
                                    : 'No items yet',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12.0,
                                  fontWeight: itemCount > 0
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (itemCount > 0 && totalPrice > 0)
                              Text(
                                _formatPrice(totalPrice),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.primary,
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
      ),
    );
  }

  Widget _buildFallbackIcon(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHigh,
      child: Center(
        child: Icon(
          store.icon,
          size: 40,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
