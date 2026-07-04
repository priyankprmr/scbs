import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

part 'product.g.dart';

@HiveType(typeId: 1)
class Product extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.description = '',
    required this.createdAt,
  });

  factory Product.create({
    required String name,
    required double price,
    required String category,
    String description = '',
  }) {
    return Product(
      id: const Uuid().v4(),
      name: name,
      price: price,
      category: category,
      description: description,
      createdAt: DateTime.now(),
    );
  }

  Product copyWith({
    String? name,
    double? price,
    String? category,
    String? description,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, price, category, description, createdAt];
}
