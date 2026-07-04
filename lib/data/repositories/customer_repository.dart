import 'package:hive_ce/hive.dart';

import '../models/customer.dart';

class CustomerRepository {
  final Box<Customer> _box;

  CustomerRepository(this._box);

  List<Customer> getAll() => _box.values.toList();

  Customer? getById(String id) => _box.get(id);

  Future<void> insert(Customer customer) => _box.put(customer.id, customer);

  Future<void> update(Customer customer) => _box.put(customer.id, customer);

  Future<void> delete(String id) => _box.delete(id);

  List<Customer> search(String query) {
    if (query.isEmpty) return getAll();
    final lower = query.toLowerCase();
    return _box.values.where((c) {
      return c.name.toLowerCase().contains(lower) ||
          c.phone.toLowerCase().contains(lower) ||
          c.address.toLowerCase().contains(lower);
    }).toList();
  }
}
