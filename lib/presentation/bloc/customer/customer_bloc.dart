import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/customer_repository.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository _repository;

  CustomerBloc(this._repository) : super(const CustomerInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<AddCustomer>(_onAddCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
    on<SearchCustomers>(_onSearchCustomers);
  }

  void _onLoadCustomers(LoadCustomers event, Emitter<CustomerState> emit) {
    emit(const CustomerLoading());
    try {
      final customers = _repository.getAll();
      emit(CustomerLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onAddCustomer(
      AddCustomer event, Emitter<CustomerState> emit) async {
    await _repository.insert(event.customer);
    add(const LoadCustomers());
  }

  Future<void> _onUpdateCustomer(
      UpdateCustomer event, Emitter<CustomerState> emit) async {
    await _repository.update(event.customer);
    add(const LoadCustomers());
  }

  Future<void> _onDeleteCustomer(
      DeleteCustomer event, Emitter<CustomerState> emit) async {
    await _repository.delete(event.id);
    add(const LoadCustomers());
  }

  void _onSearchCustomers(
      SearchCustomers event, Emitter<CustomerState> emit) {
    try {
      final results = _repository.search(event.query);
      emit(CustomerLoaded(results));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }
}
