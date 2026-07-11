import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/cart_item.dart';
import '../../services/product_service.dart';
import '../../services/cart_service.dart';

class UserProductDetailScreen extends StatefulWidget {
  final int productId;
  const UserProductDetailScreen({super.key, required this.productId});

  @override
  State<UserProductDetailScreen> createState() =>
      _UserProductDetailScreenState();
}

class _UserProductDetailScreenState extends State<UserProductDetailScreen> {
  final _productService = ProductService();
  Product? _product;
  bool _isLoading = true;
  bool _isFavorite = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final product = await _productService.getProductById(widget.productId);
    if (mounted) {
      setState(() {
        _product = product;
        _isLoading = false;
      });
    }
  }

  void _addToCart() {
    if (_product == null) return;
    final cart = context.read<CartService>();
    final success = cart.addItem(
      CartItem(
        productId: _product!.id!,
        productName: _product!.name,
        unitPrice: _product!.price,
        quantity: _quantity,
        photoPath: _product!.photoPath,
      ),
      _product!.stock,
    );
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_product!.name} ditambahkan ke keranjang',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF22C55E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock not available'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _directCheckout() {
    if (_product == null) return;
    final cart = context.read<CartService>();
    final success = cart.addItem(
      CartItem(
        productId: _product!.id!,
        productName: _product!.name,
        unitPrice: _product!.price,
        quantity: _quantity,
        photoPath: _product!.photoPath,
      ),
      _product!.stock,
    );
    if (mounted) {
      if (success) {
        Navigator.pushNamed(context, '/user-checkout');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock not available'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Produk')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Produk')),
        body: const Center(child: Text('Produk tidak ditemukan')),
      );
    }

    final p = _product!;
    final isOutOfStock = p.stock <= 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: const Color(0xFFF1F5F9),
                    child: p.photoPath != null && p.photoPath!.isNotEmpty
                        ? Image.file(
                            File(p.photoPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, err, stack) => const Icon(
                              Icons.image,
                              size: 80,
                              color: Color(0xFF94A3B8),
                            ),
                          )
                        : const Icon(
                            Icons.image,
                            size: 80,
                            color: Color(0xFF94A3B8),
                          ),
                  ),
                  if (isOutOfStock)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: const Center(
                        child: Text(
                          'STOK HABIS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      p.category,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Name & Favorite
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite
                              ? const Color(0xFFEC4899)
                              : const Color(0xFF94A3B8),
                        ),
                        onPressed: () {
                          setState(() => _isFavorite = !_isFavorite);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _isFavorite
                                    ? 'Ditambahkan ke favorit'
                                    : 'Dihapus dari favorit',
                              ),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Price
                  Row(
                    children: [
                      Text(
                        'Rp ${_formatPrice(p.price)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      if (p.stock < 5 && !isOutOfStock) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Sisa ${p.stock}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Stock info
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOutOfStock
                            ? 'Stok habis'
                            : 'Stok: ${p.stock} unit tersedia',
                        style: TextStyle(
                          fontSize: 13,
                          color: isOutOfStock
                              ? const Color(0xFFEF4444)
                              : Colors.grey[600],
                          fontWeight: isOutOfStock
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Description
                  const Text(
                    'Deskripsi Produk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.description.isNotEmpty
                        ? p.description
                        : 'Tidak ada deskripsi untuk produk ini.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isOutOfStock
          ? Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1: Quantity Selector & Subtotal Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Jumlah:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              height: 38,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: _quantity > 1
                                        ? () => setState(() => _quantity--)
                                        : null,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Icon(
                                        Icons.remove,
                                        size: 18,
                                        color: _quantity > 1
                                            ? const Color(0xFF1E3A8A)
                                            : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      '$_quantity',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _quantity < p.stock
                                        ? () => setState(() => _quantity++)
                                        : null,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Icon(
                                        Icons.add,
                                        size: 18,
                                        color: _quantity < p.stock
                                            ? const Color(0xFF1E3A8A)
                                            : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Subtotal: Rp ${_formatPrice(p.price * _quantity)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Row 2: Action Buttons (+ Keranjang and Checkout)
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: _addToCart,
                              icon: const Icon(Icons.shopping_cart_outlined, size: 18, color: Color(0xFF1E3A8A)),
                              label: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '+ Keranjang',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _directCheckout,
                              icon: const Icon(Icons.flash_on, size: 18, color: Colors.white),
                              label: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Beli Sekarang',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF22C55E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : null,
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
