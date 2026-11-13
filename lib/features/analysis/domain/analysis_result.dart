String _s(dynamic v) => v == null ? '' : v.toString().trim();

List<Map<String, dynamic>> _maps(dynamic v) =>
    v is List ? v.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList() : [];

List<String> _texts(dynamic v) {
  if (v is! List) return [];
  final out = <String>[];
  for (final e in v) {
    if (e is Map) {
      final t = _s(e['text'] ?? e['value'] ?? e['label']);
      if (t.isNotEmpty) out.add(t);
    } else {
      final t = _s(e);
      if (t.isNotEmpty) out.add(t);
    }
  }
  return out;
}

class DetailItem {
  const DetailItem({required this.label, required this.value, required this.originalText, required this.evidence});
  final String label, value, originalText;

  /// 'explicit' (stated in the document) or 'inferred' (interpreted by the AI).
  final String evidence;

  factory DetailItem.fromJson(Map<String, dynamic> j) => DetailItem(
        label: _s(j['label']),
        value: _s(j['value']),
        originalText: _s(j['original_text']),
        evidence: _s(j['evidence']) == 'inferred' ? 'inferred' : 'explicit',
      );
  Map<String, dynamic> toJson() =>
      {'label': label, 'value': value, 'original_text': originalText, 'evidence': evidence};
}

class DeadlineItem {
  const DeadlineItem({required this.label, required this.date, required this.originalText});
  final String label, date, originalText;

  factory DeadlineItem.fromJson(Map<String, dynamic> j) => DeadlineItem(
      label: _s(j['label']), date: _s(j['date']), originalText: _s(j['original_text']));
  Map<String, dynamic> toJson() => {'label': label, 'date': date, 'original_text': originalText};
}

class ActionItem {
  const ActionItem({required this.text, required this.origin});
  final String text;

  /// 'document' (requested by the document) or 'inferred' (suggested by ZUNIQ).
  final String origin;

  factory ActionItem.fromJson(Map<String, dynamic> j) =>
      ActionItem(text: _s(j['text']), origin: _s(j['origin']) == 'document' ? 'document' : 'inferred');
  Map<String, dynamic> toJson() => {'text': text, 'origin': origin};
}

class AnalysisResult {
  const AnalysisResult({
    required this.title,
    required this.documentType,
    required this.sourceLanguage,
    required this.explanationLanguage,
    required this.summary,
    required this.details,
    required this.requirements,
    required this.deadlines,
    required this.actions,
    required this.uncertain,
  });

  final String title, documentType, sourceLanguage, explanationLanguage, summary;
  final List<DetailItem> details;
  final List<String> requirements;
  final List<DeadlineItem> deadlines;
  final List<ActionItem> actions;
  final List<String> uncertain;

  factory AnalysisResult.fromJson(Map<String, dynamic> j) {
    final type = _s(j['document_type']);
    final title = _s(j['title']);
    return AnalysisResult(
      title: title.isEmpty ? 'Untitled document' : title,
      documentType: type.isEmpty ? 'document' : type,
      sourceLanguage: _s(j['source_language']),
      explanationLanguage: _s(j['explanation_language']),
      summary: _s(j['summary']),
      details: _maps(j['important_details']).map(DetailItem.fromJson).where((d) => d.label.isNotEmpty || d.value.isNotEmpty).toList(),
      requirements: _texts(j['requirements']),
      deadlines: _maps(j['deadlines']).map(DeadlineItem.fromJson).where((d) => d.date.isNotEmpty || d.label.isNotEmpty).toList(),
      actions: _maps(j['action_items']).map(ActionItem.fromJson).where((a) => a.text.isNotEmpty).toList(),
      uncertain: _texts(j['uncertain_information']),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'document_type': documentType,
        'source_language': sourceLanguage,
        'explanation_language': explanationLanguage,
        'summary': summary,
        'important_details': details.map((e) => e.toJson()).toList(),
        'requirements': requirements,
        'deadlines': deadlines.map((e) => e.toJson()).toList(),
        'action_items': actions.map((e) => e.toJson()).toList(),
        'uncertain_information': uncertain,
      };
}
