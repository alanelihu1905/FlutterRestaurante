import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_logic/models/product.dart';
import 'package:shared_logic/services/i_order_repository.dart';

class MenuEditorViewModel extends ChangeNotifier {
  final IOrderRepository _repository;
  final FirebaseFirestore _db;

  bool isLoading = false;
  bool isSaving = false;
  String? error;

  List<Product> products = [];

  StreamSubscription<List<Product>>? _sub;

  MenuEditorViewModel(
    this._repository, {
    FirebaseFirestore? db,
  }) : _db = db ?? FirebaseFirestore.instance {
    _listenProducts();
  }

  void _listenProducts() {
    isLoading = true;
    notifyListeners();

    _sub?.cancel();
    _sub = _repository.watchProducts().listen(
      (items) {
        products = List<Product>.from(items)
          ..sort((a, b) => a.name.compareTo(b.name));
        isLoading = false;
        error = null;
        notifyListeners();
      },
      onError: (e) {
        isLoading = false;
        error = 'Error al cargar productos: $e';
        notifyListeners();
      },
    );
  }

  Future<void> addProduct(Product product) async {
    try {
      isSaving = true;
      notifyListeners();
      await _repository.addProduct(product);
    } catch (e) {
      error = 'Error al crear producto: $e';
      notifyListeners();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      isSaving = true;
      notifyListeners();

      // 🔧 Editar directamente en Firestore
      await _db
          .collection('products')
          .doc(product.id)
          .update(product.toMap());
    } catch (e) {
      error = 'Error al actualizar producto: $e';
      notifyListeners();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(Product product) async {
    try {
      isSaving = true;
      notifyListeners();

      // 🔧 Eliminar directamente en Firestore
      await _db.collection('products').doc(product.id).delete();
    } catch (e) {
      error = 'Error al eliminar producto: $e';
      notifyListeners();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _listenProducts();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}