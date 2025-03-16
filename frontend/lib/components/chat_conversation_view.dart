import 'package:flutter/material.dart';
import '../models/target.dart';
import '../components/left_sidebar.dart';

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

class ChatConversationView extends StatefulWidget {
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
  _ChatConversationViewState createState() => _ChatConversationViewState();
}

class _ChatConversationViewState extends State<ChatConversationView> {
  bool _isHistoryVisible = true;
  List<String> chatHistory = [];

  // Save current conversation session title to history (if any messages exist),
  // then clear current conversation and selected target.
  void _startNewChat(Target target) {
    if (widget.messages.isNotEmpty) {
      String sessionTitle = "Chat with ${target.name}";
      chatHistory.add(sessionTitle);
    }
    setState(() {
      widget.messages.clear();
    });
  }

  void _toggleHistory() {
    setState(() {
      _isHistoryVisible = !_isHistoryVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine the mood color from the target's current mood.
    final moodColor = getMoodColor(widget.target.currentMood);

    return Row(
      children: [
        if (_isHistoryVisible)
          LeftSidebar(
            chatHistory: chatHistory,
            currentTarget: widget.target,
            onNewChat: _startNewChat,
            onSessionSelected: (sessionTitle) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Selected session: $sessionTitle")),
              );
            },
          ),
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(
                      _isHistoryVisible
                          ? Icons.keyboard_arrow_left
                          : Icons.keyboard_arrow_right,
                    ),
                    tooltip:
                        _isHistoryVisible ? 'Hide History' : 'Show History',
                    onPressed: _toggleHistory,
                  ),
                ],
              ),
              // Removed the first Expanded TextField section.
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: widget.messages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(widget.messages[index]),
                    );
                  },
                ),
              ),
              // Chat input with styled text field using moodColor
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.chatController,
                        decoration: InputDecoration(
                          hintText: "Type your message...",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: moodColor,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: widget.onSendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
