import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/content_width.dart';
import '../../../shared/widgets/reactive_mascot.dart';
import 'processing_controller.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({super.key});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(processingProvider.notifier).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(processingProvider);
    ref.listen(processingProvider, (prev, next) {
      final id = next.resultId;
      if (id != null && prev?.resultId != id) {
        context.go('/app/home');
        context.push('/analysis/$id');
      }
    });
    final t = Theme.of(context).textTheme;
    final failed = s.error != null;

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(context.tr('proc_title'))),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ContentWidth(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: ReactiveMascot(failed ? MascotMood.error : MascotMood.thinking, size: 170)),
                  _StepRow(
                    label: context.tr('step_extract'),
                    state: s.stage == ProcStage.extracting && !failed
                        ? _Step.active
                        : (s.ocrText != null ? _Step.done : _Step.failed),
                  ),
                  _StepRow(
                    label: context.tr('step_understand'),
                    state: failed && s.ocrText != null
                        ? _Step.failed
                        : s.stage == ProcStage.analyzing
                            ? (s.resultId != null ? _Step.done : _Step.active)
                            : _Step.waiting,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  if (failed) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(s.error!, style: t.bodyLarge),
                    ),
                    if (s.ocrText != null) ...[
                      const SizedBox(height: AppSpacing.s16),
                      Text(context.tr('found_text'), style: t.titleLarge),
                      const SizedBox(height: AppSpacing.s8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.s16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                        ),
                        child: SelectableText(s.ocrText!, style: t.bodyMedium),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.s24),
                    ElevatedButton(
                      onPressed: () => ref.read(processingProvider.notifier).start(),
                      child: Text(context.tr('try_again')),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    OutlinedButton(onPressed: () => context.pop(), child: Text(context.tr('back'))),
                  ] else ...[
                    const SizedBox(height: AppSpacing.s8),
                    const LinearProgressIndicator(), // indeterminate: no fabricated percentages
                    const SizedBox(height: AppSpacing.s12),
                    Text(context.tr('proc_wait'), style: t.bodySmall),
                    const SizedBox(height: AppSpacing.s24),
                    OutlinedButton(
                      onPressed: () {
                        ref.read(processingProvider.notifier).cancel();
                        context.pop();
                      },
                      child: Text(context.tr('cancel')),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _Step { waiting, active, done, failed }

class _StepRow extends StatelessWidget {
  const _StepRow({required this.label, required this.state});
  final String label;
  final _Step state;

  @override
  Widget build(BuildContext context) {
    final Widget icon = switch (state) {
      _Step.done => const Icon(Icons.check_circle, color: AppColors.success),
      _Step.failed => const Icon(Icons.error_outline, color: AppColors.error),
      _Step.active => const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)),
      _Step.waiting => const Icon(Icons.radio_button_unchecked, color: AppColors.border),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      child: Row(children: [
        SizedBox(width: 24, height: 24, child: Center(child: icon)),
        const SizedBox(width: AppSpacing.s12),
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
      ]),
    );
  }
}
