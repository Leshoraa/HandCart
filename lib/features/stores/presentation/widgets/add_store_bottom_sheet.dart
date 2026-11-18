import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/store_model.dart';

class _CategoryPreset {
  final String name;
  final IconData icon;
  final String defaultImageUrl;
  final String defaultDescription;

  const _CategoryPreset({
    required this.name,
    required this.icon,
    required this.defaultImageUrl,
    required this.defaultDescription,
  });
}

class AddStoreBottomSheet extends StatefulWidget {
  final ValueChanged<Store>? onStoreAdded;
  final ValueChanged<Store>? onStoreUpdated;
  final Store? storeToEdit;

  const AddStoreBottomSheet({
    super.key,
    this.onStoreAdded,
    this.onStoreUpdated,
    this.storeToEdit,
  });

  static Future<void> show(
    BuildContext context, {
    ValueChanged<Store>? onStoreAdded,
    ValueChanged<Store>? onStoreUpdated,
    Store? storeToEdit,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (_) => AddStoreBottomSheet(
        onStoreAdded: onStoreAdded,
        onStoreUpdated: onStoreUpdated,
        storeToEdit: storeToEdit,
      ),
    );
  }

  @override
  State<AddStoreBottomSheet> createState() => _AddStoreBottomSheetState();
}

class _AddStoreBottomSheetState extends State<AddStoreBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  late String _selectedCategory;
  late String _selectedImageUrl;
  late IconData _selectedIcon;

  static const List<_CategoryPreset> _categoryPresets = [
    _CategoryPreset(
      name: 'Supermarket',
      icon: Icons.local_grocery_store_rounded,
      defaultImageUrl:
          'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=600&auto=format&fit=crop&q=80',
      defaultDescription: 'Daily fresh produce, dairy & pantry essentials',
    ),
    _CategoryPreset(
      name: 'Bakery',
      icon: Icons.bakery_dining_rounded,
      defaultImageUrl:
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&auto=format&fit=crop&q=80',
      defaultDescription: 'Handcrafted sourdough, golden croissants & baked goods',
    ),
    _CategoryPreset(
      name: 'Organic Store',
      icon: Icons.eco_rounded,
      defaultImageUrl:
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&auto=format&fit=crop&q=80',
      defaultDescription: 'Clean pantry essentials, superfoods & healthy snacks',
    ),
    _CategoryPreset(
      name: 'Convenience',
      icon: Icons.storefront_rounded,
      defaultImageUrl:
          'https://images.unsplash.com/photo-1534723452862-4c874018d66d?w=600&auto=format&fit=crop&q=80',
      defaultDescription: 'Quick refreshments, late-night snacks & household goods',
    ),
    _CategoryPreset(
      name: 'Cafe & Coffee',
      icon: Icons.local_cafe_rounded,
      defaultImageUrl:
          'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=600&auto=format&fit=crop&q=80',
      defaultDescription: 'Specialty coffee brews, light bites & fresh roast beans',
    ),
    _CategoryPreset(
      name: 'Pharmacy',
      icon: Icons.medication_rounded,
      defaultImageUrl:
          'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=600&auto=format&fit=crop&q=80',
      defaultDescription: 'Vitamins, healthcare items & personal wellness essentials',
    ),
  ];

  static const List<String> _curatedPhotos = [
    'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1534723452862-4c874018d66d?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=600&auto=format&fit=crop&q=80',
  ];

  @override
  void initState() {
    super.initState();
    final editStore = widget.storeToEdit;

    _nameController = TextEditingController(text: editStore?.name ?? '');
    _descriptionController =
        TextEditingController(text: editStore?.description ?? '');

    _selectedCategory = editStore?.category ?? _categoryPresets.first.name;
    _selectedIcon = editStore?.icon ?? _categoryPresets.first.icon;
    _selectedImageUrl =
        editStore?.imageUrl ?? _categoryPresets.first.defaultImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _getFallbackDescription(String category) {
    final match = _categoryPresets.firstWhere(
      (p) => p.name == category,
      orElse: () => _categoryPresets.first,
    );
    return match.defaultDescription;
  }

  void _onCategorySelected(_CategoryPreset preset) {
    setState(() {
      _selectedCategory = preset.name;
      _selectedIcon = preset.icon;
      if (_curatedPhotos.contains(_selectedImageUrl)) {
        _selectedImageUrl = preset.defaultImageUrl;
      }
    });
  }

  void _submit() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a store name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final finalDesc = description.isNotEmpty
        ? description
        : _getFallbackDescription(_selectedCategory);

    if (widget.storeToEdit != null) {
      final updatedStore = widget.storeToEdit!.copyWith(
        name: name,
        category: _selectedCategory,
        description: finalDesc,
        icon: _selectedIcon,
        imageUrl: _selectedImageUrl,
      );
      widget.onStoreUpdated?.call(updatedStore);
    } else {
      final newStore = Store(
        id: 'store_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        category: _selectedCategory,
        description: finalDesc,
        icon: _selectedIcon,
        imageUrl: _selectedImageUrl,
        createdAt: DateTime.now(),
        note: '',
      );
      widget.onStoreAdded?.call(newStore);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.storeToEdit != null
                            ? 'Edit Store'
                            : AppStrings.addNewStore,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Choose category and details for your shopping trip',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              height: 114,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                color: colorScheme.surfaceContainerHigh,
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                  width: 1.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        _selectedImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: colorScheme.surfaceContainerHigh,
                          child: Center(
                            child: Icon(
                              _selectedIcon,
                              size: 36,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.black.withValues(alpha: 0.68),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _selectedIcon,
                              size: 13,
                              color: colorScheme.onSurface,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _selectedCategory,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _nameController.text.trim().isEmpty
                                ? 'Store Name'
                                : _nameController.text.trim(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 4),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _descriptionController.text.trim().isEmpty
                                ? _getFallbackDescription(_selectedCategory)
                                : _descriptionController.text.trim(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontWeight: FontWeight.w500,
                              fontSize: 11.5,
                              shadows: const [
                                Shadow(color: Colors.black54, blurRadius: 3),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: AppStrings.storeName,
                hintText: 'e.g. Grand Fresh Market, Alfamart, Trader Joe\'s',
                prefixIcon: Icon(
                  Icons.storefront_rounded,
                  color: colorScheme.primary,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            Text(
              'SELECT CATEGORY',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categoryPresets.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final preset = _categoryPresets[index];
                  final isSelected = preset.name == _selectedCategory;

                  return FilterChip(
                    selected: isSelected,
                    showCheckmark: false,
                    avatar: Icon(
                      preset.icon,
                      size: 16,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                    label: Text(preset.name),
                    labelStyle: theme.textTheme.labelMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                    backgroundColor: colorScheme.surface,
                    selectedColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusFull),
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : colorScheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                    onSelected: (_) => _onCategorySelected(preset),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'COVER PHOTO',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _curatedPhotos.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final photoUrl = _curatedPhotos[index];
                  final isSelected = photoUrl == _selectedImageUrl;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImageUrl = photoUrl;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9.5),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: colorScheme.surfaceContainerHigh,
                                child: Icon(
                                  Icons.storefront_rounded,
                                  size: 20,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.35),
                                child: const Center(
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: AppStrings.storeDescription,
                hintText: 'e.g. Weekly family groceries, check dairy section...',
                prefixIcon: Icon(
                  Icons.notes_rounded,
                  color: colorScheme.primary,
                ),
                alignLabelWithHint: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(Icons.check_circle_rounded, size: 20),
                label: Text(
                  widget.storeToEdit != null
                      ? 'Save Changes'
                      : AppStrings.saveStore,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
