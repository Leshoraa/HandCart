import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/state/cart_controller.dart';

class HomeCartBottomBar extends StatelessWidget {
  final CartController cart;

  const HomeCartBottomBar({
    super.key,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    if (cart.totalCount == 0) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Material(
          elevation: 4,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          color: colorScheme.primary,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_bag_rounded,
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${AppStrings.cartPrefix} (${cart.totalCount})',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    CurrencyFormatter.format(cart.totalPrice),
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
