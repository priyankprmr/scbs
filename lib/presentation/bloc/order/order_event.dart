import 'package:equatable/equatable.dart';

sealed class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

final class LoadOrders extends OrderEvent {
  const LoadOrders();
}

final class DeleteOrder extends OrderEvent {
  final String id;

  const DeleteOrder(this.id);

  @override
  List<Object?> get props => [id];
}

final class SearchOrders extends OrderEvent {
  final String query;

  const SearchOrders(this.query);

  @override
  List<Object?> get props => [query];
}
