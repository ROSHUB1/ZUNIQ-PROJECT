import 'package:flutter/material.dart';

/// ZUNIQ mascot poses (assets/mascot/<name>.webp, 512x512, transparent, feet bottom-aligned).
enum MascotPose {
  welcome,
  ready,
  analyzing,
  processing,
  explanationReady,
  translation,
  ask,
  listening,
  success,
  clarification,
  error,
}

/// Maps the AI's mood tag to a mascot pose.
MascotPose poseForMood(String? mood) => switch (mood) {
      'happy' => MascotPose.success,
      'unsure' => MascotPose.clarification,
      _ => MascotPose.explanationReady,
    };

class Mascot extends StatelessWidget {
  const Mascot(this.pose, {super.key, this.size = 160});
  final MascotPose pose;
  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/mascot/${pose.name}.webp',
        width: size,
        height: size,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      );
}
