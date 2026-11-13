import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/strings.dart';

/// Primary navigation: bottom bar on phones, rail on wide screens (>= 720dp).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  static const _items = <(IconData, IconData, String)>[
    (Icons.home_outlined, Icons.home, 'nav_home'),
    (Icons.folder_outlined, Icons.folder, 'nav_library'),
    (Icons.chat_bubble_outline, Icons.chat_bubble, 'nav_assistant'),
    (Icons.settings_outlined, Icons.settings, 'nav_settings'),
  ];

  void _go(BuildContext context, int i) {
    if (i == 2) {
      context.push('/chat/general'); // Assistant opens the chat directly
      return;
    }
    navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth >= 720) {
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: (i) => _go(context, i),
                labelType: NavigationRailLabelType.all,
                destinations: [
                  for (final it in _items)
                    NavigationRailDestination(
                        icon: Icon(it.$1), selectedIcon: Icon(it.$2), label: Text(context.tr(it.$3))),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: navigationShell),
            ],
          ),
        );
      }
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (i) => _go(context, i),
          destinations: [
            for (final it in _items)
              NavigationDestination(icon: Icon(it.$1), selectedIcon: Icon(it.$2), label: context.tr(it.$3)),
          ],
        ),
      );
    });
  }
}
