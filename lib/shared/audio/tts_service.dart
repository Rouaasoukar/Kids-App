import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';
import '../data/models/user_profile.dart';

// TTS only works on iOS and Android — skip entirely on Windows/web
bool get _ttsSupported =>
    !kIsWeb && (Platform.isIOS || Platform.isAndroid);

/// Text-to-Speech service — reads letters, words and sentences aloud.
/// On Windows/web it silently does nothing (voice works on iOS/Android).
class TtsService {
  FlutterTts? _tts; // null on unsupported platforms
  bool _isInitialized = false;
  AppLanguage _currentLanguage = AppLanguage.swedish;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    if (!_ttsSupported) return;
    _tts = FlutterTts();
    await _tts!.setSpeechRate(0.4);
    await _tts!.setVolume(1.0);
    await _tts!.setPitch(1.1);
    await _setLanguage(AppLanguage.swedish);
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (!_ttsSupported || _tts == null) return;
    if (_currentLanguage == language) return;
    _currentLanguage = language;
    await _setLanguage(language);
  }

  Future<void> _setLanguage(AppLanguage language) async {
    final langCode = language == AppLanguage.swedish ? 'sv-SE' : 'en-US';
    await _tts?.setLanguage(langCode);
  }

  Future<void> speak(String text) async {
    if (!_ttsSupported || _tts == null) return;
    await _tts!.stop();
    await _tts!.speak(text);
  }

  Future<void> speakLetter(String letter) async {
    await speak(letter);
  }

  Future<void> speakWordWithSpelling(String word) async {
    await speak(word);
    await Future.delayed(const Duration(milliseconds: 800));
    for (final letter in word.split('')) {
      await speak(letter);
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  Future<void> stop() async {
    await _tts?.stop();
  }

  Future<void> dispose() async {
    await _tts?.stop();
  }
}

final ttsService = TtsService();
