import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

import 'product.dart';

/// Estados que maneja toda la app (cliente + admin)
enum OrderStatus {
  pending,
  inPreparation,
  ready,
  delivered, // 👈 lo volvemos a agregar para que compile el tracking / historial
}

class Order {
  final String id;
  final String clientId;
  final String? clientName;
  final String? note;
  final Map<Product, int> items;
  final OrderStatus status;
  final DateTime? createdAt;

  Order({
    required this.id,
    required this.clientId,
    this.clientName,
    this.note,
    required this.items,
    required this.status,
    this.createdAt,
  });

  /// Total calculado (para order_summary, tracking, historial, etc.)
  double get totalPrice {
    return items.entries.fold<double>(
      0,
      (sum, e) => sum + e.key.price * e.value,
    );
  }

  factory Order.fromMap(String id, Map<String, dynamic> map) {
    final statusStr = (map['status'] as String?) ?? 'pending';
    final status = OrderStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => OrderStatus.pending,
    );

    DateTime? createdAt;
    final ts = map['createdAt'];
    if (ts is Timestamp) {
      createdAt = ts.toDate();
    }

    final itemsList = (map['items'] as List<dynamic>? ?? []);
    final items = <Product, int>{};

    for (final raw in itemsList) {
      if (raw is Map<String, dynamic>) {
        final product = Product(
          id: raw['productId'] as String? ?? '',
          name: raw['name'] as String? ?? '',
          description: raw['description'] as String? ?? '',
          price: (raw['price'] as num?)?.toDouble() ?? 0,
          category: raw['category'] as String? ?? '',
          imageUrl: raw['imageUrl'] as String? ?? '',
        );
        final qty = raw['quantity'] is int
            ? raw['quantity'] as int
            : (raw['quantity'] as num?)?.toInt() ?? 1;
        items[product] = qty;
      }
    }

    return Order(
      id: id,
      clientId: map['clientId'] as String? ?? '',
      clientName: map['clientName'] as String?,
      note: map['note'] as String? ?? '',
      items: items,
      status: status,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'note': note ?? '',
      'status': status.name,
      'createdAt': createdAt,
      'items': items.entries.map((e) {
        final p = e.key;
        final qty = e.value;
        return {
          'productId': p.id,
          'name': p.name,
          'description': p.description,
          'price': p.price,
          'category': p.category,
          'imageUrl': p.imageUrl,
          'quantity': qty,
        };
      }).toList(),
    };
  }
}