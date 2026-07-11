import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/order.dart';
import '../../../data/models/order_item.dart';
import '../../bloc/billing/billing_bloc.dart';
import '../../bloc/billing/billing_event.dart';
import '../../bloc/billing/billing_state.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_event.dart';
import '../../bloc/settings/settings_state.dart';

class _ItemRowControllers {
  final TextEditingController particular = TextEditingController();
  final TextEditingController qty = TextEditingController();
  final TextEditingController rate = TextEditingController();

  String get amount {
    final q = double.tryParse(qty.text);
    final r = double.tryParse(rate.text);
    if (q == null || r == null) return '\u2014';
    return '\u20B9${(q * r).toStringAsFixed(0)}';
  }

  void dispose() {
    particular.dispose();
    qty.dispose();
    rate.dispose();
  }

  OrderItem? toOrderItem() {
    final name = particular.text.trim();
    final q = int.tryParse(qty.text.trim());
    final r = double.tryParse(rate.text.trim());
    if (name.isEmpty || q == null || r == null || q <= 0 || r <= 0) {
      return null;
    }
    return OrderItem(
      productId: '',
      productName: name,
      price: r,
      quantity: q,
      subtotal: r * q,
    );
  }
}

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _msController = TextEditingController();
  final _moController = TextEditingController();
  final List<_ItemRowControllers> _itemRows = [_ItemRowControllers()];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const LoadSettings());
    for (final row in _itemRows) {
      row.qty.addListener(_onRowChanged);
      row.rate.addListener(_onRowChanged);
    }
  }

  @override
  void dispose() {
    _msController.dispose();
    _moController.dispose();
    for (final row in _itemRows) {
      row.qty.removeListener(_onRowChanged);
      row.rate.removeListener(_onRowChanged);
      row.dispose();
    }
    super.dispose();
  }

  void _onRowChanged() {
    setState(() {});
  }

  void _addRow() {
    final newRow = _ItemRowControllers();
    newRow.qty.addListener(_onRowChanged);
    newRow.rate.addListener(_onRowChanged);
    setState(() => _itemRows.add(newRow));
  }

  void _removeRow(int index) {
    setState(() {
      final row = _itemRows[index];
      row.qty.removeListener(_onRowChanged);
      row.rate.removeListener(_onRowChanged);
      row.dispose();
      _itemRows.removeAt(index);
    });
  }

  double _calculateTotal() {
    double total = 0;
    for (final row in _itemRows) {
      final q = double.tryParse(row.qty.text.trim());
      final r = double.tryParse(row.rate.text.trim());
      if (q != null && r != null && q > 0 && r > 0) {
        total += q * r;
      }
    }
    return total;
  }

  String? _validate() {
    final nameError = validateRequired(_msController.text);
    if (nameError != null) return 'Customer name is required';

    final phoneError = validatePhone(_moController.text);
    if (phoneError != null) return phoneError;

    final validRows = _itemRows
        .map((r) => r.toOrderItem())
        .where((oi) => oi != null)
        .toList();
    if (validRows.isEmpty) {
      return 'Please add at least one item with valid particulars, qty, and rate';
    }
    return null;
  }

  void _validateAndSave() {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red.shade700),
      );
      return;
    }

    final items = _itemRows
        .map((r) => r.toOrderItem())
        .where((oi) => oi != null)
        .cast<OrderItem>()
        .toList();

    context.read<BillingBloc>().add(SaveBill(
          customerName: _msController.text,
          customerPhone: _moController.text,
          items: items,
        ));
  }

  void _showSavedPopup(Order order) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 28),
            const SizedBox(width: 8),
            const Text('Bill Saved'),
          ],
        ),
        content: Text(
          'Order ${order.invoiceNo} has been saved successfully.',
          style: theme.textTheme.bodyMedium,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.picture_as_pdf, size: 20),
            label: const Text('View PDF'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFB71C1C),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetForm();
            },
            icon: const Icon(Icons.close, size: 20),
            label: const Text('Close & Reset'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _msController.clear();
      _moController.clear();
      for (final row in _itemRows) {
        row.qty.removeListener(_onRowChanged);
        row.rate.removeListener(_onRowChanged);
        row.dispose();
      }
      _itemRows.clear();
      final newRow = _ItemRowControllers();
      newRow.qty.addListener(_onRowChanged);
      newRow.rate.addListener(_onRowChanged);
      _itemRows.add(newRow);
      _isSaving = false;
    });
    context.read<BillingBloc>().add(const ClearBill());
  }

  @override
  Widget build(BuildContext context) {
    final today = formatDate(DateTime.now());
    final total = _calculateTotal();

    return BlocListener<BillingBloc, BillingState>(
      listener: (context, state) {
        if (state is BillingSaving) {
          setState(() => _isSaving = true);
        } else if (state is BillingSaved) {
          _showSavedPopup(state.order);
        } else if (state is BillingError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
            ),
          );
          context.read<BillingBloc>().add(const ClearBill());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Bill'),
          actions: [
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFB71C1C),
                      ),
                    )
                  : const Icon(Icons.save),
              tooltip: 'Save Bill',
              onPressed: _isSaving ? null : _validateAndSave,
            ),
          ],
        ),
        body: Container(
          color: const Color(0xFFFEFAF6),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    _Header(),
                    _CustomerBillInfo(
                      msController: _msController,
                      moController: _moController,
                      date: today,
                    ),
                    BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (context, state) {
                        final months = state is SettingsLoaded
                            ? state.settings.guaranteeMonths
                            : 6;
                        return _ItemsAndTerms(
                          itemRows: _itemRows,
                          onAddRow: _addRow,
                          onRemoveRow: _removeRow,
                          guaranteeMonths: months,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                child: Column(
                  children: [
                    _Total(total: total),
                    const SizedBox(height: 12,),
                    _Footer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            '\u0965\u0965 \u0ab6\u0acd\u0ab0\u0ac0 \u0a97\u0aa3\u0ac7\u0ab6\u0abe\u0aaf \u0aa8\u0aae\u0a83 \u0965\u0965',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFFB71C1C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'M. 97257 54672',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'SHIVAM AIR COOLER',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: const Color(0xFFB71C1C),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFB71C1C),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'All Type Of Cooler Sales & Service',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Nr. Ramapir Temple, Prakashnagar, Chandlodiya, Ahmedabad.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        const Divider(color: Colors.red, thickness: 1),
      ],
    );
  }
}

