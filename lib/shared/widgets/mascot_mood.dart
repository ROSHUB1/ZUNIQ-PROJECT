import 'mascot.dart';

/// Expressions the mascot can show, driven by what the user is doing.
enum MascotMood { idle, greeting, listening, thinking, explaining, happy, unsure, error }

extension MascotMoodX on MascotMood {
  /// Whether the animation for this mood repeats (Lottie only).
  bool get loops => this != MascotMood.greeting && this != MascotMood.happy;

  /// Closest static pose (for places that still show the PNG art).
  MascotPose get fallbackPose => switch (this) {
        MascotMood.idle => MascotPose.ask,
        MascotMood.greeting => MascotPose.welcome,
        MascotMood.listening => MascotPose.listening,
        MascotMood.thinking => MascotPose.processing,
        MascotMood.explaining => MascotPose.explanationReady,
        MascotMood.happy => MascotPose.success,
        MascotMood.unsure => MascotPose.clarification,
        MascotMood.error => MascotPose.error,
      };
}
