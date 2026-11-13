import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/reactive_mascot.dart';

/// Intro shown when the Assistant opens: Lottie sparkles/rings behind the mascot (assets/lottie/assistant_intro.json,
/// replaceable), the mascot popping in, and a speech bubble that types the greeting.
/// If the Lottie file cannot be loaded, the rest of the intro still plays.
class AssistantIntro extends StatelessWidget {
  const AssistantIntro({super.key, this.mood = MascotMood.greeting, this.onMascotTap});
  final MascotMood mood;
  final VoidCallback? onMascotTap;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        SizedBox(
          width: 250,
          height: 230,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/assistant_intro.json',
                width: 250,
                height: 250,
                repeat: false,
                animate: !reduce,
                errorBuilder: (context, error, stack) => const SizedBox.shrink(),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: reduce ? 1.0 : 0.0, end: 1.0),
                duration: const Duration(milliseconds: 950),
                curve: Curves.elasticOut,
                builder: (context, v, child) => Transform.scale(
                  scale: 0.55 + 0.45 * v,
                  child: Opacity(opacity: v.clamp(0.0, 1.0), child: child),
                ),
                child: ReactiveMascot(mood, size: 158, onTap: onMascotTap),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.card,
          ),
          child: TypewriterText(context.tr('intro_greeting'), style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

/// Types its text out character by character. The full text is laid out invisibly first so the box never resizes.
class TypewriterText extends StatefulWidget {
  const TypewriterText(this.text, {super.key, this.style, this.startDelay = const Duration(milliseconds: 750)});
  final String text;
  final TextStyle? style;
  final Duration startDelay;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  int _n = 0;
  bool _started = false;
  Timer? _timer;
  Timer? _delay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _n = widget.text.length;
      return;
    }
    _delay = Timer(widget.startDelay, () {
      _timer = Timer.periodic(const Duration(milliseconds: 28), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        setState(() => _n++);
        if (_n >= widget.text.length) t.cancel();
      });
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shown = widget.text.substring(0, _n.clamp(0, widget.text.length));
    return Stack(
      children: [
        Opacity(opacity: 0, child: Text(widget.text, style: widget.style)),
        Text(shown, style: widget.style),
      ],
    );
  }
}
