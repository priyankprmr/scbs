import 'package:equatable/equatable.dart';

import '../../../data/models/customer.dart';

sealed class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

final class CustomerInitial extends CustomerState {
  const CustomerInitial();
}

final class CustomerLoading extends CustomerState {
  const CustomerLoading();
}

final class CustomerLoaded extends CustomerState {
  final List<Customer> customers;

  const CustomerLoaded(this.customers);

  @override
  List<Object?> get props => [customers];
}

final class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}
