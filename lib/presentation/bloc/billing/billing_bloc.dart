import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/customer.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/order_repository.dart';
import 'billing_event.dart';
import 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final OrderRepository _orderRepository;
  final CustomerRepository _customerRepository;

  BillingBloc(this._orderRepository, this._customerRepository)
      : super(const BillingInitial()) {
    on<SaveBill>(_onSaveBill);
    on<ClearBill>(_onClearBill);
  }

  Future<void> _onSaveBill(
      SaveBill event, Emitter<BillingState> emit) async {
    emit(const BillingSaving());

    try {
      final customers =
          _customerRepository.search(event.customerPhone.trim());
      final existingCustomer = customers
          .where((c) => c.phone.trim() == event.customerPhone.trim())
          .firstOrNull;

      String customerId;
      if (existingCustomer != null) {
        customerId = existingCustomer.id;
      } else {
        final newCustomer = Customer.create(
          name: event.customerName.trim(),
          phone: event.customerPhone.trim(),
        );
        await _customerRepository.insert(newCustomer);
        customerId = newCustomer.id;
      }

      final invoiceNo = _orderRepository.generateInvoiceNo();

      final order = Order.create(
        invoiceNo: invoiceNo,
        customerId: customerId,
        customerName: event.customerName.trim(),
        customerPhone: event.customerPhone.trim(),
        items: event.items,
        discount: 0,
      );

      await _orderRepository.insert(order);

      emit(BillingSaved(order));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  void _onClearBill(ClearBill event, Emitter<BillingState> emit) {
    emit(const BillingInitial());
  }
}
