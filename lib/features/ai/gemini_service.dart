import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../shared/data/models/user_profile.dart';
import '../../shared/data/word_bank.dart';

/// The AI service that generates personalised exercises using Google Gemini.
///
/// How it works:
/// 1. We describe the child's age group and language to Gemini
/// 2. Gemini returns a fresh letter / word / sentence appropriate for that child
/// 3. We fall back to the built-in WordBank if AI is unavailable (offline)
class GeminiService {
  GenerativeModel? _model;
  bool _isAvailable = false;

  /// Call once at app startup
  Future<void> init() async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (apiKey.isEmpty) return;

      _model = GenerativeModel(
        model: 'gemini-1.5-flash', // fast and free-tier friendly
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,   // some creativity but not too wild
          maxOutputTokens: 200, // short responses only
        ),
      );
      _isAvailable = true;
    } catch (_) {
      _isAvailable = false;
    }
  }

  bool get isAvailable => _isAvailable;

  // ─── Generate a letter exercise (age 3-4) ────────────────────────────────

  /// Returns a letter the child should practise, based on difficulty level.
  /// difficulty: 0 = easy (A-E), 1 = medium, 2 = hard (Å Ä Ö included)
  Future<String> generateLetter({
    required AppLanguage language,
    required int difficulty,
  }) async {
    if (!_isAvailable) return _fallbackLetter(language, difficulty);

    final lang = language == AppLanguage.swedish ? 'Swedish' : 'English';
    final diffText = ['easy (A to E)', 'medium (F to P)', 'hard (including special characters)'][difficulty.clamp(0, 2)];

    final prompt = '''
You are a kids learning app assistant.
Return ONLY a single uppercase letter suitable for a $diffText $lang spelling exercise.
For Swedish hard difficulty, include letters like Å, Ä, or Ö sometimes.
Reply with just the letter, nothing else. No punctuation, no explanation.
''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      final letter = response.text?.trim().toUpperCase() ?? '';
      if (letter.length == 1) return letter;
    } catch (_) {}

    return _fallbackLetter(language, difficulty);
  }

  // ─── Generate a word exercise (age 4-7) ──────────────────────────────────

  /// Returns a word + emoji pair for the word-building exercise.
  Future<({String word, String emoji})> generateWord({
    required AppLanguage language,
    required AgeGroup ageGroup,
    required int difficulty, // 0=easy (3 letters), 1=medium (4-5), 2=hard (6+)
  }) async {
    if (!_isAvailable) return _fallbackWord(language);

    final lang = language == AppLanguage.swedish ? 'Swedish' : 'English';
    final lengths = ['3 letters', '4 to 5 letters', '6 or more letters'];
    final lengthText = lengths[difficulty.clamp(0, 2)];

    final prompt = '''
You are a kids learning app assistant for children aged 4-7.
Return a simple common $lang word that is $lengthText long, suitable for young children.
Also return one emoji that represents the word visually.
Reply in this exact format only, nothing else:
WORD|EMOJI

Example: CAT|🐱
For Swedish example: KATT|🐱
''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';
      final parts = text.split('|');
      if (parts.length == 2) {
        final word = parts[0].trim().toUpperCase();
        final emoji = parts[1].trim();
        if (word.isNotEmpty && emoji.isNotEmpty) {
          return (word: word, emoji: emoji);
        }
      }
    } catch (_) {}

    return _fallbackWord(language);
  }

  // ─── Generate a sentence exercise (age 7-16) ─────────────────────────────

  /// Returns a sentence + emoji for the typing exercise.
  /// difficulty: 0=short (5-8 words), 1=medium (9-12), 2=long (13+)
  Future<({String sentence, String emoji})> generateSentence({
    required AppLanguage language,
    required int difficulty,
    String? theme, // optional theme like 'animals', 'school', 'nature'
  }) async {
    if (!_isAvailable) return _fallbackSentence(language);

    final lang = language == AppLanguage.swedish ? 'Swedish' : 'English';
    final lengths = ['5 to 8 words', '9 to 12 words', '13 or more words'];
    final lengthText = lengths[difficulty.clamp(0, 2)];
    final themeText = theme != null ? 'about $theme' : '';

    final prompt = '''
You are a kids learning app assistant for children aged 7-16.
Write one simple, positive $lang sentence $themeText that is $lengthText long.
The sentence should be grammatically correct and appropriate for children.
Also return one emoji that visually represents the sentence.
Reply in this exact format only, nothing else:
SENTENCE|EMOJI

Example for English: The dog runs fast in the park.|🐕
Example for Swedish: Hunden springer snabbt i parken.|🐕
''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';
      final parts = text.split('|');
      if (parts.length == 2) {
        final sentence = parts[0].trim();
        final emoji = parts[1].trim();
        if (sentence.isNotEmpty && emoji.isNotEmpty) {
          return (sentence: sentence, emoji: emoji);
        }
      }
    } catch (_) {}

    return _fallbackSentence(language);
  }

  // ─── Fallbacks (used when offline or AI fails) ────────────────────────────

  String _fallbackLetter(AppLanguage language, int difficulty) {
    final alphabet = WordBank.alphabetFor(language);
    // Split alphabet into easy/medium/hard thirds
    final third = (alphabet.length / 3).floor();
    final start = difficulty.clamp(0, 2) * third;
    final end = (start + third).clamp(0, alphabet.length);
    final slice = alphabet.sublist(start, end);
    slice.shuffle();
    return slice.first;
  }

  ({String word, String emoji}) _fallbackWord(AppLanguage language) {
    final words = WordBank.wordsFor(language).toList(); // toList() makes it mutable
    words.shuffle();
    final w = words.first;
    return (word: w.word, emoji: w.emoji);
  }

  ({String sentence, String emoji}) _fallbackSentence(AppLanguage language) {
    final sentences = WordBank.sentencesFor(language).toList();
    sentences.shuffle();
    final s = sentences.first;
    return (sentence: s.sentence, emoji: s.emoji);
  }
}

/// Global singleton — any screen can call geminiService.generateWord() etc.
final geminiService = GeminiService();
