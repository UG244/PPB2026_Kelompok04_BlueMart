import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AdminPaymentScreen extends StatefulWidget {
  const AdminPaymentScreen({super.key});

  @override
  State<AdminPaymentScreen> createState() => _AdminPaymentScreenState();
}

class _AdminPaymentScreenState extends State<AdminPaymentScreen> {
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'Transfer Bank BCA',
      'icon': Icons.account_balance,
      'color': const Color(0xFF0066AE),
      'status': true,
      'desc': 'BCA Virtual Account',
    },
    {
      'name': 'Transfer Bank Mandiri',
      'icon': Icons.account_balance,
      'color': const Color(0xFF003E7E),
      'status': true,
      'desc': 'Mandiri Virtual Account',
    },
    {
      'name': 'QRIS',
      'icon': Icons.qr_code,
      'color': const Color(0xFF06B6D4),
      'status': true,
      'desc': 'VIA QRIS',
    },
    {
      'name': 'GoPay',
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFF00AA13),
      'status': false,
      'desc': 'E-Wallet',
    },
    {
      'name': 'OVO',
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFF4B2B9C),
      'status': false,
      'desc': 'E-Wallet',
    },
    {
      'name': 'COD (Bayar di Tempat)',
      'icon': Icons.money,
      'color': const Color(0xFFF97316),
      'status': true,
      'desc': 'Cash on Delivery',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Metode Pembayaran')),
        body: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _paymentMethods.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Atur metode pembayaran yang tersedia untuk pelanggan',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                );
              }
              return _buildCard(_paymentMethods[index - 1]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> method) {
    final isActive = method['status'] as bool;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardShape),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (method['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                method['icon'] as IconData,
                color: method['color'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method['desc'] as String,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Switch(
              value: isActive,
              onChanged: (v) => setState(() => method['status'] = v),
              activeTrackColor: AppTheme.success.withValues(alpha: 0.5),
              activeThumbColor: AppTheme.success,
            ),
          ],
        ),
      ),
    );
  }
}
