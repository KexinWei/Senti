import 'package:flutter/material.dart';
import '../models/target.dart';

class LeftSidebar extends StatelessWidget {
  final List<String> chatHistory;
  final Target currentTarget;
  final Function(Target) onNewChat;
  final Function(String) onSessionSelected;

  const LeftSidebar({
    required this.chatHistory,
    required this.currentTarget,
    required this.onNewChat,
    required this.onSessionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey[850],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: Text("New Chat"),
              onPressed: () => onNewChat(currentTarget),
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                final sessionTitle = chatHistory[index];
                return ListTile(
                  title: Text(sessionTitle),
                  onTap: () => onSessionSelected(sessionTitle),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
