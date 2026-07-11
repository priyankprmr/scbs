import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    _msController.dispose();
    _moController.dispose();
    for (final row in _itemRows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() => _itemRows.add(_ItemRowControllers()));
  }

  void _removeRow(int index) {
    setState(() {
      _itemRows[index].dispose();
      _itemRows.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Bill'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Bill',
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFEFAF6),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _Header(),
            _CustomerBillInfo(
              msController: _msController,
              moController: _moController,
            ),
            _ItemsAndTerms(
              itemRows: _itemRows,
              onAddRow: _addRow,
              onRemoveRow: _removeRow,
            ),
            _Total(),
            _Footer(),
            const SizedBox(height: 12),
          ],
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

  const _CustomerBillInfo({
    required this.msController,
    required this.moController,
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
            child: const Row(
              children: [
                Text(
                  'Date: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '04 Jul 2026',
                  style: TextStyle(fontWeight: FontWeight.bold),
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

  const _ItemsAndTerms({
    required this.itemRows,
    required this.onAddRow,
    required this.onRemoveRow,
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
        '\u25cf \u0aae\u0acb\u0a9f\u0ab0 \u0aaa\u0a82\u0aaa \u0a97\u0ac7\u0ab0\u0a82\u0a9f\u0ac0  6 months',
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
              '\u20B9 —',
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
