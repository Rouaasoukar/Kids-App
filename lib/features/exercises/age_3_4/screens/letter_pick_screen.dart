import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/audio/tts_service.dart';
import '../../../../shared/data/word_bank.dart';
import '../../../../shared/data/models/user_profile.dart';
import '../../../../shared/data/repositories/profile_repository.dart';
import '../../../../shared/widgets/celebration_overlay.dart';
import '../../../../shared/widgets/round_complete_screen.dart';
import '../../../ai/gemini_service.dart';

const int _exercisesPerRound = 5;

/// Age 3-4: The app says a letter aloud and shows it big.
/// The child taps the correct letter from 4 colourful buttons.
class LetterPickScreen extends StatefulWidget {
  final String profileId;
  const LetterPickScreen({super.key, required this.profileId});

  @override
  State<LetterPickScreen> createState() => _LetterPickScreenState();
}

class _LetterPickScreenState extends State<LetterPickScreen> {
  final _repo = ProfileRepository();
  final _random = Random();

  UserProfile? _profile;
  List<String> _alphabet = [];

  // Current exercise state
  String _targetLetter = '';
  List<String> _choices = [];
  String? _selectedLetter;
  bool _showCelebration = false;
  bool _showWrong = false;
  int _streak = 0;

  // Round tracking
  int _exerciseNumber = 0;       // 0â€“4 (current exercise in round)
  int _correctInRound = 0;       // correct answers this round
  int _pointsInRound = 0;        // total points earned this round
  int _starsInRound = 0;         // total stars earned this round
  bool _roundComplete = false;   // show round complete screen

  @override
  void initState() {
    super.initState();
    _loadAndStart();
  }

  Future<void> _loadAndStart() async {
    await _repo.init();
    _profile = _repo.getProfile(widget.profileId);
    if (_profile == null) return;

    _alphabet = WordBank.alphabetFor(_profile!.language);
    await ttsService.init();
    await ttsService.setLanguage(_profile!.language);

    _nextExercise();
  }

  // Difficulty increases every 5 correct answers: 0â†’easy, 1â†’medium, 2â†’hard
  int get _difficulty => (_streak ~/ 5).clamp(0, 2);

  void _startNewRound() {
    setState(() {
      _exerciseNumber = 0;
      _correctInRound = 0;
      _pointsInRound = 0;
      _starsInRound = 0;
      _roundComplete = false;
      _streak = 0;
    });
    _nextExercise();
  }


  Future<void> _nextExercise() async {
    // Check if round is complete
    if (_exerciseNumber >= _exercisesPerRound) {
      setState(() => _roundComplete = true);
      return;
    }

    setState(() => _exerciseNumber++);

    // Try AI first, fall back to word bank if offline
    final String target;
    if (geminiService.isAvailable) {
      target = await geminiService.generateLetter(
        language: _profile!.language,
        difficulty: _difficulty,
      );
    } else {
      target = _alphabet[_random.nextInt(_alphabet.length)];
    }

    // Build 3 wrong choices â€” must be different from target and each other
    final wrongs = <String>[];
    while (wrongs.length < 3) {
      final candidate = _alphabet[_random.nextInt(_alphabet.length)];
      if (candidate != target && !wrongs.contains(candidate)) {
        wrongs.add(candidate);
      }
    }

    // Shuffle target into the 4 choices
    final allChoices = [...wrongs, target]..shuffle(_random);

    setState(() {
      _targetLetter = target;
      _choices = allChoices;
      _selectedLetter = null;
      _showCelebration = false;
      _showWrong = false;
    });

    // Automatically speak the letter after a short delay
    Future.delayed(const Duration(milliseconds: 600), () {
      ttsService.speakLetter(target);
    });
  }

