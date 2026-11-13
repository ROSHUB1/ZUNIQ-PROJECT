import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import 'floating_mascot.dart';
import 'mascot_mood.dart';

export 'mascot_mood.dart';

/// Finds the animation files placed under assets/mascot_anim/ (see the README.txt there).
/// A file named after a mood (e.g. thinking.json / thinking.gif) is used for that mood;
/// "default" is used for moods without their own file.
class MascotAnimations {
  static const folder = 'assets/mascot_anim/';
  static const _exts = ['json', 'gif', 'webp', 'png'];
  static Future<Map<String, String>>? _index;

  static Future<Map<String, String>> get index => _index ??= _load();

  static Future<Map<String, String>> _load() async {
    final out = <String, String>{};
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      for (final key in manifest.listAssets()) {
        if (!key.startsWith(folder)) continue;
        final file = key.substring(folder.length);
        final dot = file.lastIndexOf('.');
        if (dot <= 0 || file.contains('/')) continue;
        final ext = file.substring(dot + 1).toLowerCase();
        if (!_exts.contains(ext)) continue;
        final name = file.substring(0, dot).toLowerCase();
        if (!out.containsKey(name) || ext == 'json') out[name] = key;
      }
    } catch (_) {}
    return out;
  }

  static String? pathFor(Map<String, String> index, MascotMood mood) => index[mood.name.toLowerCase()] ?? index['default'];
}

/// The mascot. Shows your animation for the current [mood] when a file exists,
/// otherwise the static mascot pose with a gentle float. Tapping can trigger a reaction via [onTap].
class ReactiveMascot extends StatelessWidget {
  const ReactiveMascot(this.mood, {super.key, this.size = 120, this.onTap});
  final MascotMood mood;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final fallback = FloatingMascot(mood.fallbackPose, size: size, amplitude: mood == MascotMood.error ? 2 : 6);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: size,
        child: FutureBuilder<Map<String, String>>(
          future: MascotAnimations.index,
          builder: (context, snap) {
            final path = snap.hasData ? MascotAnimations.pathFor(snap.data!, mood) : null;
            final Widget view;
            if (path == null) {
              view = fallback;
            } else if (path.endsWith('.json')) {
              view = Lottie.asset(
                path,
                width: size,
                height: size,
                fit: BoxFit.contain,
                repeat: mood.loops,
                animate: !reduce,
                errorBuilder: (context, error, stack) => fallback,
              );
            } else {
              view = Image.asset(
                path,
                width: size,
                height: size,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                excludeFromSemantics: true,
                errorBuilder: (context, error, stack) => fallback,
              );
            }
            return AnimatedSwitcher(
              duration: reduce ? Duration.zero : const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutBack,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(scale: Tween<double>(begin: 0.85, end: 1).animate(anim), child: child),
              ),
              child: KeyedSubtree(key: ValueKey('${mood.name}:${path ?? 'static'}'), child: view),
            );
          },
        ),
      ),
    );
  }
}
