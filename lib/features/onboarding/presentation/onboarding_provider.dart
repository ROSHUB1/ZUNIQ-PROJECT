import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/preferences.dart';
import '../data/onboarding_repository_impl.dart';
import '../domain/onboarding_repository.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => PrefsOnboardingRepository(ref.watch(sharedPreferencesProvider)),
);

class OnboardingController extends Notifier<bool> {
  @override
  bool build() => ref.watch(onboardingRepositoryProvider).isComplete();

  Future<void> complete() async {
    await ref.read(onboardingRepositoryProvider).markComplete();
    state = true;
  }
}

final onboardingProvider = NotifierProvider<OnboardingController, bool>(OnboardingController.new);
