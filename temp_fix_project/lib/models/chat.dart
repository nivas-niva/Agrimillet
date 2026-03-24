class ChatMessage {
  final String id;
  final String sender; // 'user' or 'bot'
  final String text;
  final String language;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.language,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? '',
      sender: json['sender'] ?? '',
      text: json['text'] ?? '',
      language: json['language'] ?? 'en',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'text': text,
      'language': language,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class Chat {
  final String userId;
  final List<ChatMessage> messages;
  final String language;
  final DateTime createdAt;

  Chat({
    required this.userId,
    required this.messages,
    this.language = 'en',
    required this.createdAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      userId: json['userId'] ?? '',
      messages: (json['messages'] as List?)
              ?.map((e) => ChatMessage.fromJson(e))
              .toList() ??
          [],
      language: json['language'] ?? 'en',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }
}
