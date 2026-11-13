import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../language/presentation/language_provider.dart';
import '../../library/data/history_provider.dart';
import '../../scanner/presentation/scan_actions.dart';
import '../data/analysis_api.dart';
import '../data/ocr_service.dart';

enum ProcStage { extracting, analyzing }

class ProcState {
  const ProcState({this.stage = ProcStage.extracting, this.error, this.ocrText, this.resultId});
  final ProcStage stage;
  final String? error;
  final String? ocrText;
  final String? resultId;
}

class ProcessingController extends Notifier<ProcState> {
  int _run = 0; // invalidates stale runs (cancel / retry) so results never arrive twice

  @override
  ProcState build() => const ProcState();

  Future<void> start() async {
    final run = ++_run;
    state = const ProcState();
    final paths = ref.read(scanSessionProvider)?.paths ?? const <String>[];
    if (paths.isEmpty) {
      state = const ProcState(error: 'No image selected.');
      return;
    }
    String? text;
    try {
      final parts = <String>[];
      for (var i = 0; i < paths.length; i++) {
        final ocr = await ref.read(ocrServiceProvider).recognize(paths[i]);
        if (run != _run) return;
        final t = ocr.text.trim();
        if (t.isNotEmpty) parts.add(paths.length > 1 ? '--- Page ${i + 1} ---\n$t' : t);
      }
      final extracted = parts.join('\n\n');
      if (extracted.isEmpty) {
        state = const ProcState(error: 'No readable text was found. Try a clearer photo with the text filling the frame.');
        return;
      }
      text = extracted;
      state = ProcState(stage: ProcStage.analyzing, ocrText: text);

      final lang = ref.read(languageProvider);
      final result = await ref.read(analysisApiProvider).analyze(
            text: text,
            languageCode: lang?.code ?? 'en',
            languageName: lang?.englishName ?? 'English',
          );
      if (run != _run) return;
      final entry = HistoryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        result: result,
      );
      await ref.read(historyProvider.notifier).add(entry);
      if (run != _run) return;
      state = ProcState(stage: ProcStage.analyzing, ocrText: text, resultId: entry.id);
    } on AppException catch (e) {
      if (run == _run) state = ProcState(stage: state.stage, error: e.message, ocrText: text);
    } catch (_) {
      if (run == _run) {
        state = ProcState(stage: state.stage, error: 'Something went wrong. Please try again.', ocrText: text);
      }
    }
  }

  void cancel() {
    _run++;
    state = const ProcState();
  }
}

final processingProvider = NotifierProvider<ProcessingController, ProcState>(ProcessingController.new);
