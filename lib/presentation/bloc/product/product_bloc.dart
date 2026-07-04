import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _repository;

  ProductBloc(this._repository) : super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<SearchProducts>(_onSearchProducts);
  }

  void _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) {
    emit(const ProductLoading());
    try {
      final products = _repository.getAll();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onAddProduct(
      AddProduct event, Emitter<ProductState> emit) async {
    await _repository.insert(event.product);
    add(const LoadProducts());
  }

  Future<void> _onUpdateProduct(
      UpdateProduct event, Emitter<ProductState> emit) async {
    await _repository.update(event.product);
    add(const LoadProducts());
  }

  Future<void> _onDeleteProduct(
      DeleteProduct event, Emitter<ProductState> emit) async {
    await _repository.delete(event.id);
    add(const LoadProducts());
  }

  void _onSearchProducts(
      SearchProducts event, Emitter<ProductState> emit) {
    try {
      final results = _repository.search(event.query);
      emit(ProductLoaded(results));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
