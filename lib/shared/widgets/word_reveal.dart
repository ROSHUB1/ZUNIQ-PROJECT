import 'package:flutter/material.dart';

import 'fade_slide_in.dart';

/// Reveals text word by word with a soft fade/slide. Static when reduced motion is on.
class WordReveal extends StatelessWidget {
  const WordReveal(this.text,
      {super.key, this.style, this.baseDelay = Duration.zero, this.step = const Duration(milliseconds: 60)});
  final String text;
  final TextStyle? style;
  final Duration baseDelay;
  final Duration step;

  @override
  Widget build(BuildContext context) {
    final words = text.split(' ');
    return Wrap(
      children: [
        for (var i = 0; i < words.length; i++)
          FadeSlideIn(delay: baseDelay + step * i, child: Text('${words[i]}\u00A0', style: style)),
      ],
    );
  }
}
