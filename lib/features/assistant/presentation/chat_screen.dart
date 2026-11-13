import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/utils/format.dart';
import '../../../shared/widgets/content_width.dart';
import '../../../shared/widgets/floating_mascot.dart';
import '../../../shared/widgets/mascot.dart';
import '../../../shared/widgets/reactive_mascot.dart';
import '../../../shared/widgets/soft_background.dart';
import '../../../shared/widgets/zuniq_logo.dart';
import '../../library/data/history_provider.dart';
import '../../scanner/presentation/scan_actions.dart';
import '../domain/chat_models.dart';
import 'assistant_intro.dart';
import 'chat_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId, this.prefill});
  final String conversationId;
  final String? prefill;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  MascotMood? _reaction;
  Timer? _reactTimer;

  bool get _isGeneral => widget.conversationId == 'general';

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() {});
    });
    final p = widget.prefill;
    if (p != null && p.isNotEmpty) {
      _input.text = p;
      _input.selection = TextSelection.collapsed(offset: p.length);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _reactTimer?.cancel();
    _input.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Shows a short-lived expression, then returns to the normal mood.
  void _react(MascotMood mood) {
    setState(() => _reaction = mood);
    _reactTimer?.cancel();
    _reactTimer = Timer(const Duration(milliseconds: 4200), () {
      if (mounted) setState(() => _reaction = null);
    });
  }

  MascotMood _moodFor(ChatState chat, bool showEmpty) {
    if (chat.error != null) return MascotMood.error;
    if (chat.sending) return MascotMood.thinking;
    if (_focus.hasFocus && _input.text.trim().isNotEmpty) return MascotMood.listening;
    if (_reaction != null) return _reaction!;
    return showEmpty ? MascotMood.greeting : MascotMood.idle;
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final end = _scroll.position.maxScrollExtent;
      if (MediaQuery.disableAnimationsOf(context)) {
        _scroll.jumpTo(end);
      } else {
        _scroll.animateTo(end, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
      }
    });
  }

  void _send(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    _input.clear();
    setState(() {});
    ref.read(chatProvider(widget.conversationId).notifier).send(t);
  }

  void _fill(String text) {
    setState(() {
      _input.text = text;
      _input.selection = TextSelection.collapsed(offset: text.length);
    });
    _focus.requestFocus();
  }

  Future<void> _onAttach(String v) async {
    switch (v) {
      case 'scan':
        await startScan(context, ref, ScanSource.scanner);
      case 'photos':
        await startScan(context, ref, ScanSource.gallery);
      case 'paste':
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        final text = data?.text ?? '';
        if (text.isNotEmpty && mounted) _fill('${_input.text}$text');
      case 'docs':
        _scaffoldKey.currentState?.openDrawer();
    }
  }

  Future<void> _newChat() async {
    await ref.read(chatProvider('general').notifier).clear();
    if (!mounted) return;
    if (!_isGeneral) context.pushReplacement('/chat/general');
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.conversationId;
    final chat = ref.watch(chatProvider(id));
    final docs = ref.watch(historyProvider);
    final doc = docs.where((e) => e.id == id).firstOrNull;
    ref.listen(chatProvider(id), (prev, next) {
      if (prev?.messages.length != next.messages.length || prev?.sending != next.sending) _toBottom();
      final grew = next.messages.length > (prev?.messages.length ?? 0);
      if (grew && next.messages.isNotEmpty && !next.messages.last.isUser) {
        final m = next.messages.last.mood;
        _react(m == 'happy' ? MascotMood.happy : (m == 'unsure' ? MascotMood.unsure : MascotMood.explaining));
      }
    });

    if (!_isGeneral && doc == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(context.tr('r_not_found'))));
    }

    final t = Theme.of(context).textTheme;
    final canSend = _input.text.trim().isNotEmpty && !chat.sending;
    final showEmpty = chat.messages.isEmpty && !chat.sending;
    final mood = _moodFor(chat, showEmpty);

    return Scaffold(
      key: _scaffoldKey,
      drawer: _ChatDrawer(currentId: id),
      body: SoftBackground(
        child: SafeArea(
          child: ContentWidth(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, AppSpacing.s8),
                  child: Row(
                    children: [
                      _RoundButton(icon: Icons.menu_rounded, onTap: () => _scaffoldKey.currentState?.openDrawer()),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!showEmpty) ...[
                              ReactiveMascot(mood, size: 54, onTap: () => _react(MascotMood.happy)),
                              const SizedBox(width: 6),
                            ],
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_isGeneral ? context.tr('asst_title') : context.tr('chat_title_doc'),
                                      style: t.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  if (doc != null)
                                    Text(doc.result.title, style: t.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _RoundButton(icon: Icons.add_comment_outlined, onTap: _newChat),
                    ],
                  ),
                ),
                Expanded(
                  child: showEmpty
                      ? _Empty(
                          isGeneral: _isGeneral,
                          onSend: _send,
                          onFill: _fill,
                          onScan: () => startScan(context, ref, ScanSource.scanner),
                          mood: mood,
                          onMascotTap: () => _react(MascotMood.happy),
                        )
                      : ListView(
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.s8, AppSpacing.screenH, AppSpacing.s16),
                          children: [
                            for (final m in chat.messages) _Bubble(m),
                            if (chat.sending) const _Typing(),
                          ],
                        ),
                ),
                if (chat.error != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(AppSpacing.screenH, 0, AppSpacing.screenH, AppSpacing.s8),
                    padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(children: [
                      const Mascot(MascotPose.error, size: 40),
                      const SizedBox(width: 8),
                      Expanded(child: Text(chat.error!, style: t.bodyMedium)),
                      TextButton(
                        onPressed: () => ref.read(chatProvider(id).notifier).retry(),
                        child: Text(context.tr('retry')),
                      ),
                    ]),
                  ),
                Container(
                  margin: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s4, AppSpacing.s16, AppSpacing.s12),
                  padding: const EdgeInsets.fromLTRB(4, 4, 6, 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.add_rounded, color: AppColors.textPrimary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        onSelected: _onAttach,
                        itemBuilder: (_) => [
                          _menuItem('scan', Icons.document_scanner_outlined, context.tr('scan_title')),
                          _menuItem('photos', Icons.image_outlined, context.tr('attach_photos')),
                          _menuItem('paste', Icons.content_paste_rounded, context.tr('attach_paste')),
                          _menuItem('docs', Icons.folder_open_outlined, context.tr('attach_docs')),
                        ],
                      ),
                      Expanded(
                        child: TextField(
                          controller: _input,
                          focusNode: _focus,
                          minLines: 1,
                          maxLines: 5,
                          textInputAction: TextInputAction.newline,
                          onChanged: (_) => setState(() {}),
                          style: t.bodyLarge,
                          decoration: InputDecoration(
                            hintText: context.tr('chat_hint'),
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: canSend ? AppColors.primary : AppColors.surfaceSecondary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: canSend ? () => _send(_input.text) : null,
                            tooltip: context.tr('send'),
                            icon: Icon(Icons.arrow_upward_rounded,
                                color: canSend ? Colors.white : AppColors.textSecondary, size: 22),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

PopupMenuItem<String> _menuItem(String value, IconData icon, String label) => PopupMenuItem<String>(
      value: value,
      child: Row(children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Flexible(child: Text(label)),
      ]),
    );

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: AppShadows.card),
        child: Material(
          color: AppColors.surface,
          shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(width: 44, height: 44, child: Icon(icon, color: AppColors.textPrimary)),
          ),
        ),
      );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s8),
        child: Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(width: 14),
                Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600))),
                const Icon(Icons.north_east_rounded, size: 16, color: AppColors.textSecondary),
              ]),
            ),
          ),
        ),
      );
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.isGeneral,
    required this.onSend,
    required this.onFill,
    required this.onScan,
    required this.mood,
    required this.onMascotTap,
  });
  final MascotMood mood;
  final VoidCallback onMascotTap;
  final bool isGeneral;
  final void Function(String) onSend;
  final void Function(String) onFill;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final rows = isGeneral
        ? [
            _ActionRow(icon: Icons.document_scanner_outlined, label: context.tr('scan_title'), onTap: onScan),
            _ActionRow(
                icon: Icons.text_snippet_outlined,
                label: context.tr('act_explain'),
                onTap: () => onFill(context.tr('pre_explain'))),
            _ActionRow(
                icon: Icons.translate,
                label: context.tr('act_translate'),
                onTap: () => onFill(context.tr('pre_translate'))),
            _ActionRow(
                icon: Icons.help_outline_rounded,
                label: context.tr('sug_term'),
                onTap: () => onFill(context.tr('sug_term'))),
          ]
        : [
            _ActionRow(icon: Icons.auto_awesome, label: context.tr('sug_simple'), onTap: () => onSend(context.tr('sug_simple'))),
            _ActionRow(icon: Icons.checklist_rounded, label: context.tr('sug_next'), onTap: () => onSend(context.tr('sug_next'))),
            _ActionRow(icon: Icons.translate, label: context.tr('sug_translate'), onTap: () => onSend(context.tr('sug_translate'))),
            _ActionRow(icon: Icons.help_outline_rounded, label: context.tr('sug_term'), onTap: () => onSend(context.tr('sug_term'))),
          ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.s16, AppSpacing.screenH, AppSpacing.s16),
      children: [
        if (isGeneral)
          AssistantIntro(mood: mood, onMascotTap: onMascotTap)
        else ...[
          const Center(child: FloatingMascot(MascotPose.ask, size: 150)),
          const SizedBox(height: AppSpacing.s8),
          Text(context.tr('chat_d_title'), style: t.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.s4),
          Text(context.tr('chat_d_body'),
              style: t.bodyMedium?.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
        const SizedBox(height: AppSpacing.s24),
        ...rows,
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.m);
  final ChatMessage m;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final maxW = (MediaQuery.sizeOf(context).width * 0.84).clamp(0.0, 560.0);
    if (m.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s12),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(maxWidth: maxW),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: SelectableText(m.text, style: t.bodyLarge?.copyWith(color: Colors.white)),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Mascot(poseForMood(m.mood), size: 42),
          const SizedBox(width: AppSpacing.s8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: maxW - 50),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppShadows.card,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: SelectableText(m.text, style: t.bodyLarge),
                ),
                const SizedBox(height: 2),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: m.text));
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(context.tr('copied')), duration: const Duration(seconds: 1)));
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.copy_rounded, size: 16, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Typing extends StatelessWidget {
  const _Typing();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s12),
        child: Row(children: [
          const Mascot(MascotPose.processing, size: 42),
          const SizedBox(width: AppSpacing.s8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: const _Dots(),
          ),
        ]),
      );
}

