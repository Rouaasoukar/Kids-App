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
import '../../../ai/gemini_service.dart';

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

  // Current round state
  String _targetLetter = '';
  List<String> _choices = []; // 4 options shown to the child
  String? _selectedLetter; // what the child tapped
  bool _showCelebration = false;
  bool _showWrong = false;
  int _streak = 0; // consecutive correct answers

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

    _nextRound();
  }

  // Difficulty increases every 5 correct answers: 0→easy, 1→medium, 2→hard
  int get _difficulty => (_streak ~/ 5).clamp(0, 2);

  Future<void> _nextRound() async {
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

    // Build 3 wrong choices — must be different from target and each other
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
    if (_selectedLetter != null) return; // already answered
    setState(() => _selectedLetter = letter);

    if (letter == _targetLetter) {
      // ✅ Correct!
      _streak++;


      // Give bonus points for streaks (every 3 correct in a row = +1 star)
      final points = 10 + (_streak >= 3 ? 5 : 0);
      final stars = _streak % 3 == 0 ? 1 : 0;

      await _repo.updateScore(widget.profileId, points, stars);

      setState(() => _showCelebration = true);
    } else {
      // ❌ Wrong — shake and show feedback
      _streak = 0;
      setState(() => _showWrong = true);

      // Say the correct letter so child learns
      await ttsService.speakLetter(_targetLetter);

      // Hide wrong feedback after 1.5 seconds
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
    return Scaffold(
      body: Stack(
        children: [
          // ─── Main exercise UI ───────────────────────────────────────
          _buildExerciseBody(),

          // ─── Celebration overlay (shown on correct answer) ──────────
          if (_showCelebration)
            CelebrationOverlay(
              pointsEarned: _pointsForRound,
              earnedStar: _streak % 3 == 0 && _streak > 0,
              onContinue: () => _nextRound(),
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
            // ─── Top bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
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
                          const Text('🔥', style: TextStyle(fontSize: 16)),
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

            // ─── Instruction ─────────────────────────────────────────
            Text(
              'Vilken bokstav är detta?',
              style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textMedium),
            ),
            Text(
              'Which letter is this?',
              style: AppTextStyles.bodyMedium,
            ),

            const SizedBox(height: 24),

            // ─── Big letter display + speaker button ──────────────────
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
            Text('Tryck för att höra igen / Tap to hear',
                style: AppTextStyles.bodyMedium),

            const Spacer(),

            // ─── Wrong answer feedback ────────────────────────────────
            if (_showWrong)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: WrongAnswerFeedback(),
              ),

            // ─── 4 choice buttons ─────────────────────────────────────
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
