import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/cart_service.dart';
import '../../services/auth_service.dart';
import '../../services/transaction_service.dart';
import '../../utils/app_theme.dart';

class UserCheckoutScreen extends StatefulWidget {
  const UserCheckoutScreen({super.key});

  @override
  State<UserCheckoutScreen> createState() => _UserCheckoutScreenState();
}

class _UserCheckoutScreenState extends State<UserCheckoutScreen> {
  bool _isProcessing = false;
  String? _resultMessage;
  bool _success = false;
  String _selectedPayment = 'QRIS';
  String _selectedShipping = 'JNE YES';
  String _promoCode = '';

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'QRIS',
      'name': 'QRIS',
      'icon': Icons.qr_code,
      'color': const Color(0xFF0EA5E9),
    },
    {
      'id': 'BCA',
      'name': 'Transfer BCA',
      'icon': Icons.account_balance,
      'color': const Color(0xFF005BAC),
    },
    {
      'id': 'MANDIRI',
      'name': 'Transfer Mandiri',
      'icon': Icons.account_balance,
      'color': const Color(0xFF00843D),
    },
    {
      'id': 'DANA',
      'name': 'DANA',
      'icon': Icons.wallet,
      'color': const Color(0xFF00B3A6),
    },
    {
      'id': 'OVO',
      'name': 'OVO',
      'icon': Icons.wallet,
      'color': const Color(0xFF4A21A3),
    },
    {
      'id': 'GOPAY',
      'name': 'GoPay',
      'icon': Icons.wallet,
      'color': const Color(0xFF00AEE0),
    },
    {
      'id': 'COD',
      'name': 'COD (Bayar di Tempat)',
      'icon': Icons.money,
      'color': const Color(0xFFF97316),
    },
  ];

  final List<Map<String, dynamic>> _shippingMethods = [
    {
      'id': 'JNE YES',
      'name': 'JNE YES',
      'cost': 50000,
      'est': '1-2 Hari',
      'icon': Icons.flash_on,
    },
    {
      'id': 'JNE REG',
      'name': 'JNE Reguler',
      'cost': 25000,
      'est': '3-5 Hari',
      'icon': Icons.local_shipping,
    },
    {
      'id': 'J&T',
      'name': 'J&T Express',
      'cost': 20000,
      'est': '3-5 Hari',
      'icon': Icons.local_shipping,
    },
    {
      'id': 'SICEPAT',
      'name': 'SiCepat',
      'cost': 22000,
      'est': '2-4 Hari',
      'icon': Icons.local_shipping,
    },
    {
      'id': 'GOSEND',
      'name': 'GoSend Instant',
      'cost': 35000,
      'est': 'Same Day',
      'icon': Icons.motorcycle,
    },
    {
      'id': 'GRAB',
      'name': 'Grab Express',
      'cost': 38000,
      'est': 'Same Day',
      'icon': Icons.motorcycle,
    },
  ];

  double get _shippingCost {
    final method = _shippingMethods.firstWhere(
      (s) => s['id'] == _selectedShipping,
      orElse: () => {'cost': 0},
    );
    return (method['cost'] as num).toDouble();
  }

  double get _taxRate => 0.11;
  double get _taxAmount {
    final cart = context.read<CartService>();
    return cart.totalPrice * _taxRate;
  }

  bool _hasPromo = false;
  double _discountAmount = 0;

  void _applyPromo() {
    if (_promoCode.toLowerCase() == 'bluemart10') {
      setState(() {
        _hasPromo = true;
        _discountAmount = 100000;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Promo berhasil diterapkan!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (_promoCode.toLowerCase() == 'gratisongkir') {
      setState(() {
        _hasPromo = true;
        _discountAmount = _shippingCost;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Promo gratis ongkir diterapkan!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kode promo tidak valid'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _confirmCheckout() async {
    final cart = context.read<CartService>();
    final authService = AuthService();
    final transactionService = TransactionService();

    final user = await authService.getCurrentUser();
    if (user == null) return;

    setState(() {
      _isProcessing = true;
      _resultMessage = null;
    });

    final total =
        cart.totalPrice + _shippingCost + _taxAmount - _discountAmount;
    final result = await transactionService.checkout(
      buyerUsername: user.username,
      cartItems: cart.items,
      totalAmount: total,
    );

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _success = result['success'] as bool;
        _resultMessage = result['message'] as String?;
      });
      if (_success) {
        cart.clearCart();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Pesanan')),
      body: Consumer<CartService>(
        builder: (context, cart, _) {
          if (_resultMessage != null && _success) {
            return _buildSuccessState();
          }
          if (_resultMessage != null && !_success) {
            return _buildErrorState();
          }

          final grandTotal =
              cart.totalPrice + _shippingCost + _taxAmount - _discountAmount;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Products
              const Text(
                'Produk yang Dibeli',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: cart.items
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.quantity} x Rp ${_formatPrice(item.unitPrice)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textHint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Rp ${_formatPrice(item.subtotal)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Address
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: AppTheme.primaryDark,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Rumah',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Jl. Merdeka No. 10, Denpasar',
                    style: TextStyle(fontSize: 12, color: AppTheme.textHint),
                  ),
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text('Ubah'),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Shipping
              const Text(
                'Metode Pengiriman',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ..._shippingMethods.map((method) {
                final isSelected = _selectedShipping == method['id'];
                return Card(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: RadioListTile<String>(
                    value: method['id'] as String,
                    groupValue: _selectedShipping,
                    onChanged: (v) => setState(() => _selectedShipping = v!),
                    title: Row(
                      children: [
                        Icon(
                          method['icon'] as IconData,
                          size: 18,
                          color: AppTheme.primaryDark,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          method['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${method['est']} • Rp ${_formatPrice((method['cost'] as num).toDouble())}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textHint,
                      ),
                    ),
                    activeColor: AppTheme.primaryDark,
                    dense: true,
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Payment
              const Text(
                'Metode Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _paymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = _paymentMethods[index];
                    final isSelected = _selectedPayment == method['id'];
                    return GestureDetector(
                      onTap: () => setState(
                        () => _selectedPayment = method['id'] as String,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (method['color'] as Color).withValues(
                                  alpha: 0.1,
                                )
                              : AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: method['color'] as Color,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              method['icon'] as IconData,
                              size: 24,
                              color: method['color'] as Color,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              method['name'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? method['color'] as Color
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Promo
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Promo / Voucher',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Masukkan kode promo',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                isDense: true,
                              ),
                              onChanged: (v) => _promoCode = v,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _applyPromo,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Pakai'),
                          ),
                        ],
                      ),
                      if (_hasPromo)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: AppTheme.success,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Diskon Rp ${_formatPrice(_discountAmount)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Order Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        'Subtotal',
                        'Rp ${_formatPrice(cart.totalPrice)}',
                      ),
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        'Ongkos Kirim',
                        'Rp ${_formatPrice(_shippingCost)}',
                      ),
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        'Pajak (11%)',
                        'Rp ${_formatPrice(_taxAmount)}',
                      ),
                      if (_hasPromo) ...[
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Diskon',
                          '-Rp ${_formatPrice(_discountAmount)}',
                          color: AppTheme.success,
                        ),
                      ],
                      const Divider(height: 20),
                      _buildSummaryRow(
                        'Grand Total',
                        'Rp ${_formatPrice(grandTotal)}',
                        bold: true,
                        color: AppTheme.primaryDark,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Checkout button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _confirmCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Bayar Rp ${_formatPrice(grandTotal)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: color ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 64,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pesanan Berhasil!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _resultMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/main',
                  (route) => false,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDark,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kembali ke Beranda'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/user-orders'),
              child: const Text('Lihat Riwayat Pesanan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _resultMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() => _resultMessage = null),
              child: const Text('Coba Lagi'),
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
