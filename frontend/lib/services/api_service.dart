import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/people.dart';
import '../models/chat_session.dart';
import '../models/message.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Get all users
  Future<List<People>> getPeople() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/people'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['people'];
        return data.map((json) => People.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load people');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Create new user
  Future<People> createPeople(
    String name,
    String relationship, {
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/people'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'relationship': relationship,
          'description': description,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body)['people'];
        return People.fromJson(data);
      } else {
        throw Exception('Failed to create people');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Get all sessions for a user
  Future<List<ChatSession>> getSessionsByPeopleId(int peopleId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sessions/person/$peopleId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['sessions'];
        return data.map((json) => ChatSession.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sessions');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Create new session
  Future<ChatSession> createSession(int peopleId, {String? title}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sessions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'people_id': peopleId, 'title': title}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body)['session'];
        return ChatSession.fromJson(data);
      } else {
        throw Exception('Failed to create session');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Get all messages for a session
  Future<List<Message>> getMessagesBySessionId(int sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages?session_id=$sessionId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['messages'];
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Send new message
  Future<Message> sendMessage(int sessionId, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'session_id': sessionId,
          'sender': 'user',
          'content': content,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body)['userMessage'];
        return Message.fromJson(data);
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Delete session
  Future<void> deleteSession(int sessionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/sessions/$sessionId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete session');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Get message count for a session
  Future<int> getSessionMessageCount(int sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sessions/messages/count/$sessionId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'];
      } else {
        throw Exception('Failed to get message count');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
}
