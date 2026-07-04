import 'package:equatable/equatable.dart';

import '../../../data/models/customer.dart';

sealed class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

final class LoadCustomers extends CustomerEvent {
  const LoadCustomers();
}

final class AddCustomer extends CustomerEvent {
  final Customer customer;

  const AddCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

final class UpdateCustomer extends CustomerEvent {
  final Customer customer;

  const UpdateCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

final class DeleteCustomer extends CustomerEvent {
  final String id;

  const DeleteCustomer(this.id);

  @override
  List<Object?> get props => [id];
}

final class SearchCustomers extends CustomerEvent {
  final String query;

  const SearchCustomers(this.query);

  @override
  List<Object?> get props => [query];
}
