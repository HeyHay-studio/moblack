import 'package:flutter/material.dart';

import '../../core/models/product_record.dart';

class CartItem {
  final ProductRecord product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartManager extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(
    0,
    (sum, item) => sum + ((item.product.price ?? 0) * item.quantity),
  );

  void addToCart(ProductRecord product) {
    final existingIndex = _items.indexWhere(
      (i) => i.product.publicId == product.publicId,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  CartItem removeFromCart(int index) {
    final removedItem = _items.removeAt(index);
    notifyListeners();
    return removedItem;
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void updateQuantity(String productId, int delta) {
    final index = _items.indexWhere(
      (item) => item.product.publicId == productId,
    );
    if (index != -1) {
      final newQuantity = _items[index].quantity + delta;

      if (newQuantity <= 0) {
        removeFromCart(index);
      } else {
        _items[index].quantity = newQuantity;
        notifyListeners();
      }
    }
  }
}

final cartManager = CartManager();
