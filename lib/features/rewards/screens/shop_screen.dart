import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';

/// The shop where kids spend their points on avatar accessories.
/// Full implementation coming in Phase 3.
class ShopScreen extends StatelessWidget {
  final String profileId;
  const ShopScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛍️ Butik / Shop'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🛒', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('Butiken öppnar snart!\nShop coming in Phase 3',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge),
          ],
        ),
      ),
    );
  }
}
