import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Hardcoded expected QR code value for validation.
const String _expectedQrCode = 'shop_vibe_77';

class MerchantMainPage extends StatefulWidget {
  const MerchantMainPage({super.key});

  @override
  State<MerchantMainPage> createState() => _MerchantMainPageState();
}

class _MerchantMainPageState extends State<MerchantMainPage> {
  final TextEditingController _couponController = TextEditingController();
  bool _isScanning = false;
  MobileScannerController? _scannerController;

  @override
  void dispose() {
    _couponController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  /// Placeholder save trigger – implement business logic here.
  void _onSaveCoupon() {
    // TODO: implement save coupon logic
  }

  void _openScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
    setState(() => _isScanning = true);
  }

  void _closeScanner() {
    _scannerController?.dispose();
    _scannerController = null;
    setState(() => _isScanning = false);
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? scannedValue = barcodes.first.rawValue;
    if (scannedValue == null) return;

    // Stop scanning immediately to avoid multiple navigations
    _closeScanner();

    final bool isValid = scannedValue == _expectedQrCode;

    Get.toNamed(
      '/validation',
      arguments: {'isValid': isValid, 'scannedValue': scannedValue},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // ── Camera scanner overlay ──
    if (_isScanning) {
      return Scaffold(
        body: Stack(
          children: [
            MobileScanner(
              controller: _scannerController!,
              onDetect: _onBarcodeDetected,
            ),

            // Scan-frame overlay
            Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.8),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            // Close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 16,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: _closeScanner,
                ),
              ),
            ),

            // Instruction text
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Text(
                'Point camera at a QR code',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  shadows: [
                    const Shadow(blurRadius: 8, color: Colors.black87),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Main merchant dashboard ──
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              final box = Hive.box('settings');
              await box.delete('userType');
              Get.offAllNamed('/startup');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──
            Icon(
              Icons.storefront_rounded,
              size: 72,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Merchant Dashboard',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 40),

            // ── Coupon Amount Section ──
            Text(
              'Coupon Amount',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _couponController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter coupon amount (€)',
                prefixIcon: const Icon(Icons.euro_rounded),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _onSaveCoupon,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ── Validate QR Code ──
            OutlinedButton.icon(
              onPressed: _openScanner,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Validate QR Code'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: colorScheme.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
