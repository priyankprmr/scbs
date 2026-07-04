import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/order_item.dart';
import '../../../data/models/product.dart';
import '../../bloc/billing/billing_bloc.dart';
import '../../bloc/billing/billing_event.dart';
import '../../bloc/billing/billing_state.dart';
import '../../bloc/customer/customer_bloc.dart';
import '../../bloc/customer/customer_event.dart';
import '../../bloc/customer/customer_state.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../../widgets/bill_summary_card.dart';
import '../../widgets/empty_state.dart';
import '../order/order_detail_screen.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _discountController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<CustomerBloc>()),
        BlocProvider.value(value: context.read<ProductBloc>()),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('New Bill')),
        body: BlocBuilder<BillingBloc, BillingState>(
          builder: (context, state) {
            if (state.isSaving) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.savedOrder != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _onBillSaved(context, state);
              });
            }

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _CustomerSection(state: state),
                      const SizedBox(height: 16),
                      _ItemsSection(state: state),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _discountController,
                        decoration: const InputDecoration(
                          labelText: 'Discount',
                          prefixText: '\u{20B9} ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (v) {
                          final d = double.tryParse(v) ?? 0;
                          context
                              .read<BillingBloc>()
                              .add(SetDiscount(d));
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration:
                            const InputDecoration(labelText: 'Notes'),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                BillSummaryCard(state: state),
                _ActionBar(state: state, notesController: _notesController),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onBillSaved(BuildContext context, BillingState state) {
    final savedOrder = state.savedOrder!;
    context.read<BillingBloc>().add(const ClearBill());
    _discountController.clear();
    _notesController.clear();
    _showSuccessDialog(context, savedOrder);
  }

  void _showSuccessDialog(BuildContext context, dynamic savedOrder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bill Saved'),
        content: Text('${savedOrder.invoiceNo} saved successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue Billing'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(order: savedOrder),
                ),
              );
            },
            child: const Text('View Invoice'),
          ),
        ],
      ),
    );
  }
}

class _CustomerSection extends StatelessWidget {
  final BillingState state;

  const _CustomerSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Customer',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => _selectCustomer(context),
                  icon: const Icon(Icons.person_add),
                  label: Text(
                      state.selectedCustomer != null ? 'Change' : 'Select'),
                ),
              ],
            ),
            if (state.selectedCustomer != null) ...[
              const Divider(),
              Text(state.selectedCustomer!.name,
                  style: Theme.of(context).textTheme.bodyLarge),
              Text(state.selectedCustomer!.phone),
            ],
          ],
        ),
      ),
    );
  }

  void _selectCustomer(BuildContext context) {
    context.read<CustomerBloc>().add(const LoadCustomers());
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _CustomerPicker(onSelect: (customer) {
          context.read<BillingBloc>().add(SelectCustomer(customer));
          Navigator.pop(context);
        }),
      ),
    );
  }
}

class _CustomerPicker extends StatefulWidget {
  final void Function(Customer) onSelect;

  const _CustomerPicker({required this.onSelect});

  @override
  State<_CustomerPicker> createState() => _CustomerPickerState();
}

class _CustomerPickerState extends State<_CustomerPicker> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Customer')),
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CustomerLoaded) {
            if (state.customers.isEmpty) {
              return const EmptyState(
                icon: Icons.people_outline,
                message: 'No customers',
              );
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search customers...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (q) => context
                        .read<CustomerBloc>()
                        .add(SearchCustomers(q)),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.customers.length,
                    itemBuilder: (context, index) {
                      final c = state.customers[index];
                      return ListTile(
                        title: Text(c.name),
                        subtitle: Text(c.phone),
                        onTap: () => widget.onSelect(c),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          if (state is CustomerError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ItemsSection extends StatelessWidget {
  final BillingState state;

  const _ItemsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Items',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => _addItem(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            if (state.items.isNotEmpty) ...[
              const Divider(),
              ...state.items.map((item) => _ItemRow(
                    item: item,
                    onQtyChanged: (qty) {
                      context
                          .read<BillingBloc>()
                          .add(UpdateItemQty(item.productId, qty));
                    },
                    onRemove: () {
                      context
                          .read<BillingBloc>()
                          .add(RemoveItem(item.productId));
                    },
                  )),
            ],
          ],
        ),
      ),
    );
  }

  void _addItem(BuildContext context) {
    context.read<ProductBloc>().add(const LoadProducts());
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _ProductPicker(onSelect: (product, qty) {
          context
              .read<BillingBloc>()
              .add(AddItem(product, quantity: qty));
          Navigator.pop(context);
        }),
      ),
    );
  }
}

class _ProductPicker extends StatefulWidget {
  final void Function(Product product, int qty) onSelect;

  const _ProductPicker({required this.onSelect});

  @override
  State<_ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends State<_ProductPicker> {
  final _searchController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');

  @override
  void dispose() {
    _searchController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProductLoaded) {
            if (state.products.isEmpty) {
              return const EmptyState(
                icon: Icons.inventory_2_outlined,
                message: 'No products',
              );
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search products...',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (q) => context
                              .read<ProductBloc>()
                              .add(SearchProducts(q)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _qtyController,
                          decoration:
                              const InputDecoration(labelText: 'Qty'),
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            final q = int.tryParse(v);
                            if (q != null && q > 0) {
                              _qtyController.text = q.toString();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final p = state.products[index];
                      return ListTile(
                        title: Text(p.name),
                        subtitle: Text(
                            '${p.category} \u2014 ${formatCurrency(p.price)}'),
                        onTap: () {
                          final qty =
                              int.tryParse(_qtyController.text) ?? 1;
                          widget.onSelect(p, qty);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
          if (state is ProductError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final OrderItem item;
  final void Function(int) onQtyChanged;
  final VoidCallback onRemove;

  const _ItemRow({
    required this.item,
    required this.onQtyChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: Theme.of(context).textTheme.bodyLarge),
                Text(formatCurrency(item.price),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          SizedBox(
            width: 44,
            child: IconButton(
              icon:
                  const Icon(Icons.remove_circle_outline, size: 20),
              onPressed: () => onQtyChanged(item.quantity - 1),
              padding: EdgeInsets.zero,
            ),
          ),
          SizedBox(
            width: 30,
            child: Text('${item.quantity}',
                textAlign: TextAlign.center),
          ),
          SizedBox(
            width: 44,
            child: IconButton(
              icon:
                  const Icon(Icons.add_circle_outline, size: 20),
              onPressed: () => onQtyChanged(item.quantity + 1),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 8),
          Text(formatCurrency(item.subtotal),
              style: Theme.of(context).textTheme.bodyMedium),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 20, color: Colors.red),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final BillingState state;
  final TextEditingController notesController;

  const _ActionBar({
    required this.state,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: state.items.isNotEmpty
                    ? () => context
                        .read<BillingBloc>()
                        .add(const ClearBill())
                    : null,
                child: const Text('Clear'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: state.canSave
                    ? () => context.read<BillingBloc>().add(
                          SaveBill(notes: notesController.text.trim()),
                        )
                    : null,
                child: const Text('Save Bill'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
