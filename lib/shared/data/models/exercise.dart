import 'user_profile.dart';

/// What type of exercise this is — matches our three age groups
enum ExerciseType {
  letterPick, // age 3-4: hear letter, pick from 4 buttons
  wordBuild, // age 4-7: hear word + see picture, tap letters to build it
  sentenceType, // age 7-16: hear sentence + see picture, type it
}

/// One exercise unit that the AI (or word bank) generates.
/// The app uses this to display the correct screen and check the answer.
class Exercise {
  final String id;
  final ExerciseType type;
  final AppLanguage language;

  // The content
  final String target; // the letter / word / sentence to learn
  final String? imagePath; // optional picture (used in age 4-7 and 7-16)
  final List<String> choices; // for letter pick: the 4 letter options
  final String? hint; // optional hint text

  // Scoring for this exercise
  final int pointsReward; // base points for getting it right
  final int starsReward; // stars awarded (usually 0 or 1)

  const Exercise({
    required this.id,
    required this.type,
    required this.language,
    required this.target,
    this.imagePath,
    this.choices = const [],
    this.hint,
    required this.pointsReward,
    this.starsReward = 0,
  });
}

/// The result after a child completes one exercise
class ExerciseResult {
  final String exerciseId;
  final bool isCorrect;
  final int pointsEarned;
  final int starsEarned;
  final Duration timeTaken;
  final DateTime completedAt;

  const ExerciseResult({
    required this.exerciseId,
    required this.isCorrect,
    required this.pointsEarned,
    required this.starsEarned,
    required this.timeTaken,
    required this.completedAt,
  });
}
