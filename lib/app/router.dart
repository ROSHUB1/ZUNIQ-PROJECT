import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/assistant/presentation/assistant_screen.dart';
import '../features/assistant/presentation/chat_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/language/presentation/language_provider.dart';
import '../features/language/presentation/language_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/onboarding/presentation/onboarding_provider.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/analysis/presentation/result_screen.dart';
import '../features/processing/presentation/processing_screen.dart';
import '../features/scanner/presentation/review_screen.dart';
import 'app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.onDispose(refresh.dispose);
  ref.listen(onboardingProvider, (_, __) => refresh.value++);
  ref.listen(languageProvider, (_, __) => refresh.value++);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final done = ref.read(onboardingProvider);
      final lang = ref.read(languageProvider);
      final loc = state.matchedLocation;

      if (loc == '/') {
        if (!done) return '/onboarding';
        if (lang == null) return '/language';
        return '/app/home';
      }
      if (!done && loc != '/onboarding') return '/onboarding';
      if (done && lang == null && loc != '/language') return '/language';
      if (done && loc == '/onboarding') return lang == null ? '/language' : '/app/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SizedBox.shrink()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/language', builder: (_, __) => const LanguageScreen()),
      GoRoute(
        path: '/chat/:conversationId',
        builder: (_, state) => ChatScreen(
          conversationId: state.pathParameters['conversationId'] ?? 'general',
          prefill: state.uri.queryParameters['q'],
        ),
      ),
      GoRoute(path: '/review', builder: (_, __) => const ReviewScreen()),
      GoRoute(path: '/processing', builder: (_, __) => const ProcessingScreen()),
      GoRoute(
        path: '/analysis/:id',
        builder: (_, state) => ResultScreen(id: state.pathParameters['id'] ?? ''),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/app/home', builder: (_, __) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/app/library', builder: (_, __) => const LibraryScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/app/assistant', builder: (_, __) => const AssistantScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/app/settings', builder: (_, __) => const SettingsScreen())]),
        ],
      ),
    ],
  );
});