  Future<void> _onChoiceTap(String letter) async {
    if (_selectedLetter != null) return;
    setState(() => _selectedLetter = letter);

    if (letter == _targetLetter) {
      // âœ… Correct!
      _streak++;
      final points = 10 + (_streak >= 3 ? 5 : 0);
      final stars = _streak % 3 == 0 ? 1 : 0;

      await _repo.updateScore(widget.profileId, points, stars);

      setState(() {
        _correctInRound++;
        _pointsInRound += points;
        _starsInRound += stars;
        _showCelebration = true;
      });
    } else {
      // âŒ Wrong
      _streak = 0;
      setState(() => _showWrong = true);
      await ttsService.speakLetter(_targetLetter);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) setState(() => _showWrong = false);
      if (mounted) setState(() => _selectedLetter = null); // let them try again
    }
  }

  int get _pointsForRound {
    return 10 + (_streak >= 3 ? 5 : 0);
  }

  @override
  Widget build(BuildContext context) {
    // Show round complete screen after all exercises done
    if (_roundComplete) {
      return RoundCompleteScreen(
        profileId: widget.profileId,
        totalPoints: _pointsInRound,
        totalStars: _starsInRound,
        correctAnswers: _correctInRound,
        totalExercises: _exercisesPerRound,
        onPlayAgain: _startNewRound,
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          _buildExerciseBody(),
          if (_showCelebration)
            CelebrationOverlay(
              pointsEarned: _pointsForRound,
              earnedStar: _streak % 3 == 0 && _streak > 0,
              onContinue: () => _nextExercise(),
            ),
        ],
      ),
    );
  }

  Widget _buildExerciseBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F5E9), Color(0xFFF8F4FF)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // â”€â”€â”€ Top bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.pop(),
                  ),
                  // Exercise progress dots
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_exercisesPerRound, (i) {
                        final done = i < _exerciseNumber;
                        final current = i == _exerciseNumber - 1;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: current ? 20 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: done
                                ? AppColors.earlyGroup
                                : AppColors.neutral,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Streak counter
                  if (_streak > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.earlyGroup.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text('ðŸ”¥', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text('$_streak',
                              style: AppTextStyles.headlineMedium
                                  .copyWith(color: AppColors.earlyGroup)),
                        ],
                      ),
                    ).animate().fadeIn(),
                ],
              ),
            ),

            const Spacer(),

            // â”€â”€â”€ Instruction â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Text(
              'Vilken bokstav Ã¤r detta?',
              style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textMedium),
            ),
            Text(
              'Which letter is this?',
              style: AppTextStyles.bodyMedium,
            ),

            const SizedBox(height: 24),

            // â”€â”€â”€ Big letter display + speaker button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            GestureDetector(
              onTap: () => ttsService.speakLetter(_targetLetter),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.earlyGroup.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // The letter
                    Text(
                      _targetLetter,
                      style: AppTextStyles.letterDisplay.copyWith(
                        color: AppColors.earlyGroup,
                      ),
                    ),
                    // Small speaker icon at bottom right
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.earlyGroup.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.volume_up_rounded,
                          size: 18,
                          color: AppColors.earlyGroup,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate(key: ValueKey(_targetLetter))
                .scale(
                    begin: const Offset(0.5, 0.5),
                    duration: 400.ms,
                    curve: Curves.elasticOut),

            const SizedBox(height: 12),
            Text('Tryck fÃ¶r att hÃ¶ra igen / Tap to hear',
                style: AppTextStyles.bodyMedium),

            const Spacer(),

            // â”€â”€â”€ Wrong answer feedback â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if (_showWrong)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: WrongAnswerFeedback(),
              ),

            // â”€â”€â”€ 4 choice buttons â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.8,
                physics: const NeverScrollableScrollPhysics(),
                children: _choices.asMap().entries.map((entry) {
                  return _ChoiceButton(
                    letter: entry.value,
                    index: entry.key,
                    selected: _selectedLetter == entry.value,
                    isCorrect: entry.value == _targetLetter,
                    revealed: _selectedLetter != null,
                    onTap: () => _onChoiceTap(entry.value),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// One of the 4 letter choice buttons
class _ChoiceButton extends StatelessWidget {
  final String letter;
  final int index;
  final bool selected;
  final bool isCorrect;
  final bool revealed; // true = an answer was picked
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.letter,
    required this.index,
    required this.selected,
    required this.isCorrect,
    required this.revealed,
    required this.onTap,
  });

  // Each button gets its own colour
  static const _colors = [
    Color(0xFF6C63FF), // purple
    Color(0xFFFF6B9D), // pink
    Color(0xFF4CAF50), // green
    Color(0xFFFF9800), // orange
  ];

  @override
  Widget build(BuildContext context) {
    Color bgColor = _colors[index % _colors.length];

    // After answering: green = correct, red = wrong selection, grey = not selected
    if (revealed) {
      if (isCorrect) {
        bgColor = AppColors.correct;
      } else if (selected) {
        bgColor = AppColors.wrong;
      } else {
        bgColor = AppColors.neutral;
      }
    }

    return GestureDetector(
      onTap: revealed ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: AppTextStyles.headlineLarge.copyWith(
              color: Colors.white,
              fontSize: 28,
            ),
          ),
        ),
      )
          .animate(delay: (index * 80).ms)
          .fadeIn()
          .slideY(begin: 0.3, end: 0),
    );
  }
}

