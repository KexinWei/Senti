import 'message.dart';

class ChatSession {
  final int id;
  final int peopleId;
  final String title;
  final DateTime createdAt;

  ChatSession({
    required this.id,
    required this.peopleId,
    required this.title,
    required this.createdAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      peopleId: json['people_id'],
      title: json['title'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'people_id': peopleId,
      'title': title,
      'created_at': createdAt.toIso8601String(),
    };
  }

}
