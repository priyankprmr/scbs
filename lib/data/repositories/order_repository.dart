import 'package:hive_ce/hive.dart';

import '../models/order.dart';
import '../models/settings.dart';

class OrderRepository {
  final Box<Order> _box;
  final Box<Settings> _settingsBox;

  OrderRepository(this._box, this._settingsBox);

  List<Order> getAll() => _box.values.toList();

  Order? getById(String id) => _box.get(id);

  Future<void> insert(Order order) => _box.put(order.id, order);

  Future<void> delete(String id) => _box.delete(id);

  List<Order> search(String query) {
    if (query.isEmpty) return getAll();
    final lower = query.toLowerCase();
    return _box.values.where((o) {
      return o.invoiceNo.toLowerCase().contains(lower) ||
          o.customerName.toLowerCase().contains(lower) ||
          o.customerPhone.toLowerCase().contains(lower);
    }).toList();
  }

  String generateInvoiceNo() {
    final settings = _settingsBox.get('singleton');
    if (settings == null) return 'INV-0001';
    final nextCounter = settings.invoiceCounter + 1;
    final padded = nextCounter.toString().padLeft(4, '0');
    final invoiceNo = '${settings.invoicePrefix}-$padded';
    _settingsBox.put(
      'singleton',
      settings.copyWith(invoiceCounter: nextCounter),
    );
    return invoiceNo;
  }
}
