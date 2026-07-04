import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _repository;

  OrderBloc(this._repository) : super(const OrderInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<DeleteOrder>(_onDeleteOrder);
    on<SearchOrders>(_onSearchOrders);
  }

  void _onLoadOrders(LoadOrders event, Emitter<OrderState> emit) {
    emit(const OrderLoading());
    try {
      final orders = _repository.getAll();
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onDeleteOrder(
      DeleteOrder event, Emitter<OrderState> emit) async {
    await _repository.delete(event.id);
    add(const LoadOrders());
  }

  void _onSearchOrders(SearchOrders event, Emitter<OrderState> emit) {
    try {
      final results = _repository.search(event.query);
      emit(OrderLoaded(results));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
