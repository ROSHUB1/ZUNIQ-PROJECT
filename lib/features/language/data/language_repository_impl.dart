import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_language.dart';
import 'supported_languages.dart';

class PrefsLanguageRepository implements LanguageRepository {
  PrefsLanguageRepository(this._prefs);
  final SharedPreferences _prefs;
  static const _key = 'language_code';

  @override
  AppLanguage? readSelected() {
    final code = _prefs.getString(_key);
    if (code == null) return null;
    for (final l in supportedLanguages) {
      if (l.code == code) return l;
    }
    return null;
  }

  @override
  Future<void> save(String code) => _prefs.setString(_key, code);
}
