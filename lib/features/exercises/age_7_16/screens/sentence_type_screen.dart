import 'package:flutter/material.dart';
import '../../shared_exercise_widgets.dart';

/// Age 7-16: Hear a sentence and see a picture, then type the full sentence.
/// Full implementation coming in Phase 2.
class SentenceTypeScreen extends StatelessWidget {
  final String profileId;
  const SentenceTypeScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return ExercisePlaceholder(
      title: '✍️ Mening / Sentence',
      description: 'Lyssna och skriv meningen!\nListen and type the sentence!',
      profileId: profileId,
      color: const Color(0xFF9C27B0),
    );
  }
}
