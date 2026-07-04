import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/billing/billing_screen.dart';
import 'presentation/screens/customer/customer_list_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/order/order_list_screen.dart';
import 'presentation/screens/product/product_list_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCBS',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/customers': (_) => const CustomerListScreen(),
        '/products': (_) => const ProductListScreen(),
        '/billing': (_) => const BillingScreen(),
        '/orders': (_) => const OrderListScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
