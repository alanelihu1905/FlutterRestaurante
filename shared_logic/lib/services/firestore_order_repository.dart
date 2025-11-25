import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

import '../models/product.dart';
import '../models/order.dart';
import 'i_order_repository.dart';

class FirestoreOrderRepository implements IOrderRepository {
  final firestore.FirebaseFirestore _db;

  FirestoreOrderRepository(this._db);

  firestore.CollectionReference<Map<String, dynamic>> get _productsCol =>
      _db.collection('products');

  firestore.CollectionReference<Map<String, dynamic>> get _ordersCol =>
      _db.collection('orders');

  // ---------------------------------------------------------------------------
  // PRODUCTOS
  // ---------------------------------------------------------------------------

  @override
  Stream<List<Product>> watchProducts() {
    return _productsCol.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Future<List<Product>> getMenu() async {
    final snap = await _productsCol.get();
    return snap.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> addProduct(Product product) async {
    // Dejamos que Firestore genere el id
    await _productsCol.add(product.toMap());
  }

  @override
  Future<void> updateProduct(Product product) async {
    if (product.id.isEmpty) return;
    await _productsCol.doc(product.id).set(
          product.toMap(),
          firestore.SetOptions(merge: true),
        );
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _productsCol.doc(productId).delete();
  }

  // ---------------------------------------------------------------------------
  // ÓRDENES
  // ---------------------------------------------------------------------------

  /// Firma alineada con IOrderRepository:
  /// Future<Order> createOrder({
  ///   required String clientId,
  ///   String? clientName,
  ///   required Map<Product,int> items,
  ///   String? note,
  /// })
  @override
  Future<Order> createOrder({
    required String clientId,
    String? clientName,
    required Map<Product, int> items,
    String? note,
  }) async {
    final now = DateTime.now();

    // Creamos una Order temporal solo para usar toMap()
    final tempOrder = Order(
      id: '', // se reemplaza con el doc.id después
      clientId: clientId,
      clientName: clientName,
      items: items,
      status: OrderStatus.pending,
      createdAt: now,
      note: note,
    );

    final data = tempOrder.toMap();

    final docRef = await _ordersCol.add(data);

    // Devolvemos la orden ya con id real
    return Order.fromMap(docRef.id, data);
  }

  /// Historial de un cliente (una sola consulta)
  @override
  Future<List<Order>> getClientOrderHistory(String clientId) async {
    final snap =
        await _ordersCol.where('clientId', isEqualTo: clientId).get();

    final orders = snap.docs
        .map((doc) => Order.fromMap(doc.id, doc.data()))
        .toList();

    // Ordenamos por fecha (más nuevos primero)
    orders.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return orders;
  }

  /// Historial reactivo del cliente (stream)
  @override
  Stream<List<Order>> watchOrdersByClient(String clientId) {
    return _ordersCol
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs
          .map((doc) => Order.fromMap(doc.id, doc.data()))
          .toList();

      orders.sort((a, b) {
        final aDate =
            a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      return orders;
    });
  }

  /// Órdenes por estado (para Cocina).
  /// Sin orderBy en Firestore → no pide índice compuesto.
  @override
  Stream<List<Order>> watchOrdersByStatus(OrderStatus status) {
    return _ordersCol
        .where('status', isEqualTo: status.name)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs
          .map((doc) => Order.fromMap(doc.id, doc.data()))
          .toList();

      orders.sort((a, b) {
        final aDate =
            a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      return orders;
    });
  }

  /// Órdenes activas (pendientes / en preparación / listas)
  @override
  Stream<List<Order>> watchActiveOrders() {
    // Un solo campo con whereIn NO genera índice compuesto
    const activeStatuses = ['pending', 'inPreparation', 'ready'];

    return _ordersCol
        .where('status', whereIn: activeStatuses)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs
          .map((doc) => Order.fromMap(doc.id, doc.data()))
          .toList();

      orders.sort((a, b) {
        final aDate =
            a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      return orders;
    });
  }

  /// Seguimiento en vivo de una orden
  @override
  Stream<Order?> watchOrderById(String orderId) {
    return _ordersCol.doc(orderId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Order.fromMap(doc.id, doc.data()!);
    });
  }

  /// updateOrderStatus alineado con la firma del interface:
  /// Future<void> updateOrderStatus({
  ///   required String orderId,
  ///   required OrderStatus status,
  /// })
  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    await _ordersCol.doc(orderId).update({
      'status': status.name,
      'updatedAt': firestore.FieldValue.serverTimestamp(),
    });
  }

  // ---------------------------------------------------------------------------
  // SEED / UTILIDADES
  // ---------------------------------------------------------------------------

  @override
  Future<void> seedDatabase() async {
    final snap = await _productsCol.limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final demoProducts = <Product>[
      Product(
        id: '', // id se rellena con el de Firestore al leer
        name: 'Agua embotellada',
        description: 'Botella de agua purificada.',
        price: 25,
        category: 'Bebidas',
        imageUrl:
            'https://images.pexels.com/photos/416528/pexels-photo-416528.jpeg',
      ),
      Product(
        id: '',
        name: 'Conga Tropical',
        description: 'Bebida refrescante de frutas tropicales.',
        price: 80,
        category: 'Bebidas',
        imageUrl:
            'https://images.pexels.com/photos/5531523/pexels-photo-5531523.jpeg',
      ),
    ];

    for (final p in demoProducts) {
      await _productsCol.add(p.toMap());
    }
  }
}