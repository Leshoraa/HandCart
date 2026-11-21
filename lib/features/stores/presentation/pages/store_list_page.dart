import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/google_settings_sheet.dart';
import '../../../shopping_list/data/models/presentation/pages/store_product_list_page.dart';
import '../../../shopping_list/state/shopping_planner_controller.dart';
import '../../../shopping_list/state/shopping_planner_scope.dart';
import '../../data/models/store_model.dart';
import '../widgets/add_store_bottom_sheet.dart';
import '../widgets/category_filter_bar.dart';
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

  Future<void> _handleTogglePin(
    ShoppingPlannerController planner,
    Store store,
  ) async {
    try {
      await planner.togglePinStore(store.id);
      final isNowPinned = !store.isPinned;
      if (!mounted) return;
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
    } catch (error) {
      _showStorageError(error);
    }
  }

  void _showStorageError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unable to save changes: $error'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleEditStore(ShoppingPlannerController planner, Store store) {
    AddStoreBottomSheet.show(
      context,
      storeToEdit: store,
      onStoreUpdated: (updatedStore) async {
        await planner.updateStore(updatedStore);
        if (!mounted) return;
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
      try {
        await planner.deleteStore(store.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${store.name} deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (error) {
        _showStorageError(error);
      }
    }
  }

  Widget _buildStoreCard(ShoppingPlannerController planner, Store store) {
    final itemCount = planner.getStoreItemCount(store.id);
    final totalPrice = planner.getStoreTotalPrice(store.id);
    return StoreCard(
      store: store,
      itemCount: itemCount,
      totalPrice: totalPrice,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StoreProductListPage(store: store)),
        );
      },
      onPin: () => _handleTogglePin(planner, store),
      onEdit: () => _handleEditStore(planner, store),
      onDelete: () => _handleDeleteStore(planner, store),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planner = ShoppingPlannerScope.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalCountAll = planner.getTotalPlannedCount();

    final categories = [
      AppStrings.allStores,
      ...planner.stores.map((s) => s.category).toSet(),
    ];

    final filteredStores = planner.stores.where((store) {
      final matchesCategory =
          _selectedCategory == AppStrings.allStores ||
          store.category == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          store.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          store.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          store.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    final Map<DateTime, List<Store>> groupedStores = {};
    for (final store in filteredStores) {
      final dayKey = DateTime(
        store.date.year,
        store.date.month,
        store.date.day,
      );
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
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        selectedIndex: _selectedCategory == AppStrings.allStores
            ? 0
            : (categories.skip(1).contains(_selectedCategory)
                  ? 2 + categories.skip(1).toList().indexOf(_selectedCategory)
                  : 0),
        onDestinationSelected: (idx) {
          final categoryCount = categories.length - 1;
          if (idx == 0) {
            _onCategorySelected(AppStrings.allStores);
            Navigator.pop(context);
          } else if (idx == 1) {
            Navigator.pop(context);
          } else if (idx >= 2 && idx < 2 + categoryCount) {
            final cat = categories.skip(1).elementAt(idx - 2);
            _onCategorySelected(cat);
            Navigator.pop(context);
          } else if (idx == 2 + categoryCount) {
            Navigator.pop(context);
            GoogleSettingsSheet.show(context);
          } else if (idx == 3 + categoryCount) {
            Navigator.pop(context);
            showLicensePage(
              context: context,
              applicationName: AppStrings.appName,
              applicationVersion: '1.0.0',
            );
          }
        },
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Shopping Planner',
                          style: theme.textTheme.bodySmall?.copyWith(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.checklist_rounded,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$totalCountAll items planned • ${planner.stores.length} stores',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
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
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ...categories
              .skip(1)
              .map(
                (cat) => NavigationDrawerDestination(
                  icon: const Icon(Icons.label_outline_rounded),
                  selectedIcon: const Icon(Icons.label_rounded),
                  label: Text(cat),
                ),
              ),
          const Divider(indent: 20, endIndent: 20),
          const NavigationDrawerDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: Text('Settings'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.help_outline_rounded),
            selectedIcon: Icon(Icons.help_rounded),
            label: Text('Help & feedback'),
          ),
        ],
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          AppStrings.appName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Help & feedback',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'HandCart - Modern Material You Shopping Planner',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => GoogleSettingsSheet.show(context),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: 20,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: planner.isLoading
          ? const Center(child: CircularProgressIndicator())
          : planner.loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      'Unable to load shopping data: ${planner.loadError}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: planner.initialize,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.md,
                      AppDimens.xs,
                      AppDimens.md,
                      AppDimens.md,
                    ),
                    child: SearchBar(
                      controller: _searchController,
                      hintText: AppStrings.searchStoresHint,
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

                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: CategoryFilterBar(
                            categories: categories,
                            selectedCategory: _selectedCategory,
                            onCategorySelected: _onCategorySelected,
                          ),
                        ),

                        if (filteredStores.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: EmptyStateView(
                              icon: Icons.storefront_outlined,
                              title: AppStrings.noStoresFound,
                              message: _searchQuery.isNotEmpty
                                  ? 'No stores match "$_searchQuery". Try clearing your search.'
                                  : 'No stores in this category yet. Tap Add Store to create one.',
                              buttonLabel: _searchQuery.isNotEmpty
                                  ? 'Clear Search'
                                  : null,
                              onButtonPressed: _searchQuery.isNotEmpty
                                  ? () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    }
                                  : null,
                            ),
                          )
                        else
                          for (final date in sortedDates) ...[
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppDimens.md,
                                  AppDimens.lg,
                                  AppDimens.md,
                                  AppDimens.sm,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormatter.formatRelativeDate(date),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.secondaryContainer,
                                        borderRadius: BorderRadius.circular(
                                          AppDimens.radiusFull,
                                        ),
                                      ),
                                      child: Text(
                                        '${groupedStores[date]!.length} ${groupedStores[date]!.length == 1 ? "store" : "stores"}',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme
                                                  .onSecondaryContainer,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimens.md,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, rowIndex) {
                                    final dateStores = groupedStores[date]!;
                                    final rowCount =
                                        (dateStores.length + 1) ~/ 2;
                                    final firstIndex = rowIndex * 2;
                                    final secondIndex = firstIndex + 1;
                                    final store1 = dateStores[firstIndex];
                                    final store2 =
                                        secondIndex < dateStores.length
                                        ? dateStores[secondIndex]
                                        : null;

                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: rowIndex < rowCount - 1
                                            ? 12.0
                                            : 0.0,
                                      ),
                                      child: IntrinsicHeight(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(
                                              child: _buildStoreCard(
                                                planner,
                                                store1,
                                              ),
                                            ),
                                            const SizedBox(width: 12.0),
                                            Expanded(
                                              child: store2 != null
                                                  ? _buildStoreCard(
                                                      planner,
                                                      store2,
                                                    )
                                                  : const SizedBox.shrink(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  childCount:
                                      (groupedStores[date]!.length + 1) ~/ 2,
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
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddStoreBottomSheet.show(
          context,
          onStoreAdded: (store) async {
            final messenger = ScaffoldMessenger.of(context);
            await planner.addStore(store);
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(
                content: Text('${store.name} added'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        elevation: AppDimens.elevationNone,
        shape: const StadiumBorder(),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add_business_rounded),
        label: Text(
          AppStrings.addNewStore,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
