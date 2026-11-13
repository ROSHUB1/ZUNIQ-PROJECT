class ChatMessage {
  const ChatMessage({required this.id, required this.role, required this.text, required this.createdAt, this.mood});
  final String id;

  /// 'user' or 'assistant'
  final String role;
  final String text;
  final DateTime createdAt;

  /// AI mood tag: 'explain', 'happy' or 'unsure' (assistant messages only).
  final String? mood;

  bool get isUser => role == 'user';

  Map<String, dynamic> toJson() =>
      {'id': id, 'role': role, 'text': text, 'created_at': createdAt.millisecondsSinceEpoch, if (mood != null) 'mood': mood};

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'].toString(),
        role: j['role'] == 'assistant' ? 'assistant' : 'user',
        text: j['text'].toString(),
        createdAt: DateTime.fromMillisecondsSinceEpoch(j['created_at'] as int),
        mood: j['mood']?.toString(),
      );
}
