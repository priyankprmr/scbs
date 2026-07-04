import 'package:hive_ce/hive.dart';

import '../models/product.dart';

class ProductRepository {
  final Box<Product> _box;

  ProductRepository(this._box);

  List<Product> getAll() => _box.values.toList();

  Product? getById(String id) => _box.get(id);

  Future<void> insert(Product product) => _box.put(product.id, product);

  Future<void> update(Product product) => _box.put(product.id, product);

  Future<void> delete(String id) => _box.delete(id);

  List<Product> search(String query) {
    if (query.isEmpty) return getAll();
    final lower = query.toLowerCase();
    return _box.values.where((p) {
      return p.name.toLowerCase().contains(lower) ||
          p.category.toLowerCase().contains(lower);
    }).toList();
  }
}
