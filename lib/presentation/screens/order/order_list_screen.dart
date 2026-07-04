import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/order.dart';
import '../../bloc/order/order_bloc.dart';
import '../../bloc/order/order_event.dart';
import '../../bloc/order/order_state.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/responsive_scaffold.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final _searchController = TextEditingController();
  Order? _selectedOrder;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderBloc>().add(const LoadOrders());
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
      title: 'Orders',
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearch(context),
        ),
      ],
      master: _buildMaster(context),
      detail: tablet ? _buildDetail(context) : null,
    );
  }

  Widget _buildMaster(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) return const LoadingIndicator();
        if (state is OrderError) {
          return Center(child: Text(state.message));
        }
        if (state is OrderLoaded) {
          if (state.orders.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              message: 'No orders yet',
            );
          }
          return ListView.builder(
            itemCount: state.orders.length,
            itemBuilder: (context, index) {
              final order = state.orders[index];
              return _OrderListTile(
                order: order,
                isSelected: _selectedOrder?.id == order.id,
                onTap: () => _selectOrder(context, order),
                onDelete: () => _deleteOrder(context, order),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDetail(BuildContext context) {
    if (_selectedOrder == null) {
      return const Center(child: Text('Select an order'));
    }

    return OrderDetailScreen(order: _selectedOrder!);
  }

  void _selectOrder(BuildContext context, Order order) {
    if (ResponsiveScaffold.isTablet(context)) {
      setState(() => _selectedOrder = order);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(order: order),
        ),
      );
    }
  }

  Future<void> _deleteOrder(BuildContext context, Order order) async {
    final confirm = await showConfirmDialog(
      context: context,
      title: 'Delete Order',
      message: 'Delete ${order.invoiceNo}?',
    );
    if (confirm == true && context.mounted) {
      context.read<OrderBloc>().add(DeleteOrder(order.id));
      if (_selectedOrder?.id == order.id) {
        setState(() => _selectedOrder = null);
      }
    }
  }

  void _showSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Search Orders'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Invoice No, customer name, or phone',
          ),
          autofocus: true,
          onChanged: (query) {
            context.read<OrderBloc>().add(SearchOrders(query));
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              context.read<OrderBloc>().add(const LoadOrders());
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _OrderListTile extends StatelessWidget {
  final Order order;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _OrderListTile({
    required this.order,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      leading: CircleAvatar(
        child: Text(order.invoiceNo.substring(0, 3)),
      ),
      title: Text(order.invoiceNo),
      subtitle: Text(
        '${order.customerName} · ${formatDate(order.date)} · ${formatCurrency(order.grandTotal)}',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
