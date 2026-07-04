import 'package:equatable/equatable.dart';

import '../../../data/models/customer.dart';
import '../../../data/models/order_item.dart';
import '../../../data/models/product.dart';

sealed class BillingEvent extends Equatable {
  const BillingEvent();

  @override
  List<Object?> get props => [];
}

final class SelectCustomer extends BillingEvent {
  final Customer customer;

  const SelectCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

final class AddItem extends BillingEvent {
  final Product product;
  final int quantity;

  const AddItem(this.product, {this.quantity = 1});

  @override
  List<Object?> get props => [product, quantity];
}

final class UpdateItemQty extends BillingEvent {
  final String productId;
  final int quantity;

  const UpdateItemQty(this.productId, this.quantity);

  @override
  List<Object?> get props => [productId, quantity];
}

final class RemoveItem extends BillingEvent {
  final String productId;

  const RemoveItem(this.productId);

  @override
  List<Object?> get props => [productId];
}

final class SetDiscount extends BillingEvent {
  final double discount;

  const SetDiscount(this.discount);

  @override
  List<Object?> get props => [discount];
}

final class ClearBill extends BillingEvent {
  const ClearBill();
}

final class SaveBill extends BillingEvent {
  final String? notes;

  const SaveBill({this.notes});

  @override
  List<Object?> get props => [notes];
}
