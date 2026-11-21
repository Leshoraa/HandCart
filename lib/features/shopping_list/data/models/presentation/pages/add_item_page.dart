import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../state/shopping_planner_scope.dart';
import '../../../../services/product_image_service.dart';
import '../../product_model.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.storeCategory,
    this.imageService,
  });

  final String storeId;
  final String storeName;
  final String storeCategory;
  final ProductImageService? imageService;

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _descriptionController;
  late final ProductImageService _imageService;
  late String _selectedCategory;

  bool _isCapturingImage = false;
  bool _isSaving = false;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _quantityController = TextEditingController(text: '1');
    _descriptionController = TextEditingController();
    _imageService = widget.imageService ?? ProductImageService();
    _selectedCategory = widget.storeCategory;
    _restoreLostCameraImage();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _restoreLostCameraImage() async {
    try {
      final recoveredPath = await _imageService.retrieveLostProductImage();
      if (mounted && recoveredPath != null) {
        setState(() => _imagePath = recoveredPath);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to recover the camera photo: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<String> _categories(Iterable<Product> products) {
    return {
      widget.storeCategory,
      ...products
          .where((product) => product.storeId == widget.storeId)
          .map((product) => product.category),
    }.toList()..sort();
  }

  Future<void> _takePhoto() async {
    if (_isCapturingImage || _isSaving) return;
    setState(() => _isCapturingImage = true);
    try {
      final capturedPath = await _imageService.captureProductImage();
      if (mounted && capturedPath != null) {
        setState(() => _imagePath = capturedPath);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to capture product photo: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCapturingImage = false);
    }
  }

  Future<void> _saveItem() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    final planner = ShoppingPlannerScope.of(context);
    final priceText = _priceController.text.trim().replaceAll(',', '.');
    final product = Product(
      id: 'item_${DateTime.now().microsecondsSinceEpoch}',
      storeId: widget.storeId,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      price: priceText.isEmpty ? 0 : double.parse(priceText),
      description: _descriptionController.text.trim().isEmpty
          ? 'Shopping item'
          : _descriptionController.text.trim(),
      icon: Icons.shopping_basket_rounded,
      imagePath: _imagePath,
    );
    final quantity = int.parse(_quantityController.text.trim());

    setState(() => _isSaving = true);
    try {
      await planner.addProduct(product, quantity: quantity);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save product: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final planner = ShoppingPlannerScope.of(context);
    final categories = _categories(planner.products);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add an item for ${widget.storeName}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  key: const ValueKey('add_item_name'),
                  controller: _nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: AppStrings.itemName,
                    prefixIcon: Icon(Icons.shopping_bag_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Item name is required.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  key: const ValueKey('add_item_description'),
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Description or note (optional)',
                    prefixIcon: Icon(Icons.notes_rounded),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  key: const ValueKey('add_item_category'),
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  key: const ValueKey('add_item_price'),
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Price (optional)',
                    hintText: 'e.g. 15000',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                  validator: (value) {
                    final text = value?.trim().replaceAll(',', '.') ?? '';
                    if (text.isEmpty) return null;
                    final price = double.tryParse(text);
                    if (price == null || !price.isFinite || price < 0) {
                      return 'Enter a valid non-negative price.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  key: const ValueKey('add_item_quantity'),
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    prefixIcon: Icon(Icons.numbers_rounded),
                  ),
                  validator: (value) {
                    final quantity = int.tryParse(value?.trim() ?? '');
                    if (quantity == null || quantity < 1) {
                      return 'Quantity must be at least 1.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    key: const ValueKey('add_item_save'),
                    onPressed: _isSaving ? null : _saveItem,
                    child: _isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Text(AppStrings.saveItem),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
