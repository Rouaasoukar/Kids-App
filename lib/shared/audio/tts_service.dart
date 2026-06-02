import 'package:flutter_tts/flutter_tts.dart';
import '../data/models/user_profile.dart';

/// Text-to-Speech service — reads letters, words and sentences aloud.
///
/// How it works:
/// - We create ONE FlutterTts instance for the whole app
/// - We set the language based on the child's profile (Swedish or English)
/// - We set a slow speech rate so young kids can follow along
/// - Any screen can call speak() to make the app talk
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  AppLanguage _currentLanguage = AppLanguage.swedish;

  /// Call this once when the app starts
  Future<void> init() async {
    if (_isInitialized) return;

    // Speech rate: 0.0 = slowest, 1.0 = normal, we use 0.4 for young kids
    await _tts.setSpeechRate(0.4);

    // Volume: full blast so kids can hear clearly
    await _tts.setVolume(1.0);

    // Pitch: slightly higher = friendlier, more child-like voice
    await _tts.setPitch(1.1);

    // Default to Swedish
    await _setLanguage(AppLanguage.swedish);

    _isInitialized = true;
  }

  /// Switch language based on the child's profile setting
  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;
    _currentLanguage = language;
    await _setLanguage(language);
  }

  Future<void> _setLanguage(AppLanguage language) async {
    // BCP-47 language codes: 'sv-SE' = Swedish Sweden, 'en-US' = English US
    final langCode = language == AppLanguage.swedish ? 'sv-SE' : 'en-US';
    await _tts.setLanguage(langCode);
  }

  /// Speak any text aloud.
  /// If something is already playing, it stops it first.
  Future<void> speak(String text) async {
    if (!_isInitialized) await init();
    await _tts.stop(); // stop anything currently playing
    await _tts.speak(text);
  }

  /// Speak a single letter — we add a pause so it sounds clear
  Future<void> speakLetter(String letter) async {
    // Spelling out letters: Swedish uses the letter name, not the sound
    // e.g. "A" is spoken as "Ah", "B" as "Beh" etc.
    await speak(letter);
  }

  /// Speak a word slowly, then spell it out letter by letter
  Future<void> speakWordWithSpelling(String word) async {
    // First say the whole word
    await speak(word);
    // Small delay then spell it out
    await Future.delayed(const Duration(milliseconds: 800));
    for (final letter in word.split('')) {
      await speak(letter);
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  /// Stop any current speech
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Dispose when done (called when app closes)
  Future<void> dispose() async {
    await _tts.stop();
  }
}

/// A global singleton so any screen can access TTS without passing it around
final ttsService = TtsService();
