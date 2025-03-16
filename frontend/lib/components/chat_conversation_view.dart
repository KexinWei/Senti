import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../models/target.dart';
import '../components/left_sidebar.dart';

/// A helper function to map mood to a color.
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
  final List<String> messages; // Initial messages from HomeScreen (usually empty)
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

  /// Map to store past sessions.
  /// Key: session title (e.g. "Chat with Alice ## 2023-03-15 14:20")
  /// Value: list of messages for that session.
  Map<String, List<String>> _sessionHistory = {};

  /// Current session messages (the conversation in progress)
  late List<String> _currentMessages;

  @override
  void initState() {
    super.initState();
    // Initialize current messages with what is passed from HomeScreen.
    _currentMessages = List.from(widget.messages);
  }

  /// When the user decides to finish the current chat and start a new one,
  /// save the current session (if not empty) into the session history.
  void _startNewChat(Target target) {
    if (_currentMessages.isNotEmpty) {
      // Create a session title including the current date/time.
      final now = DateTime.now();
      final formattedDate = DateFormat(defaultDatetimeFormat).format(now);
      String sessionTitle = "Chat with ${target.name} ## $formattedDate";
      _sessionHistory[sessionTitle] = List.from(_currentMessages);
    }
    // Clear current messages for a new conversation.
    setState(() {
      _currentMessages.clear();
    });
  }

  /// When a message is sent, append it (and, for demo, a dummy AI reply) to current messages.
  void _handleSendMessage() {
    final text = widget.chatController.text.trim();
    if (text.isEmpty) return;
    widget.onSendMessage();

    setState(() {
      _currentMessages.add("You: $text");
      _currentMessages.add("AI: This is a dummy reply");
    });

    widget.onSendMessage();
    widget.chatController.clear();
  }

  /// Toggle the visibility of the left sidebar.
  void _toggleHistory() {
    setState(() {
      _isHistoryVisible = !_isHistoryVisible;
    });
  }

  /// Load a previously saved session.
  void _loadSession(String sessionTitle) {
    setState(() {
      _currentMessages = List.from(_sessionHistory[sessionTitle] ?? []);
    });
  }

  /// Get a list of session titles for the left sidebar.
  List<String> get _chatHistoryTitles {
    return _sessionHistory.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    final moodColor = getMoodColor(widget.target.currentMood);
    // Parse session strings.
    return Row(
      children: [
        if (_isHistoryVisible)
          LeftSidebar(
            // Pass the list of session titles.
            chatHistory: _chatHistoryTitles,
            currentTarget: widget.target,
            // When "New Chat" is pressed in the sidebar, finish current session.
            onNewChat: (target) => _startNewChat(target),
            // When a session is selected from the sidebar, load its messages.
            onSessionSelected: (sessionTitle) {
              _loadSession(sessionTitle);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Selected session: $sessionTitle"),
                  action: SnackBarAction(label: "OK", onPressed: (){
                    // pass
                  },),
                ),
              );
            },
          ),
        Expanded(
          child: Column(
            children: [
              // Top row with a toggle button and target name.
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isHistoryVisible
                          ? Icons.keyboard_arrow_left
                          : Icons.keyboard_arrow_right,
                    ),
                    tooltip: _isHistoryVisible ? 'Hide History' : 'Show History',
                    onPressed: _toggleHistory,
                  ),
                  Text(widget.target.name),
                ],
              ),
              // Chat messages list (shows current session messages)
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: _currentMessages.length,
                  itemBuilder: (context, index) {
                    bool isUser = !_currentMessages[index].startsWith("AI:");
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.green[100] : Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(_currentMessages[index]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Input area for sending new messages.
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.chatController,
                        textInputAction: TextInputAction.send,
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
                        onSubmitted: (value) => _handleSendMessage(),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _handleSendMessage,
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
