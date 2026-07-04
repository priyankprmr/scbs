import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/order.dart';
import '../../../data/models/order_item.dart';
import '../../../data/repositories/order_repository.dart';
import 'billing_event.dart';
import 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final OrderRepository _orderRepository;

  BillingBloc(this._orderRepository) : super(BillingState.initial()) {
    on<SelectCustomer>(_onSelectCustomer);
    on<AddItem>(_onAddItem);
    on<UpdateItemQty>(_onUpdateItemQty);
    on<RemoveItem>(_onRemoveItem);
    on<SetDiscount>(_onSetDiscount);
    on<ClearBill>(_onClearBill);
    on<SaveBill>(_onSaveBill);
  }

  void _onSelectCustomer(SelectCustomer event, Emitter<BillingState> emit) {
    emit(state.copyWith(selectedCustomer: event.customer));
  }

  void _onAddItem(AddItem event, Emitter<BillingState> emit) {
    final existingIndex =
        state.items.indexWhere((i) => i.productId == event.product.id);

    List<OrderItem> updatedItems;
    if (existingIndex >= 0) {
      updatedItems = List<OrderItem>.from(state.items);
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] =
          existing.copyWith(quantity: existing.quantity + event.quantity);
    } else {
      final newItem = OrderItem.fromProduct(
        productId: event.product.id,
        productName: event.product.name,
        price: event.product.price,
        quantity: event.quantity,
      );
      updatedItems = [...state.items, newItem];
    }

    emit(state.copyWith(items: updatedItems));
  }

  void _onUpdateItemQty(UpdateItemQty event, Emitter<BillingState> emit) {
    if (event.quantity <= 0) {
      add(RemoveItem(event.productId));
      return;
    }
    final updatedItems = state.items.map((item) {
      if (item.productId == event.productId) {
        return item.copyWith(quantity: event.quantity);
      }
      return item;
    }).toList();

    emit(state.copyWith(items: updatedItems));
  }

  void _onRemoveItem(RemoveItem event, Emitter<BillingState> emit) {
    final updatedItems =
        state.items.where((i) => i.productId != event.productId).toList();

    emit(state.copyWith(items: updatedItems));
  }

  void _onSetDiscount(SetDiscount event, Emitter<BillingState> emit) {
    emit(state.copyWith(discount: event.discount));
  }

  void _onClearBill(ClearBill event, Emitter<BillingState> emit) {
    emit(BillingState.initial());
  }

  Future<void> _onSaveBill(
      SaveBill event, Emitter<BillingState> emit) async {
    if (!state.canSave) return;

    emit(state.copyWith(isSaving: true, error: null));

    try {
      final invoiceNo = _orderRepository.generateInvoiceNo();

      final order = Order.create(
        invoiceNo: invoiceNo,
        customerId: state.selectedCustomer!.id,
        customerName: state.selectedCustomer!.name,
        customerPhone: state.selectedCustomer!.phone,
        items: state.items,
        discount: state.discount,
        notes: event.notes ?? '',
      );

      await _orderRepository.insert(order);

      emit(state.copyWith(
        isSaving: false,
        savedOrder: order,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        error: e.toString(),
      ));
    }
  }
}
