import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_dimens.dart';
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
                const SizedBox(height: 16),
                _buildCameraPreview(context),
                const SizedBox(height: 16),
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
                  minLines: 4,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
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

  Widget _buildCameraPreview(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Material(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: const ValueKey('add_item_camera_preview'),
              onTap: _isCapturingImage || _isSaving ? null : _takePhoto,
              child: _imagePath != null
                  ? _buildCapturedImagePreview(colorScheme, theme)
                  : _buildPlaceholderPreview(colorScheme, theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderPreview(ColorScheme colorScheme, ThemeData theme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: _CameraViewfinderPainter(
            color: colorScheme.outline.withValues(alpha: 0.35),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: _isCapturingImage
                  ? SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    )
                  : Icon(
                      Icons.camera_alt_rounded,
                      size: 32,
                      color: colorScheme.onPrimaryContainer,
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              _isCapturingImage ? 'Opening camera...' : 'Camera Preview',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to capture product photo',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Text(
              '4:3',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCapturedImagePreview(ColorScheme colorScheme, ThemeData theme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          File(_imagePath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: colorScheme.surfaceContainerHighest,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.broken_image_rounded,
                    size: 40,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load captured photo',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 64,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: const Text(
              '4:3',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton.filledTonal(
                key: const ValueKey('add_item_retake_photo'),
                tooltip: 'Retake photo',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isCapturingImage || _isSaving ? null : _takePhoto,
                icon: _isCapturingImage
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded, size: 20),
              ),
              const SizedBox(width: 6),
              IconButton.filledTonal(
                key: const ValueKey('add_item_remove_photo'),
                tooltip: 'Remove photo',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isSaving
                    ? null
                    : () {
                        setState(() => _imagePath = null);
                      },
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CameraViewfinderPainter extends CustomPainter {
  const _CameraViewfinderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 16.0;
    const padding = 20.0;

    // Top-left
    canvas.drawLine(
      const Offset(padding, padding + cornerLength),
      const Offset(padding, padding),
      paint,
    );
    canvas.drawLine(
      const Offset(padding, padding),
      const Offset(padding + cornerLength, padding),
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(size.width - padding - cornerLength, padding),
      Offset(size.width - padding, padding),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - padding, padding),
      Offset(size.width - padding, padding + cornerLength),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(padding, size.height - padding - cornerLength),
      Offset(padding, size.height - padding),
      paint,
    );
    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(padding + cornerLength, size.height - padding),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - padding - cornerLength, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - padding, size.height - padding),
      Offset(size.width - padding, size.height - padding - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CameraViewfinderPainter oldDelegate) =>
      oldDelegate.color != color;
}
