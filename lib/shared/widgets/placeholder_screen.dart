import 'package:flutter/material.dart';

import 'empty_state.dart';

/// Honest stand-in for features scheduled in a later milestone.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, required this.message, this.icon = Icons.construction_outlined});
  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SafeArea(child: EmptyState(icon: icon, title: 'Coming soon', message: message)),
      );
}
