import 'package:shared_preferences/shared_preferences.dart';

import '../domain/onboarding_repository.dart';

class PrefsOnboardingRepository implements OnboardingRepository {
  PrefsOnboardingRepository(this._prefs);
  final SharedPreferences _prefs;
  static const _key = 'onboarding_complete';

  @override
  bool isComplete() => _prefs.getBool(_key) ?? false;

  @override
  Future<void> markComplete() => _prefs.setBool(_key, true);
}
