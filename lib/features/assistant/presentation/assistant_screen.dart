import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/strings.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/mascot.dart';
import '../../../shared/widgets/soft_background.dart';

class AssistantScreen extends StatelessWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context) => SoftBackground(
        child: SafeArea(
          child: EmptyState(
            icon: Icons.chat_bubble_outline,
            pose: MascotPose.ask,
            title: context.tr('asst_title'),
            message: context.tr('asst_body'),
            action: ElevatedButton(
              onPressed: () => context.push('/chat/general'),
              child: Text(context.tr('asst_start')),
            ),
          ),
        ),
      );
}
