import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../features/language/presentation/language_provider.dart';
import 'router.dart';

class ZuniqApp extends ConsumerWidget {
  const ZuniqApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'ZUNIQ',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: ref.watch(routerProvider),
        builder: (context, child) => Consumer(
          builder: (context, ref, _) => StringsScope(
            code: uiCodeFor(ref.watch(languageProvider)?.code),
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      );
}
