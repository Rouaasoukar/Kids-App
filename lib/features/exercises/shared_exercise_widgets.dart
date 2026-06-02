import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/theme/app_theme.dart';

/// Temporary placeholder widget used while exercise screens are being built.
/// Shows the title and description with a "Coming Soon" message.
class ExercisePlaceholder extends StatelessWidget {
  final String title;
  final String description;
  final String profileId;
  final Color color;

  const ExercisePlaceholder({
    super.key,
    required this.title,
    required this.description,
    required this.profileId,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.2), const Color(0xFFF8F4FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
              const Spacer(),
              Text(title,
                  style: AppTextStyles.displayLarge.copyWith(color: color)),
              const SizedBox(height: 16),
              Text(
                description,
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'ðŸš§ Kommer snart / Coming in Phase 2',
                  style: AppTextStyles.bodyLarge.copyWith(color: color),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

