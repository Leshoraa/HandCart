import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_dimens.dart';
import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/widgets/empty_state_view.dart';
import '../../../../../stores/data/models/store_model.dart';
import '../../product_model.dart';
import '../../../../state/shopping_planner_scope.dart';
import '../../../../state/shopping_planner_controller.dart';
import '../../../../services/product_image_service.dart';
import 'add_item_page.dart';
import '../widgets/shopping_note_sheet.dart';
import '../widgets/shopping_product_tile.dart';
import '../widgets/store_expense_bottom_bar.dart';

class StoreProductListPage extends StatefulWidget {
  final Store store;
  final ProductImageService? imageService;

  const StoreProductListPage({
    super.key,
    required this.store,
    this.imageService,
  });

  @override
  State<StoreProductListPage> createState() => _StoreProductListPageState();
}

class _StoreProductListPageState extends State<StoreProductListPage> {
  late final TextEditingController _searchController;
  late final ProductImageService _productImageService;
  String _searchQuery = '';
  bool _isOpeningAddItem = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _productImageService = widget.imageService ?? ProductImageService();
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

  Future<void> _openAddItemPage() async {
    if (_isOpeningAddItem) return;
    _isOpeningAddItem = true;
    try {
      final added = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => AddItemPage(
            storeId: widget.store.id,
            storeName: widget.store.name,
            storeCategory: widget.store.category,
            imageService: _productImageService,
          ),
        ),
      );
      if (added == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item added'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _isOpeningAddItem = false;
    }
  }

  Future<void> _runPlannerAction(
    Future<void> Function() action, {
    String? successMessage,
  }) async {
    try {
      await action();
      if (successMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save changes: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDeleteProduct(
    ShoppingPlannerController planner,
    Product product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('Delete "${product.name}" from this shopping list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await planner.deleteProduct(product.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to delete product: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showEditProductSheet(Product productToEdit) async {
    final planner = ShoppingPlannerScope.of(context);
    var imagePath = productToEdit.imagePath;

    try {
      final recoveredImagePath = await _productImageService
          .retrieveLostProductImage();
      imagePath = recoveredImagePath ?? imagePath;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to recover the camera photo: $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    if (!mounted) {
      return;
    }

    final nameController = TextEditingController(text: productToEdit.name);
    final priceController = TextEditingController(
      text: productToEdit.price.toString(),
    );
    final descController = TextEditingController(
      text: productToEdit.description,
    );
    var isCapturingImage = false;
    var isSavingProduct = false;
    String? validationError;

    await showModalBottomSheet<void>(
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

        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
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
                              'Edit Item',
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
                    onChanged: (_) {
                      if (validationError != null) {
                        setSheetState(() => validationError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Price (optional)',
                      hintText: 'e.g. 15000',
                      prefixIcon: Icon(Icons.tag_rounded),
                    ),
                    onChanged: (_) {
                      if (validationError != null) {
                        setSheetState(() => validationError = null);
                      }
                    },
                  ),
                  if (validationError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      validationError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: isCapturingImage || isSavingProduct
                            ? null
                            : () async {
                                setSheetState(() => isCapturingImage = true);
                                try {
                                  final capturedImagePath =
                                      await _productImageService
                                          .captureProductImage();
                                  if (ctx.mounted &&
                                      capturedImagePath != null) {
                                    setSheetState(
                                      () => imagePath = capturedImagePath,
                                    );
                                  }
                                } catch (error) {
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Unable to capture product photo: $error',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (ctx.mounted) {
                                    setSheetState(
                                      () => isCapturingImage = false,
                                    );
                                  }
                                }
                              },
                        icon: isCapturingImage
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.camera_alt_outlined),
                        label: Text(
                          imagePath == null ? 'Take photo' : 'Retake photo',
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: imagePath == null
                            ? Icon(
                                Icons.image_outlined,
                                color: colorScheme.onSurfaceVariant,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(imagePath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.broken_image_outlined,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: isSavingProduct
                          ? null
                          : () async {
                              final name = nameController.text.trim();
                              final priceText = priceController.text
                                  .trim()
                                  .replaceAll(',', '.');
                              final parsedPrice = priceText.isEmpty
                                  ? 0.0
                                  : double.tryParse(priceText);
                              final desc = descController.text.trim();

                              if (name.isEmpty) {
                                setSheetState(
                                  () => validationError =
                                      'Item name is required.',
                                );
                                return;
                              }
                              if (parsedPrice == null ||
                                  !parsedPrice.isFinite ||
                                  parsedPrice < 0) {
                                setSheetState(
                                  () => validationError =
                                      'Enter a valid non-negative price.',
                                );
                                return;
                              }

                              setSheetState(() {
                                validationError = null;
                                isSavingProduct = true;
                              });
                              final updatedProduct = productToEdit.copyWith(
                                name: name,
                                category: widget.store.category,
                                price: parsedPrice,
                                description: desc.isEmpty
                                    ? 'Shopping item'
                                    : desc,
                                imagePath: imagePath,
                              );
                              try {
                                await planner.updateProduct(updatedProduct);
                                if (!ctx.mounted) return;
                                setSheetState(() => isSavingProduct = false);
                                Navigator.pop(ctx);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${updatedProduct.name} updated',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } catch (error) {
                                if (ctx.mounted) {
                                  setSheetState(() => isSavingProduct = false);
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Unable to save product: $error',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                      style: FilledButton.styleFrom(
                        shape: const StadiumBorder(),
                      ),
                      child: isSavingProduct
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : Text(
                              'Save Changes',
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
    final distinctCount = products
        .where((p) => planner.getProductQuantity(p.id) > 0)
        .length;
    final totalPrice = planner.getStoreTotalPrice(widget.store.id);

    final filteredProducts = products.where((product) {
      if (_searchQuery.isEmpty) return true;
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
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
                backgroundColor: WidgetStatePropertyAll(
                  colorScheme.surfaceContainerHigh,
                ),
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
                icon: _searchQuery.isEmpty
                    ? Icons.shopping_basket_outlined
                    : Icons.search_off_rounded,
                title: _searchQuery.isEmpty
                    ? AppStrings.noProductsFound
                    : 'No matching items',
                message: _searchQuery.isEmpty
                    ? 'Tap Add Item to add products to your list.'
                    : 'No items match "$_searchQuery".',
                buttonLabel: _searchQuery.isEmpty
                    ? AppStrings.addNewItem
                    : 'Clear Search',
                onButtonPressed: _searchQuery.isEmpty
                    ? _openAddItemPage
                    : () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = filteredProducts[index];
                  final qty = planner.getProductQuantity(product.id);
                  return ShoppingProductTile(
                    product: product,
                    quantity: qty,
                    isFirst: index == 0,
                    isLast: index == filteredProducts.length - 1,
                    onEdit: () => _showEditProductSheet(product),
                    onDelete: () => _confirmDeleteProduct(planner, product),
                    onIncrement: () => _runPlannerAction(
                      () => planner.incrementQuantity(product),
                    ),
                    onDecrement: () => _runPlannerAction(
                      () => planner.decrementQuantity(product.id),
                    ),
                  );
                }, childCount: filteredProducts.length),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: AppDimens.xl * 3)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddItemPage,
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
              onClear: () => _runPlannerAction(
                () => planner.clearStoreItems(widget.store.id),
                successMessage: 'Shopping list cleared',
              ),
            )
          : null,
    );
  }
}
