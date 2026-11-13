import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/preferences.dart';
import '../../analysis/domain/analysis_result.dart';

class HistoryEntry {
  const HistoryEntry({required this.id, required this.createdAt, required this.result});
  final String id;
  final DateTime createdAt;
  final AnalysisResult result;

  Map<String, dynamic> toJson() =>
      {'id': id, 'created_at': createdAt.millisecondsSinceEpoch, 'result': result.toJson()};

  factory HistoryEntry.fromJson(Map<String, dynamic> j) => HistoryEntry(
        id: j['id'].toString(),
        createdAt: DateTime.fromMillisecondsSinceEpoch(j['created_at'] as int),
        result: AnalysisResult.fromJson(Map<String, dynamic>.from(j['result'] as Map)),
      );
}

/// Local-only history (device storage). Cloud sync arrives with Supabase auth.
class HistoryNotifier extends Notifier<List<HistoryEntry>> {
  static const _key = 'history_v1';

  @override
  List<HistoryEntry> build() {
    final raw = ref.watch(sharedPreferencesProvider).getStringList(_key) ?? [];
    final out = <HistoryEntry>[];
    for (final r in raw) {
      try {
        out.add(HistoryEntry.fromJson(Map<String, dynamic>.from(jsonDecode(r) as Map)));
      } catch (_) {}
    }
    out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return out;
  }

  Future<void> add(HistoryEntry e) async {
    state = [e, ...state];
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _persist();
  }

  Future<void> _persist() => ref
      .read(sharedPreferencesProvider)
      .setStringList(_key, state.map((e) => jsonEncode(e.toJson())).toList());
}

final historyProvider = NotifierProvider<HistoryNotifier, List<HistoryEntry>>(HistoryNotifier.new);
