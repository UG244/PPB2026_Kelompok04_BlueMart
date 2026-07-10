import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../utils/app_theme.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController? _controller;
  bool _torchOn = false;
  bool _hasResult = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasResult) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue != null) {
      setState(() => _hasResult = true);
      _showProductFound(barcode!.rawValue!);
    }
  }

  void _showProductFound(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Produk Ditemukan', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 48,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Kode: ', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              code,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Produk dengan kode ini tersedia di katalog.',
              style: TextStyle(fontSize: 13, color: AppTheme.textHint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryDark,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lihat Produk'),
          ),
        ],
      ),
    ).then((_) => setState(() => _hasResult = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode / QR'),
        actions: [
          IconButton(
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              _controller?.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
            tooltip: 'Flashlight',
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => _controller?.switchCamera(),
            tooltip: 'Flip Camera',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Scanner overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Corner decorations
                  Positioned(
                    top: -2,
                    left: -2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          top: const BorderSide(
                            color: AppTheme.accent,
                            width: 4,
                          ),
                          left: const BorderSide(
                            color: AppTheme.accent,
                            width: 4,
                          ),
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          top: const BorderSide(
                            color: AppTheme.accent,
                            width: 4,
                          ),
                          right: const BorderSide(
                            color: AppTheme.accent,
                            width: 4,
                          ),
                        ),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    left: -2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: const BorderSide(
                            color: AppTheme.accent,
                            width: 4,
                          ),
                          left: const BorderSide(
                            color: AppTheme.accent,
                            width: 4,
                          ),
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: const BorderSide(
                            color: AppTheme.accent,
                            width: 4,
                          ),
                          right: const BorderSide(
                            color: AppTheme.accent,
                            width: 4,
                          ),
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom hint
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Arahkan kamera ke barcode produk',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
