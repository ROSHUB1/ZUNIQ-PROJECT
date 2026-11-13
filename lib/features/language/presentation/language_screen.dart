import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/content_width.dart';
import '../../../shared/widgets/mascot.dart';
import '../data/supported_languages.dart';
import '../domain/app_language.dart';
import 'language_provider.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  String _query = '';
  AppLanguage? _selected;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(languageProvider);
  }

  Future<void> _continue() async {
    final s = _selected;
    if (s == null) return;
    await ref.read(languageProvider.notifier).select(s);
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/app/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final items = filterLanguages(supportedLanguages, _query);
    return Scaffold(
      appBar: context.canPop() ? AppBar() : null,
      body: SafeArea(
        child: ContentWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.s24, AppSpacing.screenH, AppSpacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text(context.tr('lang_title'), style: t.headlineMedium)),
                      const Mascot(MascotPose.translation, size: 96),
                    ]),
                    const SizedBox(height: AppSpacing.s8),
                    Text(context.tr('lang_body'), style: t.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppSpacing.s8),
                    Text(context.tr('lang_note'), style: t.bodySmall),
                    const SizedBox(height: AppSpacing.s16),
                    TextField(
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(hintText: context.tr('lang_search'), prefixIcon: const Icon(Icons.search)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(child: Text(context.tr('lang_none'), style: t.bodyMedium))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s8),
                        itemBuilder: (context, i) {
                          final l = items[i];
                          final selected = _selected?.code == l.code;
                          return Material(
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              side: BorderSide(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => setState(() => _selected = l),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(l.nativeName, style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                                          Text(l.englishName, style: t.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                    if (selected) const Icon(Icons.check_circle, color: AppColors.primary),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenH),
                child: ElevatedButton(onPressed: _selected == null ? null : _continue, child: Text(context.tr('continue'))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
