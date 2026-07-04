import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

import 'order_item.dart';

part 'order.g.dart';

@HiveType(typeId: 3)
class Order extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String invoiceNo;

  @HiveField(2)
  final String customerId;

  @HiveField(3)
  final String customerName;

  @HiveField(4)
  final String customerPhone;

  @HiveField(5)
  final List<OrderItem> items;

  @HiveField(6)
  final double subtotal;

  @HiveField(7)
  final double discount;

  @HiveField(8)
  final double grandTotal;

  @HiveField(9)
  final DateTime date;

  @HiveField(10)
  final String notes;

  const Order({
    required this.id,
    required this.invoiceNo,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    required this.grandTotal,
    required this.date,
    this.notes = '',
  });

  factory Order.create({
    required String invoiceNo,
    required String customerId,
    required String customerName,
    required String customerPhone,
    required List<OrderItem> items,
    double discount = 0,
    String notes = '',
  }) {
    final subtotal =
        items.fold<double>(0, (sum, item) => sum + item.subtotal);
    final grandTotal = subtotal - discount;
    return Order(
      id: const Uuid().v4(),
      invoiceNo: invoiceNo,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      items: items,
      subtotal: subtotal,
      discount: discount,
      grandTotal: grandTotal,
      date: DateTime.now(),
      notes: notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNo,
        customerId,
        customerName,
        customerPhone,
        items,
        subtotal,
        discount,
        grandTotal,
        date,
        notes,
      ];
}
