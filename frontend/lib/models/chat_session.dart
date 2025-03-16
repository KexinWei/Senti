import 'message.dart';

class ChatSession {
  final String sessionId;
  String title;
  DateTime lastMessageTime;
  List<Message> messages;

  ChatSession({
    required this.sessionId,
    required this.title,
    required this.lastMessageTime,
    required this.messages,
  });
}
