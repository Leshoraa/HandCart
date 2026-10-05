import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../state/cart_scope.dart';
import '../widgets/cart_item_tile.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.cartTitle),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () {
                _showClearConfirmation(context, cart.clear);
              },
              child: const Text(
                AppStrings.clearCart,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: cart.isEmpty
          ? EmptyStateView(
              icon: Icons.remove_shopping_cart_outlined,
              title: AppStrings.emptyCartTitle,
              message: AppStrings.emptyCartSubtitle,
              buttonLabel: AppStrings.startShopping,
              onButtonPressed: () => Navigator.pop(context),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimens.md),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      return CartItemTile(item: cart.items[index]);
                    },
                  ),
                ),
                _buildSummarySheet(context, cart),
              ],
            ),
    );
  }

  Widget _buildSummarySheet(BuildContext context, dynamic cart) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.subtotal,
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  CurrencyFormatter.formatRupiah(cart.subtotal),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.tax,
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  CurrencyFormatter.formatRupiah(cart.tax),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Divider(height: AppDimens.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.total,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  CurrencyFormatter.formatRupiah(cart.totalPrice),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.md),
            ElevatedButton(
              onPressed: () {
                _showSuccessCheckoutDialog(context, cart.clear);
              },
              child: const Text(
                AppStrings.checkout,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(
      BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.clearCart),
        content: const Text(AppStrings.confirmClearCart),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(AppStrings.yes),
          ),
        ],
      ),
    );
  }

  void _showSuccessCheckoutDialog(
      BuildContext context, VoidCallback onClear) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
          size: 48,
        ),
        title: const Text('Pesanan Berhasil!'),
        content: const Text(
          'Terima kasih telah berbelanja menggunakan HandCart. Pesanan Anda segera diproses.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onClear();
              Navigator.pop(context);
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }
}
