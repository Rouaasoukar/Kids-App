import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../data/repositories/profile_repository.dart';

/// Shown after a child completes all 5 exercises in a round.
/// Displays total score, accuracy, and options to play again or go home.
class RoundCompleteScreen extends StatefulWidget {
  final String profileId;
  final int totalPoints;
  final int totalStars;
  final int correctAnswers;
  final int totalExercises;
  final VoidCallback onPlayAgain;

  const RoundCompleteScreen({
    super.key,
    required this.profileId,
    required this.totalPoints,
    required this.totalStars,
    required this.correctAnswers,
    required this.totalExercises,
    required this.onPlayAgain,
  });

  @override
  State<RoundCompleteScreen> createState() => _RoundCompleteScreenState();
}

class _RoundCompleteScreenState extends State<RoundCompleteScreen> {
  int _currentPoints = 0;
  int _currentStars = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentScore();
  }

  Future<void> _loadCurrentScore() async {
    final repo = ProfileRepository();
    await repo.init();
    final profile = repo.getProfile(widget.profileId);
    if (profile != null && mounted) {
      setState(() {
        _currentPoints = profile.points;
        _currentStars = profile.stars;
      });
    }
  }

  // Accuracy percentage
  int get _accuracy =>
      ((widget.correctAnswers / widget.totalExercises) * 100).round();

  // Motivational message based on accuracy
  String get _message {
    if (_accuracy == 100) return 'Perfekt! 🏆\nPerfect!';
    if (_accuracy >= 80) return 'Jättebra! ⭐\nGreat job!';
    if (_accuracy >= 60) return 'Bra försök! 💪\nGood try!';
    return 'Fortsätt öva! 📚\nKeep practising!';
  }

  Color get _messageColor {
    if (_accuracy == 100) return const Color(0xFFFFD700);
    if (_accuracy >= 80) return AppColors.correct;
    if (_accuracy >= 60) return AppColors.middleGroup;
    return AppColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6C63FF), Color(0xFF9C63FF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // --- Title ---
                Text(
                  'Rundan klar! 🎉',
                  style: AppTextStyles.displayLarge.copyWith(
                      color: Colors.white),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3),

                Text(
                  'Round complete!',
                  style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.8)),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 32),

                // --- Score card ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Accuracy circle
                      _AccuracyCircle(accuracy: _accuracy),

                      const SizedBox(height: 16),

                      Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineMedium
                            .copyWith(color: _messageColor),
                      ),

                      const Divider(height: 32),

                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatBox(
                            emoji: '✅',
                            value: '${widget.correctAnswers}/${widget.totalExercises}',
                            label: 'Rätt / Correct',
                          ),
                          _StatBox(
                            emoji: '⭐',
                            value: '+${widget.totalPoints}',
                            label: 'Poäng / Points',
                          ),
                          _StatBox(
                            emoji: '🌟',
                            value: '+${widget.totalStars}',
                            label: 'Stjärnor / Stars',
                          ),
                        ],
                      ),

                      const Divider(height: 32),

                      // Total score
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('Totalt / Total',
                                  style: AppTextStyles.bodyMedium),
                              Text('⭐ $_currentPoints',
                                  style: AppTextStyles.headlineMedium.copyWith(
                                      color: AppColors.primary)),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Stjärnor / Stars',
                                  style: AppTextStyles.bodyMedium),
                              Text('🌟 $_currentStars',
                                  style: AppTextStyles.headlineMedium.copyWith(
                                      color: AppColors.star)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: 0.4, end: 0),

                const Spacer(),

                // --- Buttons ---
                ElevatedButton.icon(
                  onPressed: widget.onPlayAgain,
                  icon: const Text('🎮', style: TextStyle(fontSize: 20)),
                  label: const Text('Spela igen! / Play again!'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Text('🏠', style: TextStyle(fontSize: 20)),
                  label: const Text('Hem / Home'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccuracyCircle extends StatelessWidget {
  final int accuracy;
  const _AccuracyCircle({required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (accuracy == 100) {
      color = const Color(0xFFFFD700);
    } else if (accuracy >= 80) {
      color = AppColors.correct;
    } else if (accuracy >= 60) {
      color = AppColors.middleGroup;
    } else {
      color = AppColors.secondary;
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color, width: 4),
      ),
      child: Center(
        child: Text(
          '$accuracy%',
          style: AppTextStyles.headlineLarge.copyWith(color: color),
        ),
      ),
    ).animate().scale(
        begin: const Offset(0.3, 0.3),
        duration: 600.ms,
        curve: Curves.elasticOut);
  }
}

class _StatBox extends StatelessWidget {
  final String emoji, value, label;
  const _StatBox({required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(value,
            style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.primary)),
        Text(label, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
      ],
    );
  }
}
