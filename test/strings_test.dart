import 'package:flutter_test/flutter_test.dart';
import 'package:zuniq/core/l10n/strings.dart';

void main() {
  test('Filipino has every English key and no empty values', () {
    final en = appStrings['en']!;
    final fil = appStrings['fil']!;
    expect(fil.keys.toSet().difference(en.keys.toSet()), isEmpty, reason: 'extra keys in fil');
    expect(en.keys.toSet().difference(fil.keys.toSet()), isEmpty, reason: 'missing keys in fil');
    for (final v in [...en.values, ...fil.values]) {
      expect(v.trim(), isNotEmpty);
    }
  });

  test('ui language mapping', () {
    expect(uiCodeFor('fil'), 'fil');
    expect(uiCodeFor('es'), 'en');
    expect(uiCodeFor(null), 'en');
  });
}
