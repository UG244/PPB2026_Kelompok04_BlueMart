import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import '../../utils/constants.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _authService = AuthService();
  final _productService = ProductService();
  int _totalProducts = 0;
  int _totalStock = 0;
  int _lowStockCount = 0;
  double _totalRevenue = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAccess();
    _loadDashboardData();
  }

  Future<void> _checkAccess() async {
    final isAdmin = await _authService.isAdmin();
    if (!isAdmin && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/user-home', (route) => false);
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final totalProducts = await _productService.getTotalProducts();
      final totalStock = await _productService.getTotalStock();
      final lowStockCount = await _productService.getLowStockCount(
        threshold: AppConstants.lowStockThreshold,
      );
      // Revenue will be loaded from transaction service later (Feature 11)
      // For now, use 0

      if (mounted) {
        setState(() {
          _totalProducts = totalProducts;
          _totalStock = totalStock;
          _lowStockCount = lowStockCount;
          _totalRevenue = 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => Navigator.pushNamed(context, '/map'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary cards
                  _buildSummaryCard(
                    icon: Icons.inventory_2,
                    title: 'Total Produk',
                    value: '$_totalProducts',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryCard(
                    icon: Icons.inventory,
                    title: 'Total Stok',
                    value: '$_totalStock',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryCard(
                    icon: Icons.warning_amber,
                    title: 'Stok Menipis (< ${AppConstants.lowStockThreshold})',
                    value: '$_lowStockCount',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryCard(
                    icon: Icons.monetization_on,
                    title: 'Total Pendapatan',
                    value: 'Rp ${_formatPrice(_totalRevenue)}',
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 24),

                  // Quick actions
                  Text(
                    'Aksi Cepat',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.add_box,
                          label: 'Tambah Produk',
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/admin-product-form',
                              arguments: null,
                            );
                            if (result == true) _loadDashboardData();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.list_alt,
                          label: 'Lihat Produk',
                          onTap: () => Navigator.pushNamed(context, '/admin-products'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.receipt,
                          label: 'Laporan Penjualan',
                          onTap: () => Navigator.pushNamed(context, '/admin-sales-report'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.map,
                          label: 'Lihat Peta',
                          onTap: () => Navigator.pushNamed(context, '/map'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)}.',
        );
  }
}