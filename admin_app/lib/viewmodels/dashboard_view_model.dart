import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_logic/models/order.dart' as app;
import 'package:shared_logic/models/product.dart';

class DashboardViewModel extends ChangeNotifier {
  final FirebaseFirestore _db;

  bool isLoading = false;
  String? error;

  double todayRevenue = 0;
  int todayOrdersCount = 0;
  int pendingCount = 0;
  int inPreparationCount = 0;
  int readyCount = 0;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  DashboardViewModel({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance {
    loadTodaySummary();
  }

  DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> loadTodaySummary() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final start = _startOfToday();

      final query = _db
          .collection('orders')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          )
          .orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      double revenue = 0;
      int totalOrders = 0;
      int pending = 0;
      int inPrep = 0;
      int ready = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final order = app.Order.fromMap(doc.id, data);

        totalOrders++;

        // 🔹 items es Map<Product, int>
        double orderTotal = 0;
        order.items.forEach((Product product, int qty) {
          orderTotal += product.price * qty;
        });
        revenue += orderTotal;

        switch (order.status) {
          case app.OrderStatus.pending:
            pending++;
            break;
          case app.OrderStatus.inPreparation:
            inPrep++;
            break;
          case app.OrderStatus.ready:
          case app.OrderStatus.delivered: // lo contamos como listo
            ready++;
            break;
        }
      }

      todayRevenue = revenue;
      todayOrdersCount = totalOrders;
      pendingCount = pending;
      inPreparationCount = inPrep;
      readyCount = ready;
      isLoading = false;
      error = null;
      notifyListeners();

      _listenRealtime(start);
    } catch (e) {
      isLoading = false;
      error = 'Error al cargar datos del dashboard: $e';
      notifyListeners();
    }
  }

  void _listenRealtime(DateTime start) {
    _sub?.cancel();

    final query = _db
        .collection('orders')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .orderBy('createdAt', descending: true);

    _sub = query.snapshots().listen(
      (snapshot) {
        double revenue = 0;
        int totalOrders = 0;
        int pending = 0;
        int inPrep = 0;
        int ready = 0;

        for (final doc in snapshot.docs) {
          final order = app.Order.fromMap(doc.id, doc.data());

          totalOrders++;

          double orderTotal = 0;
          order.items.forEach((Product product, int qty) {
            orderTotal += product.price * qty;
          });
          revenue += orderTotal;

          switch (order.status) {
            case app.OrderStatus.pending:
              pending++;
              break;
            case app.OrderStatus.inPreparation:
              inPrep++;
              break;
            case app.OrderStatus.ready:
            case app.OrderStatus.delivered:
              ready++;
              break;
          }
        }

        todayRevenue = revenue;
        todayOrdersCount = totalOrders;
        pendingCount = pending;
        inPreparationCount = inPrep;
        readyCount = ready;
        isLoading = false;
        error = null;
        notifyListeners();
      },
      onError: (e) {
        error = 'Error en tiempo real: $e';
        notifyListeners();
      },
    );
  }

  Future<void> refresh() async {
    await loadTodaySummary();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}