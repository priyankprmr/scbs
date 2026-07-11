import 'package:equatable/equatable.dart';

import '../../../data/models/order.dart';

sealed class BillingState extends Equatable {
  const BillingState();

  @override
  List<Object?> get props => [];
}

final class BillingInitial extends BillingState {
  const BillingInitial();
}

final class BillingSaving extends BillingState {
  const BillingSaving();
}

final class BillingSaved extends BillingState {
  final Order order;

  const BillingSaved(this.order);

  @override
  List<Object?> get props => [order];
}

final class BillingError extends BillingState {
  final String message;

  const BillingError(this.message);

  @override
  List<Object?> get props => [message];
}
