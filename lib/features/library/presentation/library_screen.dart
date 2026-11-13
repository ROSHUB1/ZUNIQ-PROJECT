import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/utils/format.dart';
import '../../../shared/widgets/content_width.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/mascot.dart';
import '../../../shared/widgets/soft_background.dart';
import '../data/history_provider.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(historyProvider);
    final t = Theme.of(context).textTheme;
    final ui = StringsScope.of(context);
    if (items.isEmpty) {
      return SoftBackground(
        child: SafeArea(
          child: EmptyState(
            icon: Icons.folder_open_outlined,
            pose: MascotPose.ready,
            title: context.tr('lib_empty_title'),
            message: context.tr('lib_empty_body'),
            action: ElevatedButton(
              onPressed: () => context.go('/app/home'),
              child: Text(context.tr('lib_scan')),
            ),
          ),
        ),
      );
    }
    return SoftBackground(
      child: SafeArea(
        child: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.s20, AppSpacing.screenH, AppSpacing.s24),
            children: [
              Text(context.tr('lib_title'), style: t.headlineMedium),
              const SizedBox(height: AppSpacing.s16),
              for (final e in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s12),
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
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(AppRadius.buttonSmall),
                              ),
                              child: const Icon(Icons.description_outlined, color: AppColors.primary),
                            ),
                            const SizedBox(width: AppSpacing.s12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(e.result.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                                Text('${prettyType(e.result.documentType)} \u00B7 ${formatDate(e.createdAt, ui)}',
                                    style: t.bodySmall),
                              ]),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (v) {
                                if (v == 'delete') ref.read(historyProvider.notifier).remove(e.id);
                              },
                              itemBuilder: (_) => [PopupMenuItem(value: 'delete', child: Text(context.tr('delete')))],
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
