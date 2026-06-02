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

/// Age 7-16: The app reads a sentence aloud and shows an emoji.
/// The child types the sentence â€” checked letter by letter as they type.
class SentenceTypeScreen extends StatefulWidget {
  final String profileId;
  const SentenceTypeScreen({super.key, required this.profileId});

  @override
  State<SentenceTypeScreen> createState() => _SentenceTypeScreenState();
}

class _SentenceTypeScreenState extends State<SentenceTypeScreen> {
  final _repo = ProfileRepository();
  final _random = Random();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  UserProfile? _profile;
  SentenceEntry? _current;
  bool _showCelebration = false;
  bool _showWrong = false;
  bool _hasSubmitted = false;
  int _streak = 0;
  bool _showAnswer = false;

  // Round tracking
  int _exerciseNumber = 0;
  int _correctInRound = 0;
  int _pointsInRound = 0;
  int _starsInRound = 0;
  bool _roundComplete = false;

  @override
  void initState() {
    super.initState();
    _loadAndStart();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadAndStart() async {
    await _repo.init();
    _profile = _repo.getProfile(widget.profileId);
    if (_profile == null) return;

    await ttsService.init();
    await ttsService.setLanguage(_profile!.language);

    _nextExercise();
  }

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

  int get _difficulty => (_streak ~/ 3).clamp(0, 2);


  Future<void> _nextExercise() async {
    if (_exerciseNumber >= _exercisesPerRound) {
      setState(() => _roundComplete = true);
      return;
    }
    setState(() => _exerciseNumber++);

    final String sentence;
    final String emoji;

    if (geminiService.isAvailable) {
      final result = await geminiService.generateSentence(
        language: _profile!.language,
        difficulty: _difficulty,
      );
      sentence = result.sentence;
      emoji = result.emoji;
    } else {
      final sentences = WordBank.sentencesFor(_profile!.language);
      final entry = sentences[_random.nextInt(sentences.length)];
      sentence = entry.sentence;
      emoji = entry.emoji;
    }

    setState(() {
      _current = SentenceEntry(sentence: sentence, emoji: emoji);
      _controller.clear();
      _showCelebration = false;
      _showWrong = false;
      _hasSubmitted = false;
      _showAnswer = false;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      ttsService.speak(_current!.sentence);
    });
  }

  Future<void> _submit() async {
    if (_hasSubmitted || _current == null) return;
    setState(() => _hasSubmitted = true);

    final typed = _controller.text.trim();
    final target = _current!.sentence.trim();

    // Case-insensitive comparison, also ignore trailing punctuation differences
    final typedClean = typed.toLowerCase().replaceAll(RegExp(r'[.!?,]'), '');
    final targetClean = target.toLowerCase().replaceAll(RegExp(r'[.!?,]'), '');

    if (typedClean == targetClean) {
      // âœ… Correct!
      _streak++;
      final points = 30 + (target.split(' ').length * 3);
      final stars = _streak % 2 == 0 ? 1 : 0;
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
      setState(() {
        _showWrong = true;
        _hasSubmitted = false;
      });
      // Read the correct sentence again
      await ttsService.speak(target);
    }
  }

  void _revealAnswer() {
    setState(() {
      _showAnswer = true;
      _showWrong = false;
    });
  }

  // Colour each typed character: green = correct, red = wrong, grey = not yet typed
  List<TextSpan> _buildColoredTarget() {
    final target = _current?.sentence ?? '';
    final typed = _controller.text;
    final spans = <TextSpan>[];

    for (int i = 0; i < target.length; i++) {
      Color color;
      if (i < typed.length) {
        color = typed[i].toLowerCase() == target[i].toLowerCase()
            ? AppColors.correct
            : AppColors.wrong;
      } else {
        color = AppColors.textLight;
      }
      spans.add(TextSpan(
        text: target[i],
        style: AppTextStyles.bodyLarge.copyWith(
          color: color,
          fontWeight: i < typed.length ? FontWeight.w700 : FontWeight.w400,
        ),
      ));
    }
    return spans;
  }

  int get _pointsForRound =>
      30 + ((_current?.sentence.split(' ').length ?? 0) * 3);

  @override
  Widget build(BuildContext context) {
    if (_current == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
          _buildBody(),
          if (_showCelebration)
            CelebrationOverlay(
              pointsEarned: _pointsForRound,
              earnedStar: _streak % 2 == 0 && _streak > 0,
              onContinue: () => _nextExercise(),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3E5F5), Color(0xFFF8F4FF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // â”€â”€â”€ Top bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => context.pop(),
                      ),
                      // Progress dots
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
                                color: done ? AppColors.advancedGroup : AppColors.neutral,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            );
                          }),
                        ),
                      ),
                      if (_streak > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.advancedGroup
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Text('ðŸ”¥',
                                  style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Text('$_streak',
                                  style: AppTextStyles.headlineMedium
                                      .copyWith(
                                          color: AppColors.advancedGroup)),
                            ],
                          ),
                        ).animate().fadeIn(),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // â”€â”€â”€ Instruction â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  Text('Skriv meningen! / Type the sentence!',
                      style: AppTextStyles.headlineMedium
                          .copyWith(color: AppColors.textMedium)),

                  const SizedBox(height: 20),

                  // â”€â”€â”€ Emoji + play button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  GestureDetector(
                    onTap: () => ttsService.speak(_current!.sentence),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.advancedGroup
                                .withValues(alpha: 0.15),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_current!.emoji,
                              style: const TextStyle(fontSize: 48))
                              .animate(key: ValueKey(_current!.sentence))
                              .scale(
                                  begin: const Offset(0.3, 0.3),
                                  duration: 400.ms,
                                  curve: Curves.elasticOut),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.volume_up_rounded,
                                  color: AppColors.advancedGroup, size: 28),
                              const SizedBox(height: 4),
                              Text('Tryck fÃ¶r att hÃ¶ra',
                                  style: AppTextStyles.bodyMedium),
                              Text('Tap to listen',
                                  style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // â”€â”€â”€ Coloured target (live feedback) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.advancedGroup
                              .withValues(alpha: 0.3)),
                    ),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context2, child2) => RichText(
                        text: TextSpan(children: _buildColoredTarget()),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // â”€â”€â”€ Text input â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: false,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppTextStyles.bodyLarge,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Skriv hÃ¤r... / Type here...',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear,
                            color: AppColors.textLight),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _hasSubmitted = false);
                        },
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 16),

                  // â”€â”€â”€ Wrong feedback â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  if (_showWrong)
                    Column(
                      children: [
                        const WrongAnswerFeedback(),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _revealAnswer,
                          child: Text(
                            'Visa svaret / Show answer',
                            style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.advancedGroup),
                          ),
                        ),
                      ],
                    ),

                  // â”€â”€â”€ Revealed answer â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  if (_showAnswer)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.advancedGroup.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.advancedGroup
                                .withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('RÃ¤tt svar / Correct answer:',
                              style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 4),
                          Text(_current!.sentence,
                              style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.advancedGroup)),
                        ],
                      ),
                    ).animate().fadeIn(),

                  const SizedBox(height: 20),

                  // â”€â”€â”€ Submit button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _controller.text.trim().isEmpty
                          ? null
                          : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.advancedGroup,
                      ),
                      child: const Text('Kolla svaret! / Check answer!'),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

