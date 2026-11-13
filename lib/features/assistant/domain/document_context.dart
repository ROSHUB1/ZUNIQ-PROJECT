import '../../analysis/domain/analysis_result.dart';

/// Compact text version of a saved analysis, sent as context for document chats.
String documentContext(AnalysisResult r) {
  final b = StringBuffer()
    ..writeln('Title: ${r.title}')
    ..writeln('Type: ${r.documentType}')
    ..writeln('Summary: ${r.summary}');
  if (r.details.isNotEmpty) {
    b.writeln('Details:');
    for (final d in r.details) {
      final src = d.originalText.isEmpty ? '' : ' (source text: ${d.originalText})';
      b.writeln('- ${d.label}: ${d.value}$src [${d.evidence}]');
    }
  }
  if (r.requirements.isNotEmpty) {
    b.writeln('Requirements:');
    for (final x in r.requirements) {
      b.writeln('- $x');
    }
  }
  if (r.deadlines.isNotEmpty) {
    b.writeln('Deadlines:');
    for (final d in r.deadlines) {
      b.writeln('- ${d.date} ${d.label}');
    }
  }
  if (r.actions.isNotEmpty) {
    b.writeln('Actions:');
    for (final a in r.actions) {
      b.writeln('- ${a.text} [${a.origin}]');
    }
  }
  if (r.uncertain.isNotEmpty) {
    b.writeln('Unclear:');
    for (final x in r.uncertain) {
      b.writeln('- $x');
    }
  }
  final s = b.toString();
  return s.length > 7000 ? s.substring(0, 7000) : s;
}
