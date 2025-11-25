import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_logic/models/order.dart';
import 'package:shared_logic/services/i_order_repository.dart';

class KitchenViewModel extends ChangeNotifier {
  final IOrderRepository _repository;

  KitchenViewModel(this._repository) {
    _listenToOrders();
  }

  List<Order> _orders = [];
  List<Order> get orders => List.unmodifiable(_orders);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  StreamSubscription<List<Order>>? _sub;

  void _listenToOrders() {
    _isLoading = true;
    notifyListeners();

    _sub = _repository.watchActiveOrders().listen(
      (data) {
        _orders = data;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> refresh() async {
    await _sub?.cancel();
    _listenToOrders();
  }

  Future<void> updateOrderStatus(
    Order order,
    OrderStatus newStatus,
  ) async {
    try {
      await _repository.updateOrderStatus(
        orderId: order.id,
        status: newStatus,
      );

      // 👇 En vez de usar copyWith, simplemente recargamos las órdenes
      await refresh();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}