import 'package:equatable/equatable.dart';

import '../../../data/models/customer.dart';
import '../../../data/models/order.dart';
import '../../../data/models/order_item.dart';

final class BillingState extends Equatable {
  final Customer? selectedCustomer;
  final List<OrderItem> items;
  final double discount;
  final bool isSaving;
  final Order? savedOrder;
  final String? error;

  const BillingState({
    this.selectedCustomer,
    this.items = const [],
    this.discount = 0,
    this.isSaving = false,
    this.savedOrder,
    this.error,
  });

  double get subtotal =>
      items.fold<double>(0, (sum, item) => sum + item.subtotal);

  double get grandTotal => subtotal - discount;

  bool get canSave =>
      selectedCustomer != null && items.isNotEmpty && !isSaving;

  BillingState copyWith({
    Customer? selectedCustomer,
    List<OrderItem>? items,
    double? discount,
    bool? isSaving,
    Order? savedOrder,
    String? error,
    bool clearCustomer = false,
    bool clearSavedOrder = false,
  }) {
    return BillingState(
      selectedCustomer:
          clearCustomer ? null : (selectedCustomer ?? this.selectedCustomer),
      items: items ?? this.items,
      discount: discount ?? this.discount,
      isSaving: isSaving ?? this.isSaving,
      savedOrder:
          clearSavedOrder ? null : (savedOrder ?? this.savedOrder),
      error: error,
    );
  }

  factory BillingState.initial() => const BillingState();

  @override
  List<Object?> get props => [
        selectedCustomer,
        items,
        discount,
        isSaving,
        savedOrder,
        error,
      ];
}
