import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
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

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          AppStrings.addNewItem,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.itemName,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: AppStrings.itemPrice,
                  prefixText: '\$ ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Short Description',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ?? 0.0;
              final desc = descController.text.trim();

              if (name.isNotEmpty && price > 0) {
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
            style: FilledButton.styleFrom(shape: const StadiumBorder()),
            child: const Text(AppStrings.saveItem),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planner = ShoppingPlannerScope.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final products = planner.getProductsForStore(widget.store.id);
    final totalExpense = planner.getStoreTotalPrice(widget.store.id);
    final itemCount = planner.getStoreItemCount(widget.store.id);

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
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18.0,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              widget.store.category,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.0,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          // Note Menu Button in Top-Right
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
          // Search Bar
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
                leading: Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                trailing: [
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),
                ],
                onChanged: _onSearchChanged,
              ),
            ),
          ),

          // Header Summary Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.md,
                0,
                AppDimens.md,
                AppDimens.sm + 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Items to Buy (${filteredProducts.length})',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddProductDialog(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text(
                      AppStrings.addNewItem,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Single-Column Vertical List of Products
          if (filteredProducts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_basket_outlined,
                      size: 64,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.noProductsFound,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
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
      bottomNavigationBar: itemCount > 0
          ? StoreExpenseBottomBar(
              itemCount: itemCount,
              totalPrice: totalExpense,
              onClear: () => planner.clearStoreItems(widget.store.id),
            )
          : null,
    );
  }
}
