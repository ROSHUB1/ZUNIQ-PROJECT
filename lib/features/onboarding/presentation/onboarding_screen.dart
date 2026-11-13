import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/content_width.dart';
import '../../../shared/widgets/reactive_mascot.dart';
import '../../../shared/widgets/soft_background.dart';
import '../../../shared/widgets/zuniq_logo.dart';
import 'onboarding_provider.dart';

class _PageData {
  const _PageData(this.mood, this.titleKey, this.bodyKey);
  final MascotMood mood;
  final String titleKey;
  final String bodyKey;
}

const _pages = <_PageData>[
  _PageData(MascotMood.greeting, 'onb1_title', 'onb1_body'),
  _PageData(MascotMood.explaining, 'onb2_title', 'onb2_body'),
  _PageData(MascotMood.listening, 'onb3_title', 'onb3_body'),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _pages.length - 1;

  Future<void> _finish() async {
    await ref.read(onboardingProvider.notifier).complete();
    if (mounted) context.go('/language');
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    final next = _index + 1;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(next);
    } else {
      _controller.nextPage(duration: AppMotion.page(context), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SoftBackground(
        child: SafeArea(
          child: ContentWidth(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.s8, AppSpacing.s8, 0),
                  child: Row(
                    children: [
                      const ZuniqWordmark(size: 26),
                      const Spacer(),
                      Visibility(
                        visible: !_isLast,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: TextButton(onPressed: _finish, child: Text(context.tr('skip'))),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) {
                      final p = _pages[i];
                      return Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _Art(mood: p.mood),
                              const SizedBox(height: AppSpacing.s32),
                              Text(context.tr(p.titleKey), style: t.headlineMedium, textAlign: TextAlign.center),
                              const SizedBox(height: AppSpacing.s12),
                              Text(context.tr(p.bodyKey),
                                  style: t.bodyLarge?.copyWith(color: AppColors.textSecondary),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) {
                    final active = i == _index;
                    return AnimatedContainer(
                      duration: AppMotion.small(context),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenH),
                  child: ElevatedButton(
                    onPressed: _next,
                    child: Text(context.tr(_isLast ? 'get_started' : 'continue')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Art extends StatelessWidget {
  const _Art({required this.mood});
  final MascotMood mood;

  @override
  Widget build(BuildContext context) => Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppRadius.sheet + 8),
          boxShadow: AppShadows.card,
        ),
        child: Center(child: ReactiveMascot(mood, size: 230)),
      );
}
