import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/validators.dart';
import '../../../data/models/product.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';

const List<String> _categories = [
  'Desert Cooler',
  'Personal Cooler',
  'Tower Cooler',
  'Parts',
];

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late String _selectedCategory;
  final _formKey = GlobalKey<FormState>();

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product != null ? widget.product!.price.toString() : '',
    );
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _selectedCategory = widget.product?.category ?? _categories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProductBloc>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: validateRequired,
              autofocus: !isEdit,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixText: '₹ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: validatePrice,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) _selectedCategory = v;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _save(bloc),
              child: Text(isEdit ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _save(ProductBloc bloc) {
    if (!_formKey.currentState!.validate()) return;

    final price = double.parse(_priceController.text.trim());

    if (isEdit) {
      bloc.add(UpdateProduct(widget.product!.copyWith(
        name: _nameController.text.trim(),
        price: price,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
      )));
    } else {
      bloc.add(AddProduct(Product.create(
        name: _nameController.text.trim(),
        price: price,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
      )));
    }

    Navigator.pop(context);
  }
}
