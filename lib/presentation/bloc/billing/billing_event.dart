import 'package:equatable/equatable.dart';

import '../../../data/models/order_item.dart';

sealed class BillingEvent extends Equatable {
  const BillingEvent();

  @override
  List<Object?> get props => [];
}

final class SaveBill extends BillingEvent {
  final String customerName;
  final String customerPhone;
  final List<OrderItem> items;

  const SaveBill({
    required this.customerName,
    required this.customerPhone,
    required this.items,
  });

  @override
  List<Object?> get props => [customerName, customerPhone, items];
}

final class ClearBill extends BillingEvent {
  const ClearBill();
}
