import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  List<CartItem> get selectedItems => _items.where((i) => i.isSelected).toList();
  
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  int get selectedItemCount => selectedItems.fold(0, (sum, item) => sum + item.quantity);
  
  int get uniqueItemCount => _items.length;

  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.subtotal);
  
  double get selectedTotalPrice =>
      selectedItems.fold(0.0, (sum, item) => sum + item.subtotal);
      
  bool get isAllSelected => _items.isNotEmpty && _items.every((i) => i.isSelected);

  bool get isEmpty => _items.isEmpty;

  /// Add a product to cart or increase quantity if already present.
  /// Returns true if added successfully, false if stock limit exceeded.
  bool addItem(CartItem newItem, int maxStock) {
    final existingIndex = _items.indexWhere(
      (item) => item.productId == newItem.productId,
    );

    if (existingIndex >= 0) {
      final current = _items[existingIndex];
      if (current.quantity + newItem.quantity > maxStock) {
        return false; // Cannot exceed available stock
      }
      _items[existingIndex] = CartItem(
        productId: current.productId,
        productName: current.productName,
        unitPrice: current.unitPrice,
        quantity: current.quantity + newItem.quantity,
        photoPath: current.photoPath,
        isSelected: current.isSelected,
      );
    } else {
      if (newItem.quantity > maxStock) return false;
      _items.add(newItem);
    }

    notifyListeners();
    return true;
  }

  /// Update quantity of a specific item.
  /// If quantity <= 0, remove the item.
  void updateQuantity(int productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      _items[index] = CartItem(
        productId: _items[index].productId,
        productName: _items[index].productName,
        unitPrice: _items[index].unitPrice,
        quantity: newQuantity,
        photoPath: _items[index].photoPath,
        isSelected: _items[index].isSelected,
      );
      notifyListeners();
    }
  }

  /// Remove item from cart.
  void removeItem(int productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  /// Clear the entire cart.
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
  
  void removeSelectedItems() {
    _items.removeWhere((item) => item.isSelected);
    notifyListeners();
  }
  
  void toggleSelection(int productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      final current = _items[index];
      _items[index] = CartItem(
        productId: current.productId,
        productName: current.productName,
        unitPrice: current.unitPrice,
        quantity: current.quantity,
        photoPath: current.photoPath,
        isSelected: !current.isSelected,
      );
      notifyListeners();
    }
  }
  
  void selectAll(bool select) {
    for (int i = 0; i < _items.length; i++) {
      final current = _items[i];
      _items[i] = CartItem(
        productId: current.productId,
        productName: current.productName,
        unitPrice: current.unitPrice,
        quantity: current.quantity,
        photoPath: current.photoPath,
        isSelected: select,
      );
    }
    notifyListeners();
  }
}