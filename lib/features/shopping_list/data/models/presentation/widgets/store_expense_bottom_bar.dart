import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_dimens.dart';
import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/utils/currency_formatter.dart';

class StoreExpenseBottomBar extends StatelessWidget {
  final int itemCount;
  final int totalQuantity;
  final double totalPrice;
  final VoidCallback onClear;

  const StoreExpenseBottomBar({
    super.key,
    required this.itemCount,
    this.totalQuantity = 0,
    this.totalPrice = 0.0,
    required this.onClear,
  });

  String _formatTotal(num amount) {
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Material(
          elevation: AppDimens.elevationNone,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          color: colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag_rounded,
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemCount == 1
                          ? '1 ${AppStrings.singleItemPlanned}'
                          : '$itemCount ${AppStrings.itemsPlanned}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (totalQuantity > itemCount)
                      Text(
                        '$totalQuantity total items',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                if (totalPrice > 0) ...[
                  Text(
                    _formatTotal(totalPrice),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  icon: Icon(
                    Icons.delete_sweep_outlined,
                    color: colorScheme.onPrimary.withValues(alpha: 0.85),
                    size: 20,
                  ),
                  tooltip: 'Clear planned items',
                  visualDensity: VisualDensity.compact,
                  onPressed: onClear,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
