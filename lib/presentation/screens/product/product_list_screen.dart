import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/product.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/responsive_scaffold.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  Product? _selectedProduct;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().add(const LoadProducts());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tablet = ResponsiveScaffold.isTablet(context);

    return ResponsiveScaffold(
      title: 'Products',
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearch(context),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, null),
        child: const Icon(Icons.add),
      ),
      master: _buildMaster(context),
      detail: tablet ? _buildDetail(context) : null,
    );
  }

  Widget _buildMaster(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) return const LoadingIndicator();
        if (state is ProductError) {
          return Center(child: Text(state.message));
        }
        if (state is ProductLoaded) {
          if (state.products.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_2_outlined,
              message: 'No products yet',
              actionLabel: 'Add Product',
            );
          }
          return ListView.builder(
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              return _ProductListTile(
                product: product,
                isSelected: _selectedProduct?.id == product.id,
                onTap: () => _selectProduct(context, product),
                onDelete: () => _deleteProduct(context, product),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDetail(BuildContext context) {
    if (_selectedProduct == null) {
      return const Center(child: Text('Select a product'));
    }

    return ProductFormScreen(product: _selectedProduct);
  }

  void _selectProduct(BuildContext context, Product product) {
    if (ResponsiveScaffold.isTablet(context)) {
      setState(() => _selectedProduct = product);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<ProductBloc>(),
            child: ProductFormScreen(product: product),
          ),
        ),
      ).then((_) {
        setState(() => _selectedProduct = null);
      });
    }
  }

  void _openForm(BuildContext context, Product? product) {
    if (ResponsiveScaffold.isTablet(context)) {
      setState(() => _selectedProduct = product);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<ProductBloc>(),
            child: ProductFormScreen(product: product),
          ),
        ),
      ).then((_) {
        setState(() => _selectedProduct = null);
      });
    }
  }

  Future<void> _deleteProduct(BuildContext context, Product product) async {
    final confirm = await showConfirmDialog(
      context: context,
      title: 'Delete Product',
      message: 'Delete ${product.name}?',
    );
    if (confirm == true) {
      context.read<ProductBloc>().add(DeleteProduct(product.id));
      if (_selectedProduct?.id == product.id) {
        setState(() => _selectedProduct = null);
      }
    }
  }

  void _showSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Search Products'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Name or category',
          ),
          autofocus: true,
          onChanged: (query) {
            context.read<ProductBloc>().add(SearchProducts(query));
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              context.read<ProductBloc>().add(const LoadProducts());
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProductListTile({
    required this.product,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      title: Text(product.name),
      subtitle: Text('${product.category} — ${formatCurrency(product.price)}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
