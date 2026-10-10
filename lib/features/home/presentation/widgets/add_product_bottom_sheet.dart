import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/dummy_data.dart';
import '../../data/models/product_model.dart';

class AddProductBottomSheet extends StatefulWidget {
  final ValueChanged<Product> onProductAdded;

  const AddProductBottomSheet({
    super.key,
    required this.onProductAdded,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<Product> onProductAdded,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (_) => AddProductBottomSheet(onProductAdded: onProductAdded),
    );
  }

  @override
  State<AddProductBottomSheet> createState() => _AddProductBottomSheetState();
}

class _AddProductBottomSheetState extends State<AddProductBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  String _selectedCategory = DummyData.categories[1]; // 'Beverages'
  IconData _selectedIcon = Icons.local_cafe_rounded;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  IconData _resolveCategoryIcon(String category) {
    switch (category) {
      case 'Beverages':
        return Icons.local_cafe_rounded;
      case 'Food':
        return Icons.bakery_dining_rounded;
      case 'Snacks':
        return Icons.fastfood_rounded;
      case 'Pantry':
        return Icons.soup_kitchen_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    if (name.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.validationErrorProduct),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newProduct = Product(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: _selectedCategory,
      price: price,
      description: 'Newly added $_selectedCategory product.',
      icon: _selectedIcon,
      rating: 5.0,
    );

    widget.onProductAdded(newProduct);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Product "$name" added successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              AppStrings.addNewProduct,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.productName,
                prefixIcon: Icon(Icons.label_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: AppStrings.price,
                prefixIcon: Icon(Icons.attach_money_rounded),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.category,
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
                  .where((category) => category != 'All')
                  .map((category) {
                final isSelected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
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
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _selectedIcon = _resolveCategoryIcon(category);
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
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  AppStrings.saveProduct,
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
  }
}
