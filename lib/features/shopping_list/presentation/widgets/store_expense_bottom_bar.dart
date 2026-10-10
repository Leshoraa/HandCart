import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';

class StoreExpenseBottomBar extends StatelessWidget {
  final int itemCount;
  final double totalPrice;
  final VoidCallback onClear;

  const StoreExpenseBottomBar({
    super.key,
    required this.itemCount,
    required this.totalPrice,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Material(
          elevation: 4,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          color: colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag_rounded,
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  itemCount == 1
                      ? '1 ${AppStrings.singleItemPlanned}'
                      : '$itemCount ${AppStrings.itemsPlanned}',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  CurrencyFormatter.format(totalPrice),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
