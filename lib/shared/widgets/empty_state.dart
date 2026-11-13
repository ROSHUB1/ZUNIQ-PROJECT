import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'mascot.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.action, this.pose});
  final IconData icon;
  final MascotPose? pose;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pose != null)
              Mascot(pose!, size: 150)
            else
              Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(title, style: t.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.s8),
            Text(message, style: t.bodyMedium?.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: AppSpacing.s24), action!],
          ],
        ),
      ),
    );
  }
}
