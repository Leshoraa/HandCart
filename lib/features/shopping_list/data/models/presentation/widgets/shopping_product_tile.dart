import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_dimens.dart';
import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/utils/currency_formatter.dart';
import '../../product_model.dart';

class ShoppingProductTile extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isFirst;
  final bool isLast;

  const ShoppingProductTile({
    super.key,
    required this.product,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onEdit,
    required this.onDelete,
    this.isFirst = false,
    this.isLast = false,
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

  Widget _buildFallbackImage(ColorScheme colorScheme) {
    return Center(
      child: Icon(product.icon, size: 32, color: colorScheme.primary),
    );
  }

  Widget _buildNetworkImage(ColorScheme colorScheme) {
    final imageUrl = product.imageUrl;
    if (imageUrl == null) return _buildFallbackImage(colorScheme);

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) =>
          _buildFallbackImage(colorScheme),
    );
  }

  Widget _buildProductImage(ColorScheme colorScheme) {
    final imagePath = product.imagePath;
    if (imagePath == null) return _buildNetworkImage(colorScheme);

    return Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          _buildNetworkImage(colorScheme),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final BorderRadius borderRadius;
    if (isFirst && isLast) {
      borderRadius = BorderRadius.circular(AppDimens.radiusLg);
    } else if (isFirst) {
      borderRadius = const BorderRadius.vertical(
        top: Radius.circular(AppDimens.radiusLg),
      );
    } else if (isLast) {
      borderRadius = const BorderRadius.vertical(
        bottom: Radius.circular(AppDimens.radiusLg),
      );
    } else {
      borderRadius = BorderRadius.zero;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainer
            : colorScheme.surfaceContainerLow,
        borderRadius: borderRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: colorScheme.surfaceContainerHigh.withValues(
                      alpha: 0.5,
                    ),
                    child: _buildProductImage(colorScheme),
                  ),
                ),

                const SizedBox(width: 14.0),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (product.description.isNotEmpty) ...[
                        const SizedBox(height: 3.0),
                        Text(
                          product.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (product.price > 0) ...[
                        const SizedBox(height: 5.0),
                        Text(
                          quantity > 1
                              ? '${_formatPrice(product.price)} × $quantity = ${_formatPrice(product.price * quantity)}'
                              : _formatPrice(product.price),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 10.0),

                if (quantity == 0)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 6.0,
                      ),
                      minimumSize: const Size(0, 36),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: onIncrement,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 16.0,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          AppStrings.addToCart,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                      border: Border.all(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32),
                          icon: Icon(
                            Icons.remove_rounded,
                            size: 16.0,
                            color: colorScheme.primary,
                          ),
                          onPressed: onDecrement,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            '$quantity',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32),
                          icon: Icon(
                            Icons.add_rounded,
                            size: 16.0,
                            color: colorScheme.primary,
                          ),
                          onPressed: onIncrement,
                        ),
                      ],
                    ),
                  ),
                PopupMenuButton<String>(
                  tooltip: 'Product options',
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                      case 'delete':
                        onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit Item')),
                    PopupMenuItem(value: 'delete', child: Text('Delete Item')),
                  ],
                ),
              ],
            ),
          ),
          if (!isLast)
            Divider(
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
        ],
      ),
    );
  }
}
