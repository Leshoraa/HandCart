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
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    return DummyData.sampleProducts.where((product) {
      final matchesCategory = _selectedCategory == 'Semua' ||
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
                        helpText: 'PILIH TANGGAL',
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
                            _selectedCategory == 'Semua'
                                ? DateFormatter.formatRelativeDate(_selectedDate)
                                : _selectedCategory,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (_selectedCategory == 'Semua') ...[
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
                      '${_filteredProducts.length} produk',
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
                      'Tidak ada produk yang cocok',
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: cart.totalCount > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                );
              },
              elevation: 3,
              shape: const StadiumBorder(),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              icon: const Icon(Icons.shopping_bag_rounded),
              label: Text(
                'Keranjang (${cart.totalCount}) • ${CurrencyFormatter.formatRupiah(cart.totalPrice)}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            )
          : null,
    );
  }
}
