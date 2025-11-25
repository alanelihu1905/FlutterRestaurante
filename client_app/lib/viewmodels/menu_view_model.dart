import 'package:flutter/foundation.dart';

import 'package:shared_logic/models/product.dart';
import 'package:shared_logic/services/i_order_repository.dart';

class MenuViewModel extends ChangeNotifier {
  final IOrderRepository _repository;

  MenuViewModel(this._repository) {
    _loadMenu();
    _listenToMenuChanges();
  }

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Lista ordenada por categoría y luego por nombre
  List<Product> get sortedProducts {
    final list = List<Product>.from(_products);
    list.sort((a, b) {
      final catA =
          (a.category.isEmpty ? 'Otros' : a.category).toLowerCase();
      final catB =
          (b.category.isEmpty ? 'Otros' : b.category).toLowerCase();

      final catCmp = catA.compareTo(catB);
      if (catCmp != 0) return catCmp;

      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
  }

  /// Productos agrupados por categoría (ya ordenados internamente)
  Map<String, List<Product>> get productsByCategory {
    final map = <String, List<Product>>{};
    for (final p in sortedProducts) {
      final cat = p.category.isEmpty ? 'Otros' : p.category;
      map.putIfAbsent(cat, () => []).add(p);
    }
    return map;
  }

  void _listenToMenuChanges() {
    _repository.watchProducts().listen((products) {
      _products = products;
      notifyListeners();
    }, onError: (e) {
      debugPrint('Error en watchProducts: $e');
    });
  }

  Future<void> _loadMenu() async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await _repository.getMenu();
      _error = null;
    } catch (e) {
      debugPrint('Error al cargar menú: $e');
      _error = 'Error al cargar el menú';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}