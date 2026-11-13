class AppLanguage {
  const AppLanguage({required this.code, required this.nativeName, required this.englishName});

  /// BCP 47 tag.
  final String code;
  final String nativeName;
  final String englishName;
}

abstract class LanguageRepository {
  AppLanguage? readSelected();
  Future<void> save(String code);
}

List<AppLanguage> filterLanguages(List<AppLanguage> all, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return all;
  return all
      .where((l) =>
          l.nativeName.toLowerCase().contains(q) ||
          l.englishName.toLowerCase().contains(q) ||
          l.code.toLowerCase().contains(q))
      .toList();
}