class _Dots extends StatefulWidget {
  const _Dots();

  @override
  State<_Dots> createState() => _DotsState();
}

class _DotsState extends State<_Dots> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(
                    0.25 + 0.75 * ((math.sin(2 * math.pi * (_c.value - i * 0.18)) + 1) / 2),
                  ),
                ),
              ),
          ],
        ),
      );
}

class _ChatDrawer extends ConsumerWidget {
  const _ChatDrawer({required this.currentId});
  final String currentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(historyProvider);
    final t = Theme.of(context).textTheme;
    final ui = StringsScope.of(context);
    void go(void Function(GoRouter r) action) {
      final router = GoRouter.of(context);
      Navigator.of(context).pop();
      action(router);
    }

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: ZuniqWordmark(size: 28),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(children: [
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.add_comment_outlined, color: AppColors.primary),
                  title: Text(context.tr('chat_new'), style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  onTap: () async {
                    await ref.read(chatProvider('general').notifier).clear();
                    go((r) => r.pushReplacement('/chat/general'));
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.folder_outlined, color: AppColors.primary),
                  title: Text(context.tr('nav_library'), style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  onTap: () => go((r) => r.go('/app/library')),
                ),
              ]),
            ),
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(context.tr('drawer_docs'), style: t.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
            ),
            Expanded(
              child: docs.isEmpty
                  ? Center(child: Text(context.tr('drawer_no_docs'), style: t.bodyMedium))
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        for (final e in docs)
                          ListTile(
                            selected: e.id == currentId,
                            selectedTileColor: AppColors.primaryLight,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            leading: const Icon(Icons.description_outlined),
                            title: Text(e.result.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text('${prettyType(e.result.documentType)} \u00B7 ${formatDate(e.createdAt, ui)}',
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            onTap: () => go((r) => r.pushReplacement('/chat/${e.id}')),
                          ),
                      ],
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
                title: Text(context.tr('nav_settings'), style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                onTap: () => go((r) => r.go('/app/settings')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
