import 'package:flutter/material.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _msController = TextEditingController();
  final _moController = TextEditingController();
  final _qty1Controller = TextEditingController();
  final _rate1Controller = TextEditingController();
  final _particular1Controller = TextEditingController();
  final _motorPumpController = TextEditingController();

  @override
  void dispose() {
    _msController.dispose();
    _moController.dispose();
    _qty1Controller.dispose();
    _rate1Controller.dispose();
    _particular1Controller.dispose();
    _motorPumpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Bill')),
      bottomNavigationBar: ElevatedButton(
        onPressed: () {},
        child: const Text('Save Bill'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _Header(),
          const SizedBox(height: 8),
          _CustomerBillInfo(
            msController: _msController,
            moController: _moController,
          ),
          // const SizedBox(height: 4),
          _ItemsTable(
            qty1Controller: _qty1Controller,
            rate1Controller: _rate1Controller,
            particular1Controller: _particular1Controller,
            motorPumpController: _motorPumpController,
          ),
          // const SizedBox(height: 4),
          _Terms(),
          // const SizedBox(height: 4),
          _Total(),
          // const SizedBox(height: 4),
          _Footer(),
          const SizedBox(height: 12),
        ],
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
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'M. 97257 54672',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'SHIVAM AIR COOLER',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(border: Border.all()),
          child: Text(
            'All Type Of Cooler Sales & Service',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Nr. Ramapir Temple, Prakashnagar, Chandlodiya, Ahmedabad.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.red),
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
        ),
        // const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.red),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Bill No. ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('INV-0001'),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Text(
                        'Date ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('04 Jul 2026'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemsTable extends StatelessWidget {
  final TextEditingController qty1Controller;
  final TextEditingController rate1Controller;
  final TextEditingController particular1Controller;
  final TextEditingController motorPumpController;

  const _ItemsTable({
    required this.qty1Controller,
    required this.rate1Controller,
    required this.particular1Controller,
    required this.motorPumpController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.red),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _TableHeader(),
            const Divider(),
            _CoolerRow(
              qtyController: qty1Controller,
              rateController: rate1Controller,
              particularController: particular1Controller,
            ),
            const Divider(height: 1),
            _MotorPumpRow(controller: motorPumpController),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 32, child: Text('No.', style: _s)),
          const Expanded(flex: 3, child: Text('Particulars', style: _s)),
          const SizedBox(width: 40, child: Text('Qty.', style: _s)),
          const SizedBox(width: 60, child: Text('Rate', style: _s)),
          const SizedBox(width: 70, child: Text('Amount', style: _s)),
        ],
      ),
    );
  }

  static const _s = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
}

class _CoolerRow extends StatelessWidget {
  final TextEditingController qtyController;
  final TextEditingController rateController;
  final TextEditingController particularController;

  const _CoolerRow({
    required this.qtyController,
    required this.rateController,
    required this.particularController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 32, child: Text('1')),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Text('\u0a8f\u0ab0 \u0a95\u0ac1\u0ab2\u0ab0 '),
                Expanded(
                  child: TextField(
                    controller: particularController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 40,
            child: TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: TextField(
              controller: rateController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 70, child: Text('—')),
        ],
      ),
    );
  }
}

class _MotorPumpRow extends StatelessWidget {
  final TextEditingController controller;

  const _MotorPumpRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 32, child: Text('2')),
          const SizedBox(width: 12, child: Text(':')),
          Text(
            '\u0aae\u0acb\u0a9f\u0ab0 \u0aaa\u0a82\u0aaa \u0a97\u0ac7\u0ab0\u0a82\u0a9f\u0ac0',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Terms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.red),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\u25cf \u0a97\u0ac7\u0ab0\u0a82\u0a9f\u0ac0 \u0aae\u0abe\u0a82 \u0ab9\u0acb\u0ab5\u0abe \u0a9b\u0aa4\u0abe \u0a9c\u0acb \u0a95\u0ac1\u0ab2\u0ab0 \u0ab0\u0ac0\u0aaa\u0ac7\u0ab0 \u0a95\u0ab0\u0ab5\u0abe \u0aae\u0abe\u0aa3\u0ab8 \u0a98\u0ab0\u0ac7 \u0a86\u0ab5\u0ac7 \u0aa4\u0acb \u0a9a\u0abe\u0ab0\u0acd\u0a9c \u0ab2\u0ac7\u0ab5\u0abe\u0aae\u0abe\u0a82 \u0a86\u0ab5\u0ab6\u0ac7.',
              style: style,
            ),
            const SizedBox(height: 4),
            Text(
              '\u25cf \u0a95\u0ac1\u0ab2\u0ab0 \u0ab0\u0ac0\u0aaa\u0ac7\u0ab0\u0ac0\u0a82\u0a97 \u0a95\u0ab0\u0ab5\u0abe \u0aae\u0abe\u0aa3\u0ab8 \u0a98\u0ab0\u0ac7 \u0aa8\u0ab9\u0ac0\u0a82 \u0a86\u0ab5\u0ac7.',
              style: style,
            ),
            const SizedBox(height: 4),
            Text(
              '\u25cf \u0ab5\u0ac7\u0a9a\u0ac7\u0ab2\u0acb \u0aae\u0abe\u0ab2 \u0aaa\u0abe\u0a9b\u0acb \u0ab2\u0ac7\u0ab5\u0abe\u0aae\u0abe\u0a82 \u0a86\u0ab5\u0ab6\u0ac7 \u0aa8\u0ab9\u0ac0\u0a82.',
              style: style,
            ),
          ],
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.red),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
              style: style?.copyWith(fontWeight: FontWeight.bold),
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
