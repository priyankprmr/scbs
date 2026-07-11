import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'data/hive_setup.dart';
import 'data/repositories/customer_repository.dart';
import 'data/repositories/order_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'presentation/bloc/billing/billing_bloc.dart';
import 'presentation/bloc/customer/customer_bloc.dart';
import 'presentation/bloc/order/order_bloc.dart';
import 'presentation/bloc/product/product_bloc.dart';
import 'presentation/bloc/settings/settings_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final boxes = await HiveSetup.init();

  final customerRepo = CustomerRepository(boxes.customers);
  final productRepo = ProductRepository(boxes.products);
  final orderRepo = OrderRepository(boxes.orders, boxes.settings);
  final settingsRepo = SettingsRepository(boxes.settings);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: customerRepo),
        RepositoryProvider.value(value: productRepo),
        RepositoryProvider.value(value: orderRepo),
        RepositoryProvider.value(value: settingsRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SettingsBloc(settingsRepo)),
          BlocProvider(create: (_) => CustomerBloc(customerRepo)),
          BlocProvider(create: (_) => ProductBloc(productRepo)),
          BlocProvider(create: (_) => OrderBloc(orderRepo)),
          BlocProvider(
            create: (_) => BillingBloc(orderRepo, customerRepo),
          ),
        ],
        child: const App(),
      ),
    ),
  );
}
