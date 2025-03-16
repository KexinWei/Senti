class Message {
  final int id;
  final int sessionId;

  final String sender;
  final String content;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.sessionId,
    required this.sender,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      sessionId: json['session_id'],
      sender: json['sender'],
      content: json['content'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'sender': sender,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

}
