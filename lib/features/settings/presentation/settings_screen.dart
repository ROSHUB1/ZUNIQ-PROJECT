import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/network/server_check.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/content_width.dart';
import '../../language/presentation/language_provider.dart';
import 'settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final lang = ref.watch(languageProvider);
    final info = ref.watch(packageInfoProvider);
    final version = info.when(
      data: (i) => '${i.version} (${i.buildNumber})',
      loading: () => '...',
      error: (_, __) => 'Unavailable',
    );
    return SafeArea(
      child: SingleChildScrollView(
        child: ContentWidth(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.s20, AppSpacing.screenH, AppSpacing.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('set_title'), style: t.headlineMedium),
                const SizedBox(height: AppSpacing.s24),
                _Section(title: context.tr('set_language'), children: [
                  _Tile(
                    icon: Icons.translate,
                    title: context.tr('set_pref'),
                    subtitle: lang == null ? context.tr('set_not_set') : '${lang.nativeName} (${lang.englishName})',
                    onTap: () => context.push('/language'),
                  ),
                ]),
                _Section(title: context.tr('set_account'), children: [
                  _Tile(
                    icon: Icons.person_outline,
                    title: context.tr('set_account_sync'),
                    subtitle: context.tr('set_later'),
                  ),
                ]),
                _Section(title: context.tr('set_server'), children: [
                  _Tile(
                    icon: Icons.wifi_tethering,
                    title: context.tr('set_test'),
                    subtitle: context.tr('set_test_sub'),
                    onTap: () => _showServerCheck(context),
                  ),
                ]),
                _Section(title: context.tr('set_about'), children: [
                  _Tile(
                    icon: Icons.info_outline,
                    title: context.tr('set_about_zuniq'),
                    subtitle: 'Understand Anything.',
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'ZUNIQ',
                      applicationVersion: version,
                      children: const [Text('Understand Anything.')],
                    ),
                  ),
                  _Tile(icon: Icons.tag, title: context.tr('set_version'), subtitle: version),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showServerCheck(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(dialogContext.tr('set_server_title')),
      content: FutureBuilder<String>(
        future: checkServer(),
        builder: (c, s) => s.connectionState != ConnectionState.done
            ? const SizedBox(height: 56, child: Center(child: CircularProgressIndicator()))
            : SelectableText(s.data ?? 'No result'),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(dialogContext.tr('close')))],
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.s8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(children: children),
            ),
          ],
        ),
      );
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.subtitle, this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListTile(
      enabled: onTap != null,
      onTap: onTap,
      leading: Icon(icon, color: onTap != null ? AppColors.primary : AppColors.textSecondary),
      title: Text(title, style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: t.bodyMedium?.copyWith(color: AppColors.textSecondary)),
      trailing: onTap != null ? const Icon(Icons.chevron_right, color: AppColors.textSecondary) : null,
    );
  }
}
