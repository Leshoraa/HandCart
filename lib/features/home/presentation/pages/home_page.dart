import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/state/cart_scope.dart';
import '../../data/dummy_data.dart';
import '../../data/models/product_model.dart';
import '../widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  final List<Product> _products = List<Product>.from(DummyData.sampleProducts);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    return _products.where((product) {
      final matchesCategory = _selectedCategory == 'All' ||
          product.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        titleSpacing: AppDimens.md,
        title: Text(
          AppStrings.appName,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimens.md),
            child: IconButton.filledTonal(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                );
              },
              icon: Badge(
                isLabelVisible: cart.totalCount > 0,
                label: Text('${cart.totalCount}'),
                backgroundColor: colorScheme.error,
                child: const Icon(Icons.shopping_cart_outlined, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // M3 Expressive Pill Search Bar
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
                hintText: AppStrings.searchHint,
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
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                },
              ),
            ),
          ),

          // M3 Expressive Categories Filter
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                itemCount: DummyData.categories.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppDimens.sm),
                itemBuilder: (context, index) {
                  final category = DummyData.categories[index];
                  final isSelected = category == _selectedCategory;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    showCheckmark: false,
                    shape: const StadiumBorder(),
                    side: BorderSide.none,
                    backgroundColor: colorScheme.surfaceContainerHigh,
                    selectedColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                  );
                },
              ),
            ),
          ),

          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.md,
                AppDimens.lg,
                AppDimens.md,
                AppDimens.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        helpText: 'SELECT DATE',
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedCategory == 'All'
                                ? DateFormatter.formatRelativeDate(_selectedDate)
                                : _selectedCategory,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (_selectedCategory == 'All') ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 15,
                              color: colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusFull),
                    ),
                    child: Text(
                      '${_filteredProducts.length} products',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Products Grid (Expressive Spacing & Aspect Ratio)
          if (_filteredProducts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: AppDimens.md),
                    Text(
                      'No matching products found',
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.64,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = _filteredProducts[index];
                    return ProductCard(product: product);
                  },
                  childCount: _filteredProducts.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimens.xl * 2 + 16),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductBottomSheet(context),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        child: const Icon(
          Icons.add_rounded,
          size: 28,
        ),
      ),
      bottomNavigationBar: cart.totalCount > 0
          ? SafeArea(
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
                            'Cart (${cart.totalCount})',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            CurrencyFormatter.formatRupiah(cart.totalPrice),
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
            )
          : null,
    );
  }

  void _showAddProductBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String selectedCategory = DummyData.categories[1]; // 'Beverages'
    IconData selectedIcon = Icons.local_cafe_rounded;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Add New Product',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        prefixIcon: Icon(Icons.label_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: DummyData.categories
                          .where((c) => c != 'All')
                          .map((category) {
                        final isSel = category == selectedCategory;
                        return ChoiceChip(
                          label: Text(category),
                          selected: isSel,
                          shape: const StadiumBorder(),
                          side: BorderSide.none,
                          backgroundColor: colorScheme.surfaceContainerHigh,
                          selectedColor: colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color: isSel
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                            fontWeight:
                                isSel ? FontWeight.w800 : FontWeight.w600,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                selectedCategory = category;
                                if (category == 'Beverages') {
                                  selectedIcon = Icons.local_cafe_rounded;
                                } else if (category == 'Food') {
                                  selectedIcon = Icons.bakery_dining_rounded;
                                } else if (category == 'Snacks') {
                                  selectedIcon = Icons.fastfood_rounded;
                                } else if (category == 'Pantry') {
                                  selectedIcon = Icons.soup_kitchen_rounded;
                                } else {
                                  selectedIcon = Icons.shopping_bag_rounded;
                                }
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final price =
                              double.tryParse(priceController.text.trim()) ?? 0;
                          if (name.isEmpty || price <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid product name and price'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          final newProduct = Product(
                            id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                            name: name,
                            category: selectedCategory,
                            price: price,
                            description: 'Newly added $selectedCategory product.',
                            icon: selectedIcon,
                            rating: 5.0,
                          );

                          setState(() {
                            _products.insert(0, newProduct);
                          });

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Product "$name" added successfully!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          'Save Product',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
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
      },
    );
  }
}
