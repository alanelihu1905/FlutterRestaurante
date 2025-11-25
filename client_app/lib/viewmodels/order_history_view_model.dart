import 'package:flutter/foundation.dart';
import 'package:shared_logic/models/order.dart';
import 'package:shared_logic/services/i_order_repository.dart';

class OrderHistoryViewModel extends ChangeNotifier {
  final IOrderRepository _repository;
  final String clientId;

  bool isLoading = false;
  String? error;
  List<Order> orders = [];

  OrderHistoryViewModel(
    this._repository, {
    required this.clientId,
  }) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      orders = await _repository.getClientOrderHistory(clientId);
      // sort seguro aunque createdAt sea null
      orders.sort((a, b) {
        final ad = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });
      notifyListeners();
    } catch (e) {
      error = 'Error al cargar historial: $e';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadHistory();
}