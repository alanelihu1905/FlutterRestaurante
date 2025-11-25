import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_logic/models/order.dart' as app;

class OrdersHistoryViewModel extends ChangeNotifier {
  final FirebaseFirestore _db;

  bool isLoading = false;
  String? error;

  List<app.Order> orders = [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  OrdersHistoryViewModel({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance {
    _listen();
  }

  void _listen() {
    isLoading = true;
    notifyListeners();

    _sub?.cancel();

    _sub = _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        orders = snapshot.docs
            .map((d) => app.Order.fromMap(d.id, d.data()))
            .toList();
        isLoading = false;
        error = null;
        notifyListeners();
      },
      onError: (e) {
        isLoading = false;
        error = 'Error al cargar historial: $e';
        notifyListeners();
      },
    );
  }

  Future<void> refresh() async {
    _listen();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}