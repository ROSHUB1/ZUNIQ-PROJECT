import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/utils/format.dart';
import '../../../shared/widgets/content_width.dart';
import '../../../shared/widgets/fade_slide_in.dart';
import '../../../shared/widgets/reactive_mascot.dart';
import '../../../shared/widgets/soft_background.dart';
import '../../../shared/widgets/word_reveal.dart';
import '../../../shared/widgets/zuniq_logo.dart';
import '../../language/presentation/language_provider.dart';
import '../../library/data/history_provider.dart';
import '../../scanner/presentation/scan_actions.dart';

String chatUrl([String? prefill]) => prefill == null
    ? '/chat/general'
    : Uri(path: '/chat/general', queryParameters: {'q': prefill}).toString();

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SoftBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          child: ContentWidth(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.s12, AppSpacing.screenH, AppSpacing.s32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FadeSlideIn(child: _TopBar()),
                  const SizedBox(height: AppSpacing.s16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 60),
                              child: Text(context.tr(greetingKey()),
                                  style: t.titleMedium?.copyWith(color: AppColors.primary)),
                            ),
                            const SizedBox(height: AppSpacing.s4),
                            WordReveal(
                              context.tr('home_title'),
                              style: t.headlineSmall,
                              baseDelay: const Duration(milliseconds: 140),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      const _HomeMascot(),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  const FadeSlideIn(delay: Duration(milliseconds: 220), child: _Hero()),
                  const SizedBox(height: AppSpacing.s24),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 300),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('quick_actions'), style: t.titleLarge),
                        const SizedBox(height: AppSpacing.s12),
                        const _QuickActions(),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 380),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('recent'), style: t.titleLarge),
                        const SizedBox(height: AppSpacing.s12),
                        const _Recent(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeMascot extends StatefulWidget {
  const _HomeMascot();

  @override
  State<_HomeMascot> createState() => _HomeMascotState();
}

class _HomeMascotState extends State<_HomeMascot> {
  MascotMood _mood = MascotMood.greeting;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _settle(const Duration(milliseconds: 3400));
  }

  void _settle(Duration after) {
    _timer?.cancel();
    _timer = Timer(after, () {
      if (mounted) setState(() => _mood = MascotMood.idle);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ReactiveMascot(
        _mood,
        size: 118,
        onTap: () {
          setState(() => _mood = MascotMood.happy);
          _settle(const Duration(milliseconds: 2600));
        },
      );
}

class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    return Row(
      children: [
        const ZuniqWordmark(size: 26),
        const Spacer(),
        Material(
          color: AppColors.surface,
          shape: const StadiumBorder(side: BorderSide(color: AppColors.border)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => context.push('/language'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.translate, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text((lang?.code ?? 'en').toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

class _Hero extends ConsumerStatefulWidget {
  const _Hero();

  @override
  ConsumerState<_Hero> createState() => _HeroState();
}

class _HeroState extends ConsumerState<_Hero> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final outline = OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: const BorderSide(color: Color(0x99FFFFFF)),
    );
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.lerp(Alignment.topLeft, Alignment.topCenter, _c.value)!,
            end: Alignment.lerp(Alignment.bottomRight, Alignment.bottomCenter, _c.value)!,
            colors: const [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: AppShadows.hero,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('scan_title'), style: t.titleLarge?.copyWith(color: Colors.white)),
                      const SizedBox(height: AppSpacing.s4),
                      Text(context.tr('scan_sub'), style: t.bodyMedium?.copyWith(color: AppColors.onHeroMuted)),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                _ScanGlyph(progress: _c.value),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            ElevatedButton.icon(
              onPressed: () => startScan(context, ref, ScanSource.scanner),
              icon: const Icon(Icons.document_scanner_outlined),
              label: Text(context.tr('scan_btn')),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryDark),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => startScan(context, ref, ScanSource.gallery),
                    icon: const Icon(Icons.image_outlined),
                    label: Text(context.tr('upload_short')),
                    style: outline,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => startScan(context, ref, ScanSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(context.tr('camera_short')),
                    style: outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A document icon with a scan line sweeping over it.
class _ScanGlyph extends StatelessWidget {
  const _ScanGlyph({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    const size = 68.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: const Color(0x26FFFFFF), borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          const Center(child: Icon(Icons.description_outlined, color: Colors.white, size: 34)),
          Positioned(
            left: 10,
            right: 10,
            top: 10 + (size - 24) * progress,
            child: Container(
              height: 2.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
                boxShadow: const [BoxShadow(color: Color(0xAAFFFFFF), blurRadius: 8)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickAction>[
      _QuickAction(
        icon: Icons.text_snippet_outlined,
        label: context.tr('qa_explain'),
        onTap: () => context.push(chatUrl(context.tr('pre_explain'))),
      ),
      _QuickAction(
        icon: Icons.translate,
        label: context.tr('qa_translate'),
        onTap: () => context.push(chatUrl(context.tr('pre_translate'))),
      ),
      _QuickAction(icon: Icons.chat_bubble_outline, label: context.tr('qa_ask'), onTap: () => context.push(chatUrl())),
      _QuickAction(icon: Icons.folder_outlined, label: context.tr('qa_docs'), onTap: () => context.go('/app/library')),
    ];
    return LayoutBuilder(builder: (context, c) {
      final w = (c.maxWidth - AppSpacing.s12) / 2;
      return Wrap(
        spacing: AppSpacing.s12,
        runSpacing: AppSpacing.s12,
        children: [for (final a in actions) SizedBox(width: w, child: a)],
      );
    });
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.card), boxShadow: AppShadows.card),
        child: Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            side: const BorderSide(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Text(label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _Recent extends ConsumerWidget {
  const _Recent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(historyProvider).take(3).toList();
    final t = Theme.of(context).textTheme;
    final ui = StringsScope.of(context);
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.auto_awesome_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('recent_empty_title'), style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                  Text(context.tr('recent_empty_body'), style: t.bodySmall),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Column(children: [
      for (final e in items)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s8),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.card), boxShadow: AppShadows.card),
            child: Material(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.card),
                side: const BorderSide(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => context.push('/analysis/${e.id}'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: Row(children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.description_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e.result.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                        Text('${prettyType(e.result.documentType)} \u00B7 ${formatDate(e.createdAt, ui)}',
                            style: t.bodySmall),
                      ]),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ]),
                ),
              ),
            ),
          ),
        ),
    ]);
  }
}
