import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../providers/favorite_provider.dart';
import '../../services/cart_service.dart';
import '../../models/cart_item.dart';
import '../../utils/app_theme.dart';

class UserFavoriteScreen extends StatefulWidget {
  const UserFavoriteScreen({super.key});

  @override
  State<UserFavoriteScreen> createState() => _UserFavoriteScreenState();
}

class _UserFavoriteScreenState extends State<UserFavoriteScreen> {
  final _productService = ProductService();
  List<Product> _allProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await _productService.getActiveProducts();
    if (mounted) {
      setState(() {
        _allProducts = products;
        _isLoading = false;
      });
    }
  }

  void _addToCart(Product product) {
    final cart = context.read<CartService>();
    cart.addItem(
      CartItem(
        productId: product.id!,
        productName: product.name,
        unitPrice: product.price,
        quantity: 1,
        photoPath: product.photoPath,
      ),
      product.stock,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} ditambahkan ke keranjang'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produk Favorit')),
      body: Consumer<FavoriteProvider>(
        builder: (context, favProvider, _) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final favorites = favProvider.getFavoriteProducts(_allProducts);

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 80,
                    color: AppTheme.textHint.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada favorit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tekan ikon hati pada produk untuk menambahkannya',
                    style: TextStyle(color: AppTheme.textHint),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadProducts,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final product = favorites[index];
                return _FavoriteItemCard(
                  product: product,
                  onAddToCart: () => _addToCart(product),
                  onRemove: () => favProvider.removeFavorite(product.id ?? 0),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _FavoriteItemCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onRemove;

  const _FavoriteItemCard({
    required this.product,
    required this.onAddToCart,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: product.photoPath != null && product.photoPath!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(product.photoPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image, color: Colors.grey),
                      ),
                    )
                  : const Icon(Icons.image, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textHint,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${_formatPrice(product.price)}',
                    style: const TextStyle(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.error,
                    size: 20,
                  ),
                  onPressed: onRemove,
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: onAddToCart,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)}.',
        );
  }
}
