import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metode Pembayaran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _paymentMethods.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Atur metode pembayaran yang tersedia untuk pelanggan',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            );
          }
          final method = _paymentMethods[index - 1];
          return _buildPaymentMethodCard(method);
        },
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final isActive = method['status'] as bool;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
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
        title: Text(
          method['name'] as String,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          method['desc'] as String,
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        trailing: Switch(
          value: isActive,
          onChanged: (value) {
            setState(() => method['status'] = value);
          },
          activeTrackColor: const Color(0xFF22C55E).withValues(alpha: 0.5),
          activeThumbColor: const Color(0xFF22C55E),
        ),
      ),
    );
  }
}