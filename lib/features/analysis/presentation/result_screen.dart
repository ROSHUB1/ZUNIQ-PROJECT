import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/utils/format.dart';
import '../../../shared/widgets/content_width.dart';
import '../../../shared/widgets/reactive_mascot.dart';
import '../../library/data/history_provider.dart';
import '../domain/analysis_result.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(historyProvider).where((e) => e.id == id).firstOrNull;
    final t = Theme.of(context).textTheme;
    if (entry == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(context.tr('r_not_found'))),
      );
    }
    final r = entry.result;
    final ui = StringsScope.of(context);
    final docActions = r.actions.where((a) => a.origin == 'document').toList();
    final suggested = r.actions.where((a) => a.origin != 'document').toList();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('result_title'))),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ContentWidth(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.s8, AppSpacing.screenH, AppSpacing.s32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(r.title, style: t.headlineMedium)),
                    const SizedBox(width: AppSpacing.s8),
                    const ReactiveMascot(MascotMood.explaining, size: 92),
                  ]),
                  const SizedBox(height: AppSpacing.s8),
                  Wrap(spacing: AppSpacing.s8, runSpacing: AppSpacing.s8, children: [
                    _Chip(prettyType(r.documentType)),
                    if (r.sourceLanguage.isNotEmpty) _Chip('${context.tr('r_original')}: ${r.sourceLanguage}'),
                    _Chip(formatDate(entry.createdAt, ui)),
                  ]),
                  const SizedBox(height: AppSpacing.s24),
                  _Section(
                    icon: Icons.lightbulb_outline,
                    title: context.tr('r_summary'),
                    child: Text(r.summary.isEmpty ? context.tr('r_no_summary') : r.summary, style: t.bodyLarge),
                  ),
                  if (r.details.isNotEmpty)
                    _Section(
                      icon: Icons.list_alt,
                      title: context.tr('r_details'),
                      child: Column(children: [for (final d in r.details) _DetailTile(d)]),
                    ),
                  if (r.requirements.isNotEmpty)
                    _Section(
                      icon: Icons.checklist,
                      title: context.tr('r_req'),
                      child: _Bullets(r.requirements),
                    ),
                  if (r.deadlines.isNotEmpty)
                    _Section(
                      icon: Icons.event_outlined,
                      title: context.tr('r_deadlines'),
                      child: Column(children: [for (final d in r.deadlines) _DeadlineTile(d)]),
                    ),
                  if (docActions.isNotEmpty)
                    _Section(
                      icon: Icons.assignment_turned_in_outlined,
                      title: context.tr('r_doc_actions'),
                      child: _Bullets(docActions.map((a) => a.text).toList()),
                    ),
                  if (suggested.isNotEmpty)
                    _Section(
                      icon: Icons.tips_and_updates_outlined,
                      title: context.tr('r_suggested'),
                      subtitle: context.tr('r_suggested_note'),
                      child: _Bullets(suggested.map((a) => a.text).toList()),
                    ),
                  if (r.uncertain.isNotEmpty)
                    _Section(
                      icon: Icons.help_outline,
                      title: context.tr('r_unclear'),
                      child: _Bullets(r.uncertain),
                    ),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/chat/${entry.id}'),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text(context.tr('r_ask')),
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

class _Chip extends StatelessWidget {
  const _Chip(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primaryDark)),
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.child, this.subtitle});
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.s8),
              Expanded(child: Text(title, style: t.titleLarge)),
            ]),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.s4),
              Text(subtitle!, style: t.bodySmall),
            ],
            const SizedBox(height: AppSpacing.s12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets(this.items);
  final List<String> items;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final i in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8, right: 10),
                  child: Icon(Icons.circle, size: 6, color: AppColors.primary),
                ),
                Expanded(child: Text(i, style: Theme.of(context).textTheme.bodyLarge)),
              ]),
            ),
        ],
      );
}

class _DetailTile extends StatelessWidget {
  const _DetailTile(this.d);
  final DetailItem d;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final inferred = d.evidence == 'inferred';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(d.label, style: t.bodySmall),
        const SizedBox(height: 2),
        Text(d.value, style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        if (d.originalText.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppRadius.buttonSmall),
            ),
            child: Text('\u201C${d.originalText}\u201D', style: t.bodyMedium),
          ),
        ],
        const SizedBox(height: AppSpacing.s8),
        Text(
          context.tr(inferred ? 'r_interpreted' : 'r_stated'),
          style: t.bodySmall?.copyWith(color: inferred ? AppColors.warning : AppColors.success),
        ),
      ]),
    );
  }
}

class _DeadlineTile extends StatelessWidget {
  const _DeadlineTile(this.d);
  final DeadlineItem d;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(d.date, style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        if (d.label.isNotEmpty) Text(d.label, style: t.bodyMedium),
        if (d.originalText.isNotEmpty)
          Text('\u201C${d.originalText}\u201D', style: t.bodySmall),
      ]),
    );
  }
}
