import 'models/user_profile.dart';

/// A word entry with an emoji picture (we use emojis as pictures for now,
/// real images will be added in Phase 4)
class WordEntry {
  final String word;
  final String emoji; // shown as the "picture"
  final String? hint; // optional hint in the child's language

  const WordEntry({required this.word, required this.emoji, this.hint});
}

/// A sentence entry for the 7-16 age group
class SentenceEntry {
  final String sentence;
  final String emoji;

  const SentenceEntry({required this.sentence, required this.emoji});
}

/// All built-in content, organised by language and exercise type.
/// This works fully offline — no internet needed.
class WordBank {
  // ─── SWEDISH ALPHABET ────────────────────────────────────────────────
  // Swedish has 29 letters: A-Z plus Å, Ä, Ö
  static const List<String> swedishAlphabet = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    'Å', 'Ä', 'Ö',
  ];

  static const List<String> englishAlphabet = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  static List<String> alphabetFor(AppLanguage lang) =>
      lang == AppLanguage.swedish ? swedishAlphabet : englishAlphabet;

  // ─── SWEDISH WORDS (age 4-7) ─────────────────────────────────────────
  // Short, common Swedish words with emoji pictures
  static const List<WordEntry> swedishWords = [
    WordEntry(word: 'KATT',   emoji: '🐱', hint: 'katt = cat'),
    WordEntry(word: 'HUND',   emoji: '🐶', hint: 'hund = dog'),
    WordEntry(word: 'FISK',   emoji: '🐟', hint: 'fisk = fish'),
    WordEntry(word: 'FÅGEL',  emoji: '🐦', hint: 'fågel = bird'),
    WordEntry(word: 'BIL',    emoji: '🚗', hint: 'bil = car'),
    WordEntry(word: 'BUS',    emoji: '🚌', hint: 'buss = bus'),
    WordEntry(word: 'SOL',    emoji: '☀️',  hint: 'sol = sun'),
    WordEntry(word: 'MÅN',    emoji: '🌙', hint: 'måne = moon'),
    WordEntry(word: 'ÄPP',    emoji: '🍎', hint: 'äpple = apple'),
    WordEntry(word: 'BOLL',   emoji: '⚽', hint: 'boll = ball'),
    WordEntry(word: 'BOK',    emoji: '📚', hint: 'bok = book'),
    WordEntry(word: 'HUS',    emoji: '🏠', hint: 'hus = house'),
    WordEntry(word: 'BJÖRN',  emoji: '🐻', hint: 'björn = bear'),
    WordEntry(word: 'BLOMMA', emoji: '🌸', hint: 'blomma = flower'),
    WordEntry(word: 'TÅRT',   emoji: '🎂', hint: 'tårta = cake'),
    WordEntry(word: 'STJÄRNA',emoji: '⭐', hint: 'stjärna = star'),
    WordEntry(word: 'HJÄRT',  emoji: '❤️',  hint: 'hjärta = heart'),
    WordEntry(word: 'LEJON',  emoji: '🦁', hint: 'lejon = lion'),
    WordEntry(word: 'ELEFANT',emoji: '🐘', hint: 'elefant = elephant'),
    WordEntry(word: 'GIRAFF', emoji: '🦒', hint: 'giraff = giraffe'),
  ];

  // ─── ENGLISH WORDS (age 4-7) ─────────────────────────────────────────
  static const List<WordEntry> englishWords = [
    WordEntry(word: 'CAT',      emoji: '🐱'),
    WordEntry(word: 'DOG',      emoji: '🐶'),
    WordEntry(word: 'FISH',     emoji: '🐟'),
    WordEntry(word: 'BIRD',     emoji: '🐦'),
    WordEntry(word: 'CAR',      emoji: '🚗'),
    WordEntry(word: 'BUS',      emoji: '🚌'),
    WordEntry(word: 'SUN',      emoji: '☀️'),
    WordEntry(word: 'MOON',     emoji: '🌙'),
    WordEntry(word: 'APPLE',    emoji: '🍎'),
    WordEntry(word: 'BALL',     emoji: '⚽'),
    WordEntry(word: 'BOOK',     emoji: '📚'),
    WordEntry(word: 'HOUSE',    emoji: '🏠'),
    WordEntry(word: 'BEAR',     emoji: '🐻'),
    WordEntry(word: 'FLOWER',   emoji: '🌸'),
    WordEntry(word: 'CAKE',     emoji: '🎂'),
    WordEntry(word: 'STAR',     emoji: '⭐'),
    WordEntry(word: 'HEART',    emoji: '❤️'),
    WordEntry(word: 'LION',     emoji: '🦁'),
    WordEntry(word: 'ELEPHANT', emoji: '🐘'),
    WordEntry(word: 'GIRAFFE',  emoji: '🦒'),
  ];

  static List<WordEntry> wordsFor(AppLanguage lang) =>
      lang == AppLanguage.swedish ? swedishWords : englishWords;

  // ─── SWEDISH SENTENCES (age 7-16) ────────────────────────────────────
  // Sentences of increasing difficulty
  static const List<SentenceEntry> swedishSentences = [
    // Easy (short)
    SentenceEntry(sentence: 'Katten sitter på mattan.', emoji: '🐱'),
    SentenceEntry(sentence: 'Solen skiner idag.', emoji: '☀️'),
    SentenceEntry(sentence: 'Hunden leker i parken.', emoji: '🐶'),
    SentenceEntry(sentence: 'Jag läser en bok.', emoji: '📚'),
    SentenceEntry(sentence: 'Blomman är röd och fin.', emoji: '🌹'),
    // Medium
    SentenceEntry(sentence: 'Barnen leker ute i trädgården.', emoji: '🌳'),
    SentenceEntry(sentence: 'Fågeln sjunger vackert i trädet.', emoji: '🐦'),
    SentenceEntry(sentence: 'Vi åker bil till farmor på lördag.', emoji: '🚗'),
    SentenceEntry(sentence: 'Det snöar ute och allt är vitt.', emoji: '❄️'),
    SentenceEntry(sentence: 'Elefanten är det största djuret på land.', emoji: '🐘'),
    // Harder
    SentenceEntry(sentence: 'Sverige är ett vackert land med många sjöar och skogar.', emoji: '🇸🇪'),
    SentenceEntry(sentence: 'Om man tränar varje dag blir man bättre och bättre.', emoji: '💪'),
  ];

  // ─── ENGLISH SENTENCES (age 7-16) ────────────────────────────────────
  static const List<SentenceEntry> englishSentences = [
    // Easy
    SentenceEntry(sentence: 'The cat sits on the mat.', emoji: '🐱'),
    SentenceEntry(sentence: 'The sun is shining today.', emoji: '☀️'),
    SentenceEntry(sentence: 'The dog plays in the park.', emoji: '🐶'),
    SentenceEntry(sentence: 'I am reading a book.', emoji: '📚'),
    SentenceEntry(sentence: 'The flower is red and pretty.', emoji: '🌹'),
    // Medium
    SentenceEntry(sentence: 'The children play outside in the garden.', emoji: '🌳'),
    SentenceEntry(sentence: 'The bird sings beautifully in the tree.', emoji: '🐦'),
    SentenceEntry(sentence: 'We drive to grandma\'s house on Saturday.', emoji: '🚗'),
    SentenceEntry(sentence: 'It is snowing and everything is white.', emoji: '❄️'),
    SentenceEntry(sentence: 'The elephant is the largest land animal.', emoji: '🐘'),
    // Harder
    SentenceEntry(sentence: 'Practice every day and you will keep getting better.', emoji: '💪'),
    SentenceEntry(sentence: 'Reading books helps you learn new words and ideas.', emoji: '📖'),
  ];

  static List<SentenceEntry> sentencesFor(AppLanguage lang) =>
      lang == AppLanguage.swedish ? swedishSentences : englishSentences;
}
