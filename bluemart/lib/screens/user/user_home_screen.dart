import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/cart_item.dart';
import '../../services/product_service.dart';
import '../../services/cart_service.dart';
import '../../providers/favorite_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/notification_badge.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final _productService = ProductService();
  List<Product> _products = [];
  bool _isLoading = true;
  int _currentBanner = 0;
  final _bannerController = PageController(viewportFraction: 0.92);

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _startBannerAutoScroll();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  void _startBannerAutoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _currentBanner = (_currentBanner + 1) % 3;
        });
        _bannerController.animateToPage(
          _currentBanner,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startBannerAutoScroll();
      }
    });
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await _productService.getActiveProducts();
    if (mounted) {
      setState(() {
        _products = products;
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProducts,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: AppTheme.surface,
                surfaceTintColor: Colors.transparent,
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.store,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BlueMart',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Belanja Hemat & Cepat',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner, size: 22),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/barcode-scanner'),
                    tooltip: 'Scan',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.admin_panel_settings_outlined,
                      size: 22,
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/admin-dashboard'),
                    tooltip: 'Admin Panel',
                  ),
                  const NotificationBadge(),
                  Consumer<CartService>(
                    builder: (context, cart, _) => Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 22,
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/user-cart'),
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

              // Content
              SliverToBoxAdapter(child: _buildBannerSection()),
              SliverToBoxAdapter(child: _buildCategorySection()),
              SliverToBoxAdapter(
                child: _buildSectionHeader('Produk Terbaru 🔥'),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_products.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppTheme.textHint,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada produk tersedia',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildProductCard(_products[index]),
                      childCount: _products.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    final banners = [
      {
        'title': 'Flash Sale Akhir Pekan',
        'subtitle': 'Diskon hingga 70%',
        'badge': 'PROMO HARI INI',
        'color1': AppTheme.primaryDark,
        'color2': AppTheme.accent,
        'icon': Icons.flash_on,
      },
      {
        'title': 'Gadget Terbaru 2026',
        'subtitle': 'Dari brand ternama',
        'badge': 'NEW COLLECTION',
        'color1': const Color(0xFF7C3AED),
        'color2': const Color(0xFFA855F7),
        'icon': Icons.phone_android,
      },
      {
        'title': 'Gratis Ongkir',
        'subtitle': 'Min. belanja Rp 100rb',
        'badge': 'PROMO SPESIAL',
        'color1': AppTheme.accentOrange,
        'color2': const Color(0xFFFDBA74),
        'icon': Icons.local_shipping,
      },
    ];

    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: banners.length,
            onPageChanged: (index) => setState(() => _currentBanner = index),
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [
                      banner['color1'] as Color,
                      banner['color2'] as Color,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (banner['color1'] as Color).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                banner['badge'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              banner['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              banner['subtitle'] as String,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Belanja Sekarang',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        banner['icon'] as IconData,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentBanner == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentBanner == index
                    ? AppTheme.primaryDark
                    : AppTheme.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    final categories = [
      {'icon': Icons.laptop, 'label': 'Laptop', 'color': AppTheme.primaryDark},
      {
        'icon': Icons.phone_android,
        'label': 'HP',
        'color': const Color(0xFF7C3AED),
      },
      {'icon': Icons.headphones, 'label': 'Audio', 'color': AppTheme.accent},
      {
        'icon': Icons.videogame_asset,
        'label': 'Gaming',
        'color': const Color(0xFF059669),
      },
      {
        'icon': Icons.power,
        'label': 'Aksesoris',
        'color': AppTheme.accentOrange,
      },
      {
        'icon': Icons.watch,
        'label': 'Wearable',
        'color': const Color(0xFFDC2626),
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kategori Pilihan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: (cat['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        cat['icon'] as IconData,
                        color: cat['color'] as Color,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['label'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _loadProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final isOutOfStock = product.stock <= 0;
    final isFav = context.watch<FavoriteProvider>().isFavorite(product.id ?? 0);
    final hasDiscount =
        product.discountPercent != null && product.discountPercent! > 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                if (hasDiscount)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${product.discountPercent}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
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
                        size: 16,
                        color: isFav ? AppTheme.error : AppTheme.textHint,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                Row(
                  children: [
                    Text(
                      'Rp ${_formatPrice(product.price)}',
                      style: const TextStyle(
                        color: AppTheme.primaryDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (hasDiscount && product.originalPrice != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        'Rp ${_formatPrice(product.originalPrice!)}',
                        style: const TextStyle(
                          color: AppTheme.textHint,
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
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
                        onTap: () => _addToCart(product),
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
