import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../stores/data/models/store_model.dart';
import '../../data/models/product_model.dart';
import '../../state/shopping_planner_scope.dart';
import '../widgets/shopping_note_sheet.dart';
import '../widgets/shopping_product_tile.dart';
import '../widgets/store_expense_bottom_bar.dart';

class StoreProductListPage extends StatefulWidget {
  final Store store;

  const StoreProductListPage({
    super.key,
    required this.store,
  });

  @override
  State<StoreProductListPage> createState() => _StoreProductListPageState();
}

class _StoreProductListPageState extends State<StoreProductListPage> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim();
    });
  }

  void _showAddProductSheet(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        final theme = Theme.of(ctx);

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 20,
            right: 20,
            top: 4,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_shopping_cart_rounded,
                        size: 22,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.addNewItem,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Planned item for ${widget.store.name}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: AppStrings.itemName,
                    prefixIcon: Icon(Icons.shopping_bag_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Price (optional)',
                    hintText: 'e.g. 15000',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Short Description',
                    prefixIcon: Icon(Icons.notes_rounded),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      final price = double.tryParse(
                            priceController.text.trim().replaceAll(',', '.'),
                          ) ??
                          0.0;
                      final desc = descController.text.trim();

                      if (name.isNotEmpty) {
                        final planner = ShoppingPlannerScope.of(context);
                        final newProduct = Product(
                          id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                          storeId: widget.store.id,
                          name: name,
                          category: widget.store.category,
                          price: price,
                          description: desc.isEmpty ? 'Shopping item' : desc,
                          icon: Icons.shopping_basket_rounded,
                        );
                        planner.addProduct(newProduct);
                        planner.incrementQuantity(newProduct);
                        Navigator.pop(ctx);
                      }
                    },
                    style: FilledButton.styleFrom(
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      AppStrings.saveItem,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final planner = ShoppingPlannerScope.of(context);
    final products = planner.getProductsForStore(widget.store.id);
    final totalQuantity = planner.getStoreItemCount(widget.store.id);
    final distinctCount =
        products.where((p) => planner.getProductQuantity(p.id) > 0).length;
    final totalPrice = planner.getStoreTotalPrice(widget.store.id);

    final filteredProducts = products.where((product) {
      if (_searchQuery.isEmpty) return true;
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.store.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              widget.store.category,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimens.md),
            child: IconButton.filledTonal(
              tooltip: AppStrings.shoppingNotes,
              onPressed: () => ShoppingNoteSheet.show(context, widget.store),
              icon: Icon(
                Icons.edit_note_rounded,
                size: 24,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.md,
                AppDimens.sm,
                AppDimens.md,
                AppDimens.md,
              ),
              child: SearchBar(
                controller: _searchController,
                hintText: AppStrings.searchProductsHint,
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor:
                    WidgetStatePropertyAll(colorScheme.surfaceContainerHigh),
                shape: const WidgetStatePropertyAll(StadiumBorder()),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
                leading: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : Icon(
                        Icons.search_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                trailing: [
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.mic_rounded),
                    onPressed: () {},
                  ),
                ],
                onChanged: _onSearchChanged,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.md,
                0,
                AppDimens.md,
                AppDimens.sm + 4,
              ),
              child: Text(
                'Items to Buy (${filteredProducts.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),

          if (filteredProducts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateView(
                icon: Icons.shopping_basket_outlined,
                title: AppStrings.noProductsFound,
                message:
                    'No items found. Tap Add Item to add products to your list.',
                buttonLabel: AppStrings.addNewItem,
                onButtonPressed: () => _showAddProductSheet(context),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = filteredProducts[index];
                    final qty = planner.getProductQuantity(product.id);
                    return ShoppingProductTile(
                      product: product,
                      quantity: qty,
                      isFirst: index == 0,
                      isLast: index == filteredProducts.length - 1,
                      onIncrement: () => planner.incrementQuantity(product),
                      onDecrement: () => planner.decrementQuantity(product.id),
                    );
                  },
                  childCount: filteredProducts.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimens.xl * 3),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductSheet(context),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          AppStrings.addNewItem,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
      bottomNavigationBar: totalQuantity > 0
          ? StoreExpenseBottomBar(
              itemCount: distinctCount,
              totalQuantity: totalQuantity,
              totalPrice: totalPrice,
              onClear: () => planner.clearStoreItems(widget.store.id),
            )
          : null,
    );
  }
}
