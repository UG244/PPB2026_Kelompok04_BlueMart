import 'package:flutter/material.dart';

class AdminCouponScreen extends StatefulWidget {
  const AdminCouponScreen({super.key});

  @override
  State<AdminCouponScreen> createState() => _AdminCouponScreenState();
}

class _AdminCouponScreenState extends State<AdminCouponScreen> {
  final List<Map<String, dynamic>> _coupons = [
    {
      'code': 'HEMAT10',
      'discount': '10%',
      'minPurchase': 'Rp 100.000',
      'expiry': '31 Des 2026',
      'uses': 45,
      'maxUses': 100,
      'active': true,
    },
    {
      'code': 'BARU20',
      'discount': '20%',
      'minPurchase': 'Rp 200.000',
      'expiry': '30 Nov 2026',
      'uses': 12,
      'maxUses': 50,
      'active': true,
    },
    {
      'code': 'GRATISONGKIR',
      'discount': 'Gratis Ongkir',
      'minPurchase': 'Rp 150.000',
      'expiry': '31 Des 2026',
      'uses': 78,
      'maxUses': 200,
      'active': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kupon Diskon'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _coupons.length + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Kelola kupon diskon untuk pelanggan',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            );
          }
          final coupon = _coupons[index - 1];
          return _buildCouponCard(coupon);
        },
      ),
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> coupon) {
    final isActive = coupon['active'] as bool;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isActive
              ? const Color(0xFF22C55E).withValues(alpha: 0.3)
              : Colors.grey[300]!,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFF97316).withValues(alpha: 0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFFF97316)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    coupon['code'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1,
                      color: isActive
                          ? const Color(0xFFF97316)
                          : Colors.grey[500],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF22C55E).withValues(alpha: 0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? 'Aktif' : 'Nonaktif',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? const Color(0xFF22C55E)
                          : Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.discount,
                    'Diskon',
                    coupon['discount'] as String,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.shopping_bag,
                    'Min. Belanja',
                    coupon['minPurchase'] as String,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.calendar_today,
                    'Kadaluarsa',
                    coupon['expiry'] as String,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.people,
                    'Digunakan',
                    '${coupon['uses']}/${coupon['maxUses']}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (coupon['uses'] as int) / (coupon['maxUses'] as int),
              backgroundColor: Colors.grey[200],
              color: isActive
                  ? const Color(0xFF22C55E)
                  : Colors.grey[400],
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}