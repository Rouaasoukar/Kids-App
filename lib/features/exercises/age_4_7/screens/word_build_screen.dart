import 'package:flutter/material.dart';
import '../../shared_exercise_widgets.dart';

/// Age 4-7: Hear a word and see a picture, then tap letters to build the word.
/// Full implementation coming in Phase 2.
class WordBuildScreen extends StatelessWidget {
  final String profileId;
  const WordBuildScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return ExercisePlaceholder(
      title: '📝 Ord / Word',
      description: 'Lyssna och bygg ordet!\nListen and build the word!',
      profileId: profileId,
      color: const Color(0xFF2196F3),
    );
  }
}
