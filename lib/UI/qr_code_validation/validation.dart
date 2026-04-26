import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ValidationScreen extends StatelessWidget {
  const ValidationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Retrieve arguments from navigation
    final args = Get.arguments as Map<String, dynamic>?;
    final bool isValid = args?['isValid'] ?? false;
    final String scannedValue = args?['scannedValue'] ?? '';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Status icon ──
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isValid
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    isValid
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 72,
                    color: isValid ? Colors.green : Colors.red,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Title ──
                Text(
                  isValid ? 'Coupon Validated' : 'Invalid QR Code',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isValid ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),

                const SizedBox(height: 12),

                // ── Subtitle ──
                Text(
                  isValid
                      ? 'The scanned coupon code is valid.\nYou may proceed.'
                      : 'The scanned code does not match\nany active coupon.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                // ── Scanned value chip ──
                if (scannedValue.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Scanned: $scannedValue',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                const SizedBox(height: 48),

                // ── Back button ──
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Get.offAllNamed('/merchant'),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back to Merchant'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor:
                          isValid ? Colors.green : colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
