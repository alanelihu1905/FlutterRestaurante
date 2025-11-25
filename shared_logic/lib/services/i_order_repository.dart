import 'package:shared_logic/models/order.dart';
import 'package:shared_logic/models/product.dart';

/// Contrato que usan client_app y admin_app
abstract class IOrderRepository {
  // ======== PRODUCTOS ========

  /// Stream en vivo de productos (para menú en cliente / admin)
  Stream<List<Product>> watchProducts();

  /// Menú completo (una sola vez)
  Future<List<Product>> getMenu();

  /// Agregar producto (admin)
  Future<void> addProduct(Product product);

  // ======== ÓRDENES (CLIENTE) ========

  Future<Order> createOrder({
    required String clientId,
    String? clientName,
    String? note,
    required Map<Product, int> items,
  });

  /// Órdenes de un cliente (stream en vivo)
  Stream<List<Order>> watchOrdersByClient(String clientId);

  /// Historial del cliente (fetch una vez)
  Future<List<Order>> getClientOrderHistory(String clientId);

  // ======== ÓRDENES (COCINA / ADMIN) ========

  /// Órdenes activas (pendientes + en preparación)
  Stream<List<Order>> watchActiveOrders();

  /// Seguimiento de una orden por id
  Stream<Order?> watchOrderById(String orderId);

  /// Actualizar estado
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  });

  /// Para sembrar datos de ejemplo (si quieres)
  Future<void> seedDatabase();
}