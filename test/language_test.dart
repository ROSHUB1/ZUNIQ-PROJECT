import 'package:flutter_test/flutter_test.dart';
import 'package:zuniq/features/language/data/supported_languages.dart';
import 'package:zuniq/features/language/domain/app_language.dart';

void main() {
  test('language codes are unique BCP 47-style tags', () {
    final codes = supportedLanguages.map((l) => l.code).toList();
    expect(codes.toSet().length, codes.length);
    expect(codes, containsAll(['en', 'fil', 'es', 'ja']));
  });

  test('filter matches native, English name and code', () {
    expect(filterLanguages(supportedLanguages, '').length, supportedLanguages.length);
    expect(filterLanguages(supportedLanguages, 'japan').map((l) => l.code), ['ja']);
    expect(filterLanguages(supportedLanguages, '日本').map((l) => l.code), ['ja']);
    expect(filterLanguages(supportedLanguages, 'FIL').map((l) => l.code), contains('fil'));
    expect(filterLanguages(supportedLanguages, 'zzzz'), isEmpty);
  });
}
