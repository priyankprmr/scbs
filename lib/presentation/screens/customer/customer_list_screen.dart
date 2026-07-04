import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/customer.dart';
import '../../bloc/customer/customer_bloc.dart';
import '../../bloc/customer/customer_event.dart';
import '../../bloc/customer/customer_state.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/responsive_scaffold.dart';
import 'customer_form_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _searchController = TextEditingController();
  Customer? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerBloc>().add(const LoadCustomers());
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
      title: 'Customers',
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearch(context),
        ),
      ],
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _openForm(context, null),
      //   child: const Icon(Icons.add),
      // ),
      master: _buildMaster(context),
      detail: tablet ? _buildDetail(context) : null,
    );
  }

  Widget _buildMaster(BuildContext context) {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoading) return const LoadingIndicator();
        if (state is CustomerError) {
          return Center(child: Text(state.message));
        }
        if (state is CustomerLoaded) {
          if (state.customers.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outline,
              message: 'No customers yet',
              // actionLabel: 'Add Customer',
            );
          }
          return ListView.builder(
            itemCount: state.customers.length,
            itemBuilder: (context, index) {
              final customer = state.customers[index];
              return _CustomerListTile(
                customer: customer,
                isSelected: _selectedCustomer?.id == customer.id,
                onTap: () => _selectCustomer(context, customer),
                onDelete: () => _deleteCustomer(context, customer),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDetail(BuildContext context) {
    if (_selectedCustomer == null) {
      return const Center(child: Text('Select a customer'));
    }

    return CustomerFormScreen(customer: _selectedCustomer);
  }

  void _selectCustomer(BuildContext context, Customer customer) {
    if (ResponsiveScaffold.isTablet(context)) {
      setState(() => _selectedCustomer = customer);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<CustomerBloc>(),
            child: CustomerFormScreen(customer: customer),
          ),
        ),
      ).then((_) {
        setState(() => _selectedCustomer = null);
      });
    }
  }

  // void _openForm(BuildContext context, Customer? customer) {
  //   if (ResponsiveScaffold.isTablet(context)) {
  //     setState(() => _selectedCustomer = customer);
  //   } else {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => BlocProvider.value(
  //           value: context.read<CustomerBloc>(),
  //           child: CustomerFormScreen(customer: customer),
  //         ),
  //       ),
  //     ).then((_) {
  //       setState(() => _selectedCustomer = null);
  //     });
  //   }
  // }

  Future<void> _deleteCustomer(BuildContext context, Customer customer) async {
    final confirm = await showConfirmDialog(
      context: context,
      title: 'Delete Customer',
      message: 'Delete ${customer.name}?',
    );
    if (confirm == true && context.mounted) {
      context.read<CustomerBloc>().add(DeleteCustomer(customer.id));
      if (_selectedCustomer?.id == customer.id) {
        setState(() => _selectedCustomer = null);
      }
    }
  }

  void _showSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Search Customers'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Name, phone, or address',
          ),
          autofocus: true,
          onChanged: (query) {
            context.read<CustomerBloc>().add(SearchCustomers(query));
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              context.read<CustomerBloc>().add(const LoadCustomers());
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _CustomerListTile extends StatelessWidget {
  final Customer customer;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CustomerListTile({
    required this.customer,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      title: Text(customer.name),
      subtitle: Text(customer.phone),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
