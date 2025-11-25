import 'package:flutter/foundation.dart';
import 'package:shared_logic/models/order.dart';
import 'package:shared_logic/models/product.dart';
import 'package:shared_logic/services/i_order_repository.dart';

/// Tipo de servicio para el cliente
enum ServiceType { pickUp, dineIn }

extension ServiceTypeLabel on ServiceType {
  String get label {
    switch (this) {
      case ServiceType.pickUp:
        return 'Para recoger';
      case ServiceType.dineIn:
        return 'Para comer aquí';
    }
  }
}

class CartViewModel extends ChangeNotifier {
  final IOrderRepository _repository;

  /// ID que usamos para identificar al cliente
  String clientId;

  /// Nombre que mostramos en la UI
  String clientName;

  /// Nota especial para la cocina
  String note = '';

  /// Tipo de servicio elegido
  ServiceType _serviceType = ServiceType.pickUp;

  final Map<Product, int> _items = {};

  bool isCreatingOrder = false;

  CartViewModel(
    this._repository, {
    required this.clientId,
    required this.clientName,
  });

  // ================= GETTERS =================

  Map<Product, int> get items => Map.unmodifiable(_items);

  int get totalItems =>
      _items.values.fold<int>(0, (sum, qty) => sum + qty);

  double get total => _items.entries.fold<double>(
        0,
        (sum, e) => sum + e.key.price * e.value,
      );

  ServiceType get serviceType => _serviceType;

  // ================= MUTADORES =================

  void addToCart(Product product) {
    if (_items.containsKey(product)) {
      _items[product] = _items[product]! + 1;
    } else {
      _items[product] = 1;
    }
    notifyListeners();
  }

  void addProduct(Product product) => addToCart(product);

  void removeProduct(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  void increment(Product product) {
    if (_items.containsKey(product)) {
      _items[product] = _items[product]! + 1;
      notifyListeners();
    }
  }

  void decrement(Product product) {
    if (!_items.containsKey(product)) return;
    final current = _items[product]!;
    if (current <= 1) {
      _items.remove(product);
    } else {
      _items[product] = current - 1;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    note = '';
    notifyListeners();
  }

  void updateNote(String value) {
    note = value;
    notifyListeners();
  }

  void updateClientName(String value) {
    clientName = value;
    notifyListeners();
  }

  void updateClientId(String value) {
    clientId = value;
    notifyListeners();
  }

  void updateServiceType(ServiceType type) {
    _serviceType = type;
    notifyListeners();
  }

  // ================= CREAR PEDIDO =================

  Future<Order> createOrder() async {
    if (_items.isEmpty) {
      throw Exception('El carrito está vacío');
    }

    isCreatingOrder = true;
    notifyListeners();

    try {
      final order = await _repository.createOrder(
        clientId: clientId,
        clientName: clientName,
        note: note,
        items: _items,
      );

      clear();
      isCreatingOrder = false;
      notifyListeners();
      return order;
    } catch (e) {
      isCreatingOrder = false;
      notifyListeners();
      rethrow;
    }
  }
}