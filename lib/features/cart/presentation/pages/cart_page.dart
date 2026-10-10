import 'package:flutter/material.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          AppStrings.cartTitle,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (!cart.isEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppDimens.sm),
              child: TextButton(
                onPressed: () {
                  _showClearConfirmation(context, cart.clear);
                },
                child: Text(
                  AppStrings.clearCart,
                  style: TextStyle(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28.0),
        ),
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
                Text(
                  AppStrings.subtotal,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  CurrencyFormatter.formatRupiah(cart.subtotal),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.tax,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  CurrencyFormatter.formatRupiah(cart.tax),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const Divider(height: AppDimens.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.total,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  CurrencyFormatter.formatRupiah(cart.totalPrice),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.md),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  _showSuccessCheckoutDialog(context, cart.clear);
                },
                icon: const Icon(Icons.check_rounded),
                label: const Text(
                  AppStrings.checkout,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: FilledButton.styleFrom(
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, VoidCallback onConfirm) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          AppStrings.clearCart,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(AppStrings.confirmClearCart),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              shape: const StadiumBorder(),
            ),
            child: const Text(AppStrings.yes),
          ),
        ],
      ),
    );
  }

  void _showSuccessCheckoutDialog(BuildContext context, VoidCallback onClear) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        icon: Icon(
          Icons.check_circle_rounded,
          color: colorScheme.primary,
          size: 48,
        ),
        title: const Text(
          'Pesanan Berhasil!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Terima kasih telah berbelanja menggunakan HandCart. Pesanan Anda segera diproses.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onClear();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }
}
