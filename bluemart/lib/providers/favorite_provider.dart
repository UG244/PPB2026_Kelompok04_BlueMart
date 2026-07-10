import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FavoriteProvider extends ChangeNotifier {
  final Set<int> _favoriteIds = {};

  Set<int> get favoriteIds => Set.unmodifiable(_favoriteIds);

  bool isFavorite(int productId) => _favoriteIds.contains(productId);

  void toggleFavorite(int productId) {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();
  }

  void removeFavorite(int productId) {
    _favoriteIds.remove(productId);
    notifyListeners();
  }

  int get favoriteCount => _favoriteIds.length;

  List<Product> getFavoriteProducts(List<Product> allProducts) {
    return allProducts
        .where((p) => p.id != null && _favoriteIds.contains(p.id))
        .toList();
  }
}
