import 'package:flutter/material.dart';
import '../../shared_exercise_widgets.dart';

/// Age 3-4: Hear a letter and pick the correct one from 4 choices.
/// Full implementation coming in Phase 2.
class LetterPickScreen extends StatelessWidget {
  final String profileId;
  const LetterPickScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return ExercisePlaceholder(
      title: '🔤 Bokstav / Letter',
      description: 'Lyssna och välj rätt bokstav!\nListen and pick the right letter!',
      profileId: profileId,
      color: const Color(0xFF4CAF50),
    );
  }
}
