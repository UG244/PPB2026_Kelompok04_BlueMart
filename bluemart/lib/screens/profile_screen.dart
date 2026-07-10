import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../models/app_user.dart';
import '../providers/favorite_provider.dart';
import '../utils/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  AppUser? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isAdmin = _user?.role == 'admin';
    final cartCount = context.watch<CartService>().uniqueItemCount;
    final favCount = context.watch<FavoriteProvider>().favoriteCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showSettingsSheet,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // VIP Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: isAdmin
                    ? [const Color(0xFFF59E0B), const Color(0xFFF97316)]
                    : [AppTheme.primaryDark, AppTheme.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (isAdmin ? const Color(0xFFF59E0B) : AppTheme.primaryDark)
                          .withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _user?.username ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isAdmin ? 'Administrator' : 'Premium Member',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isAdmin ? 'ADMIN' : 'MEMBER',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pesanan',
                  '12',
                  Icons.receipt_long,
                  AppTheme.primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Keranjang',
                  '$cartCount',
                  Icons.shopping_cart,
                  AppTheme.accentOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Favorit',
                  '$favCount',
                  Icons.favorite,
                  AppTheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Menu Section
          const Text(
            'Aktivitas Belanja',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _buildMenuItem(
                  Icons.receipt_long_outlined,
                  'Riwayat Pesanan',
                  'Monitor pengiriman',
                  () {
                    Navigator.pushNamed(context, '/user-orders');
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildMenuItem(
                  Icons.location_on_outlined,
                  'Buku Alamat Pengiriman',
                  'Atur alamat utama',
                  null,
                ),
                const Divider(height: 1, indent: 56),
                _buildMenuItem(
                  Icons.qr_code,
                  'Pembayaran QRIS',
                  'Scan QR saat checkout',
                  null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Admin Section
          if (isAdmin) ...[
            const Text(
              'Pengelola & Sistem',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.admin_panel_settings,
                    'Admin Panel',
                    'Kelola toko & produk',
                    () {
                      Navigator.pushNamed(context, '/admin-dashboard');
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    Icons.help_outline,
                    'Pusat Bantuan & FAQ',
                    'Bantuan dan pertanyaan',
                    null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Logout
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, color: AppTheme.error),
              label: const Text(
                'Logout',
                style: TextStyle(color: AppTheme.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textHint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 22, color: AppTheme.primaryDark),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppTheme.textHint),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 20,
        color: AppTheme.textHint,
      ),
      onTap: onTap,
    );
  }
}

class _SettingsSheet extends StatefulWidget {
  const _SettingsSheet();

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  bool _pushNotif = true;
  bool _orderUpdate = true;
  bool _promoNotif = false;
  bool _biometricLock = false;
  bool _compactMode = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pengaturan Akun',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: AppTheme.accent, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Akun terverifikasi',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Premium',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Notifikasi',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildSwitchTile(
            'Push Notification',
            'Terima notifikasi push',
            _pushNotif,
            (v) => setState(() => _pushNotif = v),
          ),
          _buildSwitchTile(
            'Update Pesanan',
            'Notifikasi status pesanan',
            _orderUpdate,
            (v) => setState(() => _orderUpdate = v),
          ),
          _buildSwitchTile(
            'Promo & Voucher',
            'Info promo dan diskon',
            _promoNotif,
            (v) => setState(() => _promoNotif = v),
          ),
          const SizedBox(height: 16),
          const Text(
            'Keamanan & Tampilan',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildSwitchTile(
            'Kunci Biometrik',
            'Buka dengan sidik jari',
            _biometricLock,
            (v) => setState(() => _biometricLock = v),
          ),
          _buildSwitchTile(
            'Mode Ringkas',
            'Tampilan lebih ringkas',
            _compactMode,
            (v) => setState(() => _compactMode = v),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pengaturan disimpan'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Simpan Pengaturan'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textHint,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryDark,
          ),
        ],
      ),
    );
  }
}
