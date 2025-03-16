import 'package:flutter/material.dart';

class LeftSidebar extends StatelessWidget {
  final List<String> chatHistory;
  final VoidCallback onNewChat;
  final Function(String) onSessionSelected;

  const LeftSidebar({
    required this.chatHistory,
    required this.onNewChat,
    required this.onSessionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey[200],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(child: Icon(Icons.add), onPressed: onNewChat),
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
