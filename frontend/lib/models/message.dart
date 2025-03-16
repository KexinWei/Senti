class Message {
  final String sessionId;
  final String sender;
  final String content;
  final DateTime createdAt;

  Message({
    required this.sessionId,
    required this.sender,
    required this.content,
    required this.createdAt,
  });
}
