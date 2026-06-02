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

/// Age 4-7: The app says a word and shows an emoji picture.
/// The child taps letter tiles at the bottom to build the word.
/// Correct tiles snap into place; wrong tiles shake back.
class WordBuildScreen extends StatefulWidget {
  final String profileId;
  const WordBuildScreen({super.key, required this.profileId});

  @override
  State<WordBuildScreen> createState() => _WordBuildScreenState();
}

class _WordBuildScreenState extends State<WordBuildScreen> {
  final _repo = ProfileRepository();
  final _random = Random();

  UserProfile? _profile;

  // Current round
  WordEntry? _currentWord;
  List<String> _letterTiles = []; // shuffled letters the child picks from
  List<String?> _builtWord = []; // what child has built so far (nulls = empty slots)
  List<int> _usedTileIndices = []; // which tiles have been tapped
  bool _showCelebration = false;
  bool _showWrong = false;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadAndStart();
  }

  Future<void> _loadAndStart() async {
    await _repo.init();
    _profile = _repo.getProfile(widget.profileId);
    if (_profile == null) return;

    await ttsService.init();
    await ttsService.setLanguage(_profile!.language);

    _nextRound();
  }

  int get _difficulty => (_streak ~/ 5).clamp(0, 2);

  Future<void> _nextRound() async {
    // Get word from AI or fall back to word bank
    final String word;
    final String emoji;

    if (geminiService.isAvailable) {
      final result = await geminiService.generateWord(
        language: _profile!.language,
        ageGroup: _profile!.ageGroup,
        difficulty: _difficulty,
      );
      word = result.word;
      emoji = result.emoji;
    } else {
      final words = WordBank.wordsFor(_profile!.language);
      final entry = words[_random.nextInt(words.length)];
      word = entry.word;
      emoji = entry.emoji;
    }

    final wordEntry = WordEntry(word: word, emoji: emoji);
    final letters = word.split('');

    // Add 2–3 decoy letters so it's not trivially easy
    final alphabet = WordBank.alphabetFor(_profile!.language);
    final decoys = <String>[];
    while (decoys.length < 3) {
      final d = alphabet[_random.nextInt(alphabet.length)];
      if (!letters.contains(d) && !decoys.contains(d)) decoys.add(d);
    }

    final allTiles = [...letters, ...decoys]..shuffle(_random);

    setState(() {
      _currentWord = wordEntry;
      _letterTiles = allTiles;
      _builtWord = List.filled(letters.length, null);
      _usedTileIndices = [];
      _showCelebration = false;
      _showWrong = false;
    });

    // Speak the word automatically
    Future.delayed(const Duration(milliseconds: 600), () {
      ttsService.speak(word.toLowerCase());
    });
  }

  void _onTileTap(int tileIndex) {
    if (_usedTileIndices.contains(tileIndex)) return;

    // Find the next empty slot in _builtWord
    final nextSlot = _builtWord.indexWhere((l) => l == null);
    if (nextSlot == -1) return; // word is already full

    setState(() {
      _builtWord[nextSlot] = _letterTiles[tileIndex];
      _usedTileIndices.add(tileIndex);
    });

    // Check if word is complete
    if (!_builtWord.contains(null)) {
      _checkAnswer();
    }
  }

  void _onSlotTap(int slotIndex) {
    // Tapping a filled slot removes that letter (lets child fix mistakes)
    if (_builtWord[slotIndex] == null) return;

    // Find which tile index this letter came from
    // (we need to find the last added tile that matches this letter)
    final letter = _builtWord[slotIndex]!;
    int? tileToReturn;
    for (int i = _usedTileIndices.length - 1; i >= 0; i--) {
      final idx = _usedTileIndices[i];
      if (_letterTiles[idx] == letter) {
        tileToReturn = idx;
        break;
      }
    }

    setState(() {
      _builtWord[slotIndex] = null;
      if (tileToReturn != null) _usedTileIndices.remove(tileToReturn);
    });
  }

  Future<void> _checkAnswer() async {
    final built = _builtWord.join();
    final target = _currentWord!.word;

    if (built == target) {
      // ✅ Correct!
      _streak++;
      final points = 20 + (built.length * 2); // longer words = more points
      final stars = _streak % 3 == 0 ? 1 : 0;
      await _repo.updateScore(widget.profileId, points, stars);
      setState(() => _showCelebration = true);
    } else {
      // ❌ Wrong
      _streak = 0;
      setState(() => _showWrong = true);
      await ttsService.speak(target.toLowerCase());
      await Future.delayed(const Duration(milliseconds: 1500));

      // Reset the built word so they can try again
      if (mounted) {
        setState(() {
          _builtWord = List.filled(target.length, null);
          _usedTileIndices = [];
          _showWrong = false;
        });
      }
    }
  }

  int get _pointsForRound =>
      20 + ((_currentWord?.word.length ?? 0) * 2);

  @override
  Widget build(BuildContext context) {
    if (_currentWord == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          _buildBody(),
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

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE3F2FD), Color(0xFFF8F4FF)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ─── Top bar ──────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  if (_streak > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.middleGroup.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text('$_streak',
                              style: AppTextStyles.headlineMedium
                                  .copyWith(color: AppColors.middleGroup)),
                        ],
                      ),
                    ).animate().fadeIn(),
                ],
              ),
            ),

            const Spacer(),

            // ─── Instruction ──────────────────────────────────────────
            Text('Stava ordet! / Spell the word!',
                style: AppTextStyles.headlineMedium
                    .copyWith(color: AppColors.textMedium)),

            const SizedBox(height: 20),

            // ─── Emoji picture + word speaker ─────────────────────────
            GestureDetector(
              onTap: () =>
                  ttsService.speak(_currentWord!.word.toLowerCase()),
              child: Column(
                children: [
                  Text(_currentWord!.emoji,
                      style: const TextStyle(fontSize: 80))
                      .animate(key: ValueKey(_currentWord!.word))
                      .scale(
                          begin: const Offset(0.3, 0.3),
                          duration: 500.ms,
                          curve: Curves.elasticOut),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.volume_up_rounded,
                          color: AppColors.middleGroup, size: 22),
                      const SizedBox(width: 6),
                      Text('Tryck för att höra / Tap to hear',
                          style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ─── Word slots (where built letters appear) ──────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _builtWord.asMap().entries.map((entry) {
                final letter = entry.value;
                return GestureDetector(
                  onTap: () => _onSlotTap(entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 44,
                    height: 52,
                    decoration: BoxDecoration(
                      color: letter != null
                          ? AppColors.middleGroup
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: letter != null
                            ? AppColors.middleGroup
                            : AppColors.neutral,
                        width: 2,
                      ),
                      boxShadow: letter != null
                          ? [
                              BoxShadow(
                                color: AppColors.middleGroup
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: letter != null
                          ? Text(letter,
                              style: AppTextStyles.headlineMedium
                                  .copyWith(color: Colors.white))
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),

            if (_showWrong)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: const WrongAnswerFeedback(),
              ),

            const Spacer(),

            // ─── Letter tiles to pick from ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: _letterTiles.asMap().entries.map((entry) {
                  final isUsed = _usedTileIndices.contains(entry.key);
                  return GestureDetector(
                    onTap: isUsed ? null : () => _onTileTap(entry.key),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isUsed ? 0.25 : 1.0,
                      child: Container(
                        width: 50,
                        height: 58,
                        decoration: BoxDecoration(
                          color: isUsed
                              ? AppColors.neutral
                              : const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isUsed
                                ? AppColors.neutral
                                : AppColors.middleGroup,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            entry.value,
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: isUsed
                                  ? AppColors.neutral
                                  : AppColors.middleGroup,
                            ),
                          ),
                        ),
                      ),
                    )
                        .animate(delay: (entry.key * 60).ms)
                        .fadeIn()
                        .slideY(begin: 0.4, end: 0),
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