class _CustomerBillInfo extends StatelessWidget {
  final TextEditingController msController;
  final TextEditingController moController;
  final String date;

  const _CustomerBillInfo({
    required this.msController,
    required this.moController,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFB71C1C)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Date: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  date,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFB71C1C)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: msController,
                  decoration: const InputDecoration(
                    labelText: 'M/s.',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
                const Divider(),
                TextField(
                  controller: moController,
                  decoration: const InputDecoration(
                    labelText: 'Mo.',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemsAndTerms extends StatelessWidget {
  final List<_ItemRowControllers> itemRows;
  final VoidCallback onAddRow;
  final void Function(int) onRemoveRow;
  final int guaranteeMonths;

  const _ItemsAndTerms({
    required this.itemRows,
    required this.onAddRow,
    required this.onRemoveRow,
    required this.guaranteeMonths,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFB71C1C)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderRow(),
            const SizedBox(height: 6),
            ...List.generate(itemRows.length, (index) {
              return _ItemRow(
                controllers: itemRows[index],
                isLast: index == itemRows.length - 1,
                canRemove: itemRows.length > 1,
                onAdd: onAddRow,
                onRemove: () => onRemoveRow(index),
              );
            }),
            const Divider(height: 16),
            ..._terms(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 13);
    return Row(
      children: [
        const SizedBox(width: 40),
        const Expanded(flex: 4, child: Text('Particulars', style: style)),
        const SizedBox(width: 6),
        const Expanded(flex: 1, child: Text('Qty', style: style, textAlign: TextAlign.center)),
        const SizedBox(width: 6),
        const Expanded(flex: 1, child: Text('Rate', style: style, textAlign: TextAlign.center)),
        const SizedBox(width: 6),
        const Expanded(flex: 1, child: Text('Amount', style: style, textAlign: TextAlign.center)),
      ],
    );
  }

  List<Widget> _terms(BuildContext context) {
    const style = TextStyle(
      color: Color(0xFFB71C1C),
      fontWeight: FontWeight.bold,
      fontSize: 22,
    );
    return [
      Text(
        '\u25cf \u0aae\u0acb\u0a9f\u0ab0 \u0aaa\u0a82\u0aaa \u0a97\u0ac7\u0ab0\u0a82\u0a9f\u0ac0  $guaranteeMonths months',
        style: style,
      ),
      const SizedBox(height: 10),
      Text(
        '\u25cf \u0a97\u0ac7\u0ab0\u0a82\u0a9f\u0ac0 \u0aae\u0abe\u0a82 \u0ab9\u0acb\u0ab5\u0abe \u0a9b\u0aa4\u0abe \u0a9c\u0acb \u0a95\u0ac1\u0ab2\u0ab0 \u0ab0\u0ac0\u0aaa\u0ac7\u0ab0 \u0a95\u0ab0\u0ab5\u0abe \u0aae\u0abe\u0aa3\u0ab8 \u0a98\u0ab0\u0ac7 \u0a86\u0ab5\u0ac7 \u0aa4\u0acb \u0a9a\u0abe\u0ab0\u0acd\u0a9c \u0ab2\u0ac7\u0ab5\u0abe\u0aae\u0abe\u0a82 \u0a86\u0ab5\u0ab6\u0ac7.',
        style: style,
      ),
      const SizedBox(height: 6),
      Text(
        '\u25cf \u0a95\u0ac1\u0ab2\u0ab0 \u0ab0\u0ac0\u0aaa\u0ac7\u0ab0\u0ac0\u0a82\u0a97 \u0a95\u0ab0\u0ab5\u0abe \u0aae\u0abe\u0aa3\u0ab8 \u0a98\u0ab0\u0ac7 \u0aa8\u0ab9\u0ac0\u0a82 \u0a86\u0ab5\u0ac7.',
        style: style,
      ),
      const SizedBox(height: 6),
      Text(
        '\u25cf \u0ab5\u0ac7\u0a9a\u0ac7\u0ab2\u0acb \u0aae\u0abe\u0ab2 \u0aaa\u0abe\u0a9b\u0acb \u0ab2\u0ac7\u0ab5\u0abe\u0aae\u0abe\u0a82 \u0a86\u0ab5\u0ab6\u0ac7 \u0aa8\u0ab9\u0ac0\u0a82.',
        style: style,
      ),
    ];
  }
}

class _ItemRow extends StatefulWidget {
  final _ItemRowControllers controllers;
  final bool isLast;
  final bool canRemove;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _ItemRow({
    required this.controllers,
    required this.isLast,
    required this.canRemove,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<_ItemRow> {
  String _amount = '\u2014';

  @override
  void initState() {
    super.initState();
    _updateAmount();
    widget.controllers.qty.addListener(_updateAmount);
    widget.controllers.rate.addListener(_updateAmount);
  }

  @override
  void didUpdateWidget(covariant _ItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controllers != widget.controllers) {
      oldWidget.controllers.qty.removeListener(_updateAmount);
      oldWidget.controllers.rate.removeListener(_updateAmount);
      widget.controllers.qty.addListener(_updateAmount);
      widget.controllers.rate.addListener(_updateAmount);
      _updateAmount();
    }
  }

  @override
  void dispose() {
    widget.controllers.qty.removeListener(_updateAmount);
    widget.controllers.rate.removeListener(_updateAmount);
    super.dispose();
  }

  void _updateAmount() {
    setState(() => _amount = widget.controllers.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: widget.isLast
                ? IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 22),
                    padding: EdgeInsets.zero,
                    color: const Color(0xFFB71C1C),
                    onPressed: widget.onAdd,
                  )
                : widget.canRemove
                    ? IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 22),
                        padding: EdgeInsets.zero,
                        color: const Color(0xFFB71C1C),
                        onPressed: widget.onRemove,
                      )
                    : const SizedBox.shrink(),
          ),
          Expanded(
            flex: 4,
            child: _EditableField(controller: widget.controllers.particular),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 1,
            child: _EditableField(
              controller: widget.controllers.qty,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 1,
            child: _EditableField(
              controller: widget.controllers.rate,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 1,
            child: Text(
              _amount,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextAlign textAlign;

  const _EditableField({
    required this.controller,
    this.keyboardType,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: textAlign,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFDCBABA)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB71C1C), width: 1.5),
        ),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  final double total;

  const _Total({required this.total});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFB71C1C)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              total > 0 ? formatCurrency(total) : '\u20B9 \u2014',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('\u2022 Subject to Ahmedabad Jurisdiction', style: style),
              Text('\u2022 Fix Rate... Thanks...', style: style),
              Text(
                '\u2022 \u0ab5\u0ac7\u0a9a\u0ac7\u0ab2\u0acb \u0aae\u0abe\u0ab2 \u0aaa\u0abe\u0a9b\u0acb \u0ab2\u0ac7\u0ab5\u0abe\u0aae\u0abe\u0a82 \u0a86\u0ab5\u0ab6\u0ac7 \u0aa8\u0ab9\u0ac0\u0a82.',
                style: style,
              ),
              Text('E.\u0026.O.E.', style: style),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'For, SHIVAM AIR COOLER',
              style: style?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFFB71C1C),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '(Signature)',
              style: TextStyle(decoration: TextDecoration.overline),
            ),
          ],
        ),
      ],
    );
  }
}
