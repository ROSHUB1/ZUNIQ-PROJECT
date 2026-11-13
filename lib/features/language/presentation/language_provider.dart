import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/preferences.dart';
import '../data/language_repository_impl.dart';
import '../domain/app_language.dart';

final languageRepositoryProvider = Provider<LanguageRepository>(
  (ref) => PrefsLanguageRepository(ref.watch(sharedPreferencesProvider)),
);

class LanguageController extends Notifier<AppLanguage?> {
  @override
  AppLanguage? build() => ref.watch(languageRepositoryProvider).readSelected();

  Future<void> select(AppLanguage language) async {
    await ref.read(languageRepositoryProvider).save(language.code);
    state = language;
  }
}

final languageProvider = NotifierProvider<LanguageController, AppLanguage?>(LanguageController.new);
