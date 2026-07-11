import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AdminQrisScreen extends StatefulWidget {
  const AdminQrisScreen({super.key});

  @override
  State<AdminQrisScreen> createState() => _AdminQrisScreenState();
}

class _AdminQrisScreenState extends State<AdminQrisScreen> {
  double _nominal = 0;
  final _nominalController = TextEditingController();

  @override
  void dispose() {
    _nominalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Pembayaran QRIS')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // QRIS header card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.qr_code,
                          size: 48,
                          color: Color(0xFF06B6D4),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'BlueMart QRIS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pembayaran via QRIS',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_2,
                                size: 100,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'QRIS Code',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Scan QRIS di atas untuk melakukan pembayaran',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Set Nominal
                _buildSectionCard(
                  title: 'Atur Nominal Pembayaran',
                  children: [
                    TextField(
                      controller: _nominalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan nominal',
                        prefixText: 'Rp ',
                        prefixStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _nominal = double.tryParse(value) ?? 0);
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(50000),
                        _buildChip(100000),
                        _buildChip(200000),
                        _buildChip(500000),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Riwayat
                _buildSectionCard(
                  title: 'Riwayat Pembayaran QRIS',
                  titleIcon: Icons.history,
                  children: [
                    _buildHistoryRow('Pembayaran #INV001', 'Rp 150.000', true),
                    const Divider(height: 20),
                    _buildHistoryRow('Pembayaran #INV002', 'Rp 75.000', true),
                    const Divider(height: 20),
                    _buildHistoryRow('Pembayaran #INV003', 'Rp 200.000', false),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    IconData? titleIcon,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardShape),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (titleIcon != null) ...[
                  Icon(titleIcon, size: 18, color: AppTheme.primary),
                  const SizedBox(width: 6),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildChip(int nominal) {
    final isSel = _nominal == nominal;
    return GestureDetector(
      onTap: () {
        setState(() {
          _nominal = nominal.toDouble();
          _nominalController.text = nominal.toString();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSel
              ? AppTheme.primaryLighter.withValues(alpha: 0.1)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(AppTheme.chipRadius),
          border: Border.all(
            color: isSel ? AppTheme.primaryLighter : Colors.transparent,
          ),
        ),
        child: Text(
          'Rp ${nominal ~/ 1000}rb',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSel ? AppTheme.primaryLighter : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryRow(String title, String amount, bool success) {
    final color = success ? AppTheme.success : AppTheme.error;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                amount,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            success ? 'Berhasil' : 'Gagal',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
