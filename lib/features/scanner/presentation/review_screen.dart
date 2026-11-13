import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/content_width.dart';
import 'scan_actions.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(scanSessionProvider);
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('review_title'))),
      body: SafeArea(
        child: session == null
            ? Center(child: Text(context.tr('no_image')))
            : ContentWidth(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(AppSpacing.screenH),
                        children: [
                          for (var i = 0; i < session.paths.length; i++) ...[
                            if (session.paths.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                                child: Text('${context.tr('page')} ${i + 1} / ${session.paths.length}', style: t.bodySmall),
                              ),
                            Container(
                              margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(AppRadius.card),
                                border: Border.all(color: AppColors.border),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.file(File(session.paths[i]), fit: BoxFit.contain),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 0, AppSpacing.screenH, AppSpacing.screenH),
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => context.push('/processing'),
                            icon: const Icon(Icons.auto_awesome),
                            label: Text(context.tr('explain_btn')),
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          OutlinedButton.icon(
                            onPressed: () => startScan(context, ref, session.source, push: false),
                            icon: const Icon(Icons.refresh),
                            label: Text(context.tr('scan_again')),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
