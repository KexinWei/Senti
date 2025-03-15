import 'package:flutter/material.dart';
import '../models/target.dart';

// A helper function to map mood to a color.
Color getMoodColor(String mood) {
  switch (mood.toLowerCase()) {
    case 'happy':
      return Colors.orange;
    case 'sad':
      return Colors.blue;
    case 'angry':
      return Colors.red;
    case 'calm':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

class ChatConversationView extends StatelessWidget {
  final List<String> messages;
  final TextEditingController chatController;
  final VoidCallback onSendMessage;
  final Target target;

  ChatConversationView({
    required this.messages,
    required this.chatController,
    required this.onSendMessage,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the mood color from the target's current mood.
    final moodColor = getMoodColor(target.currentMood);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 4),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(messages[index]),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: chatController,
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: moodColor, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              IconButton(icon: Icon(Icons.send), onPressed: onSendMessage),
            ],
          ),
        ),
      ],
    );
  }
}
