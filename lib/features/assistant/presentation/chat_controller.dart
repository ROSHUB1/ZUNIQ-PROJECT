import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/storage/preferences.dart';
import '../../language/presentation/language_provider.dart';
import '../../library/data/history_provider.dart';
import '../data/chat_api.dart';
import '../domain/chat_models.dart';
import '../domain/document_context.dart';

class ChatState {
  const ChatState({this.messages = const [], this.sending = false, this.error});
  final List<ChatMessage> messages;
  final bool sending;
  final String? error;

  ChatState copyWith({List<ChatMessage>? messages, bool? sending, String? error, bool clearError = false}) =>
      ChatState(
        messages: messages ?? this.messages,
        sending: sending ?? this.sending,
        error: clearError ? null : (error ?? this.error),
      );
}

/// One conversation per id. 'general' has no document; any other id is a saved document's id.
class ChatController extends FamilyNotifier<ChatState, String> {
  String get _key => 'chat_$arg';

  @override
  ChatState build(String arg) {
    final raw = ref.read(sharedPreferencesProvider).getStringList('chat_$arg') ?? [];
    final msgs = <ChatMessage>[];
    for (final r in raw) {
      try {
        msgs.add(ChatMessage.fromJson(Map<String, dynamic>.from(jsonDecode(r) as Map)));
      } catch (_) {}
    }
    return ChatState(messages: msgs);
  }

  Future<void> send(String text) async {
    final t = text.trim();
    if (t.isEmpty || state.sending) return;
    final msg = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: 'user',
      text: t,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, msg], clearError: true);
    await _persist();
    await _ask();
  }

  Future<void> retry() async {
    if (state.sending) return;
    await _ask();
  }

  Future<void> clear() async {
    state = const ChatState();
    await ref.read(sharedPreferencesProvider).remove(_key);
  }

  Future<void> _ask() async {
    if (state.messages.isEmpty || !state.messages.last.isUser) return;
    state = state.copyWith(sending: true, clearError: true);
    try {
      final lang = ref.read(languageProvider);
      final res = await ref.read(chatApiProvider).chat(
            history: [
              for (final m in state.messages) {'role': m.role, 'content': m.text},
            ],
            context: _context(),
            languageCode: lang?.code ?? 'en',
            languageName: lang?.englishName ?? 'English',
          );
      state = state.copyWith(
        sending: false,
        messages: [
          ...state.messages,
          ChatMessage(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            role: 'assistant',
            text: res.reply,
            mood: res.mood,
            createdAt: DateTime.now(),
          ),
        ],
      );
      await _persist();
    } on AppException catch (e) {
      state = state.copyWith(sending: false, error: e.message);
    } catch (_) {
      state = state.copyWith(sending: false, error: 'Something went wrong. Please try again.');
    }
  }

  String? _context() {
    if (arg == 'general') return null;
    final e = ref.read(historyProvider).where((x) => x.id == arg).firstOrNull;
    return e == null ? null : documentContext(e.result);
  }

  Future<void> _persist() {
    final recent = state.messages.length > 100 ? state.messages.sublist(state.messages.length - 100) : state.messages;
    return ref.read(sharedPreferencesProvider).setStringList(_key, recent.map((m) => jsonEncode(m.toJson())).toList());
  }
}

final chatProvider = NotifierProvider.family<ChatController, ChatState, String>(ChatController.new);
