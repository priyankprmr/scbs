import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';

part 'order_item.g.dart';

@HiveType(typeId: 2)
class OrderItem extends Equatable {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final int quantity;

  @HiveField(4)
  final double subtotal;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItem.fromProduct({
    required String productId,
    required String productName,
    required double price,
    int quantity = 1,
  }) {
    return OrderItem(
      productId: productId,
      productName: productName,
      price: price,
      quantity: quantity,
      subtotal: price * quantity,
    );
  }

  OrderItem copyWith({int? quantity}) {
    final qty = quantity ?? this.quantity;
    return OrderItem(
      productId: productId,
      productName: productName,
      price: price,
      quantity: qty,
      subtotal: price * qty,
    );
  }

  @override
  List<Object?> get props => [productId, productName, price, quantity, subtotal];
}
