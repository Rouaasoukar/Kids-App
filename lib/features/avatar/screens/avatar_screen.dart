import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';

/// Avatar customization screen where kids dress up their character.
/// Full implementation coming in Phase 3.
class AvatarScreen extends StatelessWidget {
  final String profileId;
  const AvatarScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 Min Avatar / My Avatar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎭', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('Avatarbutik kommer snart!\nAvatar shop coming in Phase 3',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge),
          ],
        ),
      ),
    );
  }
}
