import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// A full-screen celebration shown when the child gets the right answer.
///
/// Shows:
/// - Big emoji burst
/// - Points earned
/// - "Well done!" in Swedish + English
/// - Auto-dismisses after 2 seconds, or tap to continue
class CelebrationOverlay extends StatelessWidget {
  final int pointsEarned;
  final bool earnedStar;
  final VoidCallback onContinue;

  const CelebrationOverlay({
    super.key,
    required this.pointsEarned,
    this.earnedStar = false,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    // Auto-continue after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), onContinue);

    return GestureDetector(
      onTap: onContinue,
      child: Container(
        color: AppColors.correct.withValues(alpha: 0.92),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Big animated emojis
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['🎉', '⭐', '🎊']
                    .asMap()
                    .entries
                    .map((e) => Text(
                          e.value,
                          style: const TextStyle(fontSize: 48),
                        )
                            .animate()
                            .scale(
                              delay: (e.key * 100).ms,
                              duration: 400.ms,
                              curve: Curves.elasticOut,
                            )
                            .moveY(begin: 20, end: 0))
                    .toList(),
              ),

              const SizedBox(height: 24),

              // "Bra jobbat!"
              Text(
                'Bra jobbat! 🥳',
                style: AppTextStyles.displayLarge.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .scale(begin: const Offset(0.5, 0.5)),

              const SizedBox(height: 8),

              Text(
                'Well done!',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 32),

              // Points badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 8),
                    Text(
                      '+$pointsEarned poäng',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    if (earnedStar) ...[
                      const SizedBox(width: 12),
                      const Text('🌟', style: TextStyle(fontSize: 28)),
                    ],
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 40),

              Text(
                'Tryck för att fortsätta →',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(delay: 800.ms)
                  .then()
                  .fadeOut(duration: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small "Wrong answer" shake feedback widget — shown briefly then hidden
class WrongAnswerFeedback extends StatelessWidget {
  const WrongAnswerFeedback({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.wrong,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Försök igen! / Try again! 💪',
        style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
      ),
    ).animate().shake(hz: 3, offset: const Offset(6, 0)).fadeIn();
  }
}
