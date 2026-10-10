import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/store_model.dart';

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
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.storeToEdit?.name ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.storeToEdit?.category ?? 'Supermarket',
    );
    _descriptionController = TextEditingController(
      text: widget.storeToEdit?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
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

    if (widget.storeToEdit != null) {
      final updatedStore = widget.storeToEdit!.copyWith(
        name: name,
        category: category.isEmpty ? 'General' : category,
        description: description.isEmpty ? 'Shopping place' : description,
      );
      widget.onStoreUpdated?.call(updatedStore);
    } else {
      final newStore = Store(
        id: 'store_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        category: category.isEmpty ? 'General' : category,
        description: description.isEmpty ? 'Custom shopping place' : description,
        icon: Icons.storefront_rounded,
        createdAt: DateTime.now(),
        note: '',
      );
      widget.onStoreAdded?.call(newStore);
    }

    Navigator.pop(context);
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
              widget.storeToEdit != null ? 'Edit Store' : AppStrings.addNewStore,
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
                labelText: AppStrings.storeName,
                prefixIcon: Icon(Icons.storefront_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: AppStrings.storeCategory,
                prefixIcon: Icon(Icons.category_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: AppStrings.storeDescription,
                prefixIcon: Icon(Icons.notes_rounded),
              ),
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
                child: Text(
                  widget.storeToEdit != null ? 'Save Changes' : AppStrings.saveStore,
                  style: const TextStyle(
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
