import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../shopping_list/presentation/pages/store_product_list_page.dart';
import '../../../shopping_list/state/shopping_planner_controller.dart';
import '../../../shopping_list/state/shopping_planner_scope.dart';
import '../../data/models/store_model.dart';
import '../widgets/add_store_bottom_sheet.dart';
import '../widgets/store_card.dart';

class StoreListPage extends StatefulWidget {
  const StoreListPage({super.key});

  @override
  State<StoreListPage> createState() => _StoreListPageState();
}

class _StoreListPageState extends State<StoreListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TextEditingController _searchController;
  String _selectedCategory = AppStrings.allStores;
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

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _handleTogglePin(ShoppingPlannerController planner, Store store) {
    planner.togglePinStore(store.id);
    final isNowPinned = !store.isPinned;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowPinned
              ? '${store.name} pinned to top'
              : '${store.name} unpinned',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleEditStore(ShoppingPlannerController planner, Store store) {
    AddStoreBottomSheet.show(
      context,
      storeToEdit: store,
      onStoreUpdated: (updatedStore) {
        planner.updateStore(updatedStore);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${updatedStore.name} updated'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Future<void> _handleDeleteStore(
    ShoppingPlannerController planner,
    Store store,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Store?'),
        content: Text(
          'Are you sure you want to delete "${store.name}" and all its planned items? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      planner.deleteStore(store.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${store.name} deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final planner = ShoppingPlannerScope.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final totalExpenseAll = planner.getTotalPlannedExpense();
    final totalCountAll = planner.getTotalPlannedCount();

    // Extract unique store categories
    final categories = [
      AppStrings.allStores,
      ...planner.stores.map((s) => s.category).toSet(),
    ];

    final filteredStores = planner.stores.where((store) {
      final matchesCategory = _selectedCategory == AppStrings.allStores ||
          store.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          store.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          store.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          store.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    // Group stores by date
    final Map<DateTime, List<Store>> groupedStores = {};
    for (final store in filteredStores) {
      final dayKey =
          DateTime(store.date.year, store.date.month, store.date.day);
      groupedStores.putIfAbsent(dayKey, () => []).add(store);
    }
    final sortedDates = groupedStores.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    for (final date in sortedDates) {
      groupedStores[date]!.sort(
        (a, b) => (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorScheme.surface,
      drawer: NavigationDrawer(
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: colorScheme.primaryContainer,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Icon(
                        Icons.shopping_bag_rounded,
                        color: colorScheme.onPrimaryContainer,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.appName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Shopping Planner',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Planned Budget',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(totalExpenseAll),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalCountAll items planned across ${planner.stores.length} stores',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(indent: 20, endIndent: 20),
          NavigationDrawerDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront_rounded),
            label: Text('${AppStrings.allStores} (${planner.stores.length})'),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.notes_outlined),
            selectedIcon: const Icon(Icons.notes_rounded),
            label: const Text('Shopping Memos'),
          ),
          const Divider(indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'CATEGORIES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ...categories.skip(1).map(
            (cat) => NavigationDrawerDestination(
              icon: const Icon(Icons.label_outline_rounded),
              selectedIcon: const Icon(Icons.label_rounded),
              label: Text(cat),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        centerTitle: true,
        title: Text(
          AppStrings.appName,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.2,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.category_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search Bar at Top (Matching Image 2)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.md,
                  AppDimens.sm,
                  AppDimens.md,
                  AppDimens.md,
                ),
                child: SearchBar(
                  controller: _searchController,
                  hintText: AppStrings.searchStoresHint,
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

              // Scrollable Page Content (Chips, Section Header, Cards Grid)
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Horizontal Category Filter Chips with Animated Morphing Capsule
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.md,
                          ),
                          itemCount: categories.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: AppDimens.sm),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected = category == _selectedCategory;
                            return Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOutCubicEmphasized,
                                height: 32.0,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primaryContainer
                                      : (isDark
                                          ? colorScheme.surfaceContainerHigh
                                          : Colors.white),
                                  borderRadius: BorderRadius.circular(
                                    isSelected ? 16.0 : 10.0,
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : colorScheme.outlineVariant
                                            .withValues(alpha: 0.8),
                                    width: 1.0,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(
                                      isSelected ? 16.0 : 10.0,
                                    ),
                                    onTap: () => _onCategorySelected(category),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                      ),
                                      child: Center(
                                        child: AnimatedDefaultTextStyle(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                            color: isSelected
                                                ? colorScheme.onPrimaryContainer
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                          child: Text(category),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Date Grouped Store Sections (No "Shopping Places" text!)
                    if (filteredStores.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.storefront_outlined,
                                size: 64,
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No matching stores found',
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
                      for (final date in sortedDates) ...[
                        // Date Section Header
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppDimens.md,
                              AppDimens.lg,
                              AppDimens.md,
                              AppDimens.sm + 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormatter.formatRelativeDate(date),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(
                                        AppDimens.radiusFull),
                                  ),
                                  child: Text(
                                    '${groupedStores[date]!.length} ${groupedStores[date]!.length == 1 ? "store" : "stores"}',
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

                        // Store Cards 2-Column Grid for this date
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.md,
                          ),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12.0,
                              mainAxisSpacing: 12.0,
                              mainAxisExtent: 254.0,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final store = groupedStores[date]![index];
                                final itemCount =
                                    planner.getStoreItemCount(store.id);
                                final totalPrice =
                                    planner.getStoreTotalPrice(store.id);
                                return StoreCard(
                                  store: store,
                                  itemCount: itemCount,
                                  totalPrice: totalPrice,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            StoreProductListPage(store: store),
                                      ),
                                    );
                                  },
                                  onPin: () =>
                                      _handleTogglePin(planner, store),
                                  onEdit: () =>
                                      _handleEditStore(planner, store),
                                  onDelete: () =>
                                      _handleDeleteStore(planner, store),
                                );
                              },
                              childCount: groupedStores[date]!.length,
                            ),
                          ),
                        ),
                      ],

                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppDimens.xl * 3),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Floating Search Suggestions Dropdown (Image 1) - Floats over content with elevation, does NOT shift layout!
          if (_searchQuery.isNotEmpty && filteredStores.isNotEmpty)
            Positioned(
              top: 68.0,
              left: AppDimens.md,
              right: AppDimens.md,
              child: Material(
                elevation: 6,
                shadowColor: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20.0),
                color: colorScheme.surfaceContainerHigh,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: filteredStores.take(3).map((store) {
                      return ListTile(
                        leading: Icon(
                          Icons.category_rounded,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                          size: 26,
                        ),
                        title: Text(
                          store.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          store.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoreProductListPage(store: store),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddStoreBottomSheet.show(
          context,
          onStoreAdded: planner.addStore,
        ),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add_business_rounded),
        label: const Text(
          AppStrings.addNewStore,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
