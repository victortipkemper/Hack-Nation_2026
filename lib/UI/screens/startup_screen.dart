import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  Future<void> _selectUserType(int userType) async {
    final box = Hive.box('settings');
    await box.put('userType', userType);

    if (userType == 0) {
      Get.offAllNamed('/user');
    } else {
      Get.offAllNamed('/merchant');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.handshake_rounded,
                size: 80,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to HackNation',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'How would you like to use the app?',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // User option
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _selectUserType(0),
                  icon: const Icon(Icons.person_rounded),
                  label: const Text('I\'m a Customer'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: theme.textTheme.titleMedium,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Seller option
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () => _selectUserType(1),
                  icon: const Icon(Icons.storefront_rounded),
                  label: const Text('I\'m a Seller'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: theme.textTheme.titleMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
