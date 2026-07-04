import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../core/constants/app_constants.dart';
import 'models/customer.dart';
import 'models/order.dart';
import 'models/order_item.dart';
import 'models/product.dart';
import 'models/settings.dart';

class HiveSetup {
  HiveSetup._();

  static Future<HiveBoxes> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(CustomerAdapter());
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(OrderItemAdapter());
    Hive.registerAdapter(OrderAdapter());
    Hive.registerAdapter(SettingsAdapter());

    final customersBox = await Hive.openBox<Customer>(boxCustomers);
    final productsBox = await Hive.openBox<Product>(boxProducts);
    final ordersBox = await Hive.openBox<Order>(boxOrders);
    final settingsBox = await Hive.openBox<Settings>(boxSettings);

    if (settingsBox.isEmpty) {
      await settingsBox.put('singleton', Settings.defaults());
    }

    return HiveBoxes(
      customers: customersBox,
      products: productsBox,
      orders: ordersBox,
      settings: settingsBox,
    );
  }
}

class HiveBoxes {
  final Box<Customer> customers;
  final Box<Product> products;
  final Box<Order> orders;
  final Box<Settings> settings;

  const HiveBoxes({
    required this.customers,
    required this.products,
    required this.orders,
    required this.settings,
  });
}
