import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../services/cart_service.dart';
import '../../providers/favorite_provider.dart';
import '../../models/cart_item.dart';
import '../../utils/app_theme.dart';

class UserCatalogScreen extends StatefulWidget {
  const UserCatalogScreen({super.key});

  @override
  State<UserCatalogScreen> createState() => _UserCatalogScreenState();
}

class _UserCatalogScreenState extends State<UserCatalogScreen> {
  final _productService = ProductService();
  List<Product> _allProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _sortBy = 'terbaru';

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

  List<String> get _categories {
    final cats = _allProducts.map((p) => p.category).toSet().toList();
    cats.sort();
    return ['Semua', ...cats];
  }

  List<Product> get _filteredProducts {
    var result = _allProducts;
    if (_selectedCategory != 'Semua') {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    switch (_sortBy) {
      case 'termurah':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'termahal':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'nama':
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      default:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return result;
  }

  void _addToCart(Product product) {
    final cart = context.read<CartService>();
    final success = cart.addItem(
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
          content: Text(
            success
                ? '${product.name} ditambahkan ke keranjang'
                : 'Stok tidak mencukupi',
          ),
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
      appBar: AppBar(
        title: const Text('Katalog Produk'),
        actions: [
          Consumer<CartService>(
            builder: (context, cart, _) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => Navigator.pushNamed(context, '/user-cart'),
                ),
                if (cart.uniqueItemCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${cart.uniqueItemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // Filters row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              cat,
                              style: const TextStyle(fontSize: 12),
                            ),
                            selected: isSelected,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = cat),
                            selectedColor: AppTheme.primaryDark,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortBy,
                      icon: const Icon(Icons.sort, size: 20),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'terbaru',
                          child: Text('Terbaru'),
                        ),
                        DropdownMenuItem(
                          value: 'termurah',
                          child: Text('Termurah'),
                        ),
                        DropdownMenuItem(
                          value: 'termahal',
                          child: Text('Termahal'),
                        ),
                        DropdownMenuItem(value: 'nama', child: Text('Nama')),
                      ],
                      onChanged: (v) =>
                          setState(() => _sortBy = v ?? 'terbaru'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Product grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Produk tidak ditemukan',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return _ProductGridCard(
                          product: product,
                          onAddToCart: () => _addToCart(product),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const _ProductGridCard({required this.product, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.stock <= 0;
    final isFav = context.watch<FavoriteProvider>().isFavorite(product.id ?? 0);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: AppTheme.surfaceVariant,
                  child:
                      product.photoPath != null && product.photoPath!.isNotEmpty
                      ? Image.file(
                          File(product.photoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(Icons.image, size: 48, color: Colors.grey),
                ),
                if (isOutOfStock)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: Text(
                        'HABIS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                // Favorite button
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => context
                        .read<FavoriteProvider>()
                        .toggleFavorite(product.id ?? 0),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFav ? AppTheme.error : AppTheme.textHint,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${_formatPrice(product.price)}',
                  style: const TextStyle(
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (product.stock < 5 && !isOutOfStock)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Sisa ${product.stock}',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.accentOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else if (!isOutOfStock)
                      Text(
                        'Stok: ${product.stock}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textHint,
                        ),
                      ),
                    const Spacer(),
                    if (!isOutOfStock)
                      InkWell(
                        onTap: onAddToCart,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryDark,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
