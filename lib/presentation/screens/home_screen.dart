import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SCBS'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: _crossAxisCount(context),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _Tile(
              icon: Icons.receipt_long,
              label: 'New Bill',
              color: Colors.green,
              onTap: () => Navigator.pushNamed(context, '/billing'),
            ),
            _Tile(
              icon: Icons.people,
              label: 'Customers',
              color: Colors.blue,
              onTap: () => Navigator.pushNamed(context, '/customers'),
            ),
            // _Tile(
            //   icon: Icons.inventory_2,
            //   label: 'Products',
            //   color: Colors.orange,
            //   onTap: () => Navigator.pushNamed(context, '/products'),
            // ),
            _Tile(
              icon: Icons.history,
              label: 'Orders',
              color: Colors.purple,
              onTap: () => Navigator.pushNamed(context, '/orders'),
            ),
            _Tile(
              icon: Icons.settings,
              label: 'Settings',
              color: Colors.grey,
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
      ),
    );
  }

  int _crossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return 5;
    if (width >= 600) return 3;
    return 2;
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
