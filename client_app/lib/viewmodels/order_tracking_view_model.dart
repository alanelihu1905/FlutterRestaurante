import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';
import 'package:shared_logic/models/order.dart';
import 'package:shared_logic/services/i_order_repository.dart';

class OrderTrackingViewModel extends ChangeNotifier {
  final String orderId;
  final FirebaseFirestore _db;

  bool isLoading = true;
  String? error;
  Order? currentOrder;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  OrderTrackingViewModel(
    IOrderRepository repository, {
    required this.orderId,
    FirebaseFirestore? db,
  }) : _db = db ?? FirebaseFirestore.instance {
    _listenToOrder();
  }

  void _listenToOrder() {
    isLoading = true;
    error = null;
    notifyListeners();

    _sub?.cancel();
    _sub = _db.collection('orders').doc(orderId).snapshots().listen(
      (doc) {
        if (!doc.exists) {
          currentOrder = null;
          error = 'No encontramos tu pedido.';
        } else {
          final data = doc.data();
          if (data != null) {
            currentOrder = Order.fromMap(doc.id, data);
            error = null;
          } else {
            currentOrder = null;
            error = 'Los datos del pedido están vacíos.';
          }
        }
        isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        isLoading = false;
        error = 'Error al cargar el pedido: $e';
        currentOrder = null;
        notifyListeners();
      },
    );
  }

  Future<void> refresh() async {
    _listenToOrder();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}