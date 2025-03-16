import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../models/people.dart';
import '../components/left_sidebar.dart';

class ChatConversationView extends StatefulWidget {
  final List<String>
  messages; // Initial messages from HomeScreen (usually empty)
  final TextEditingController chatController;
  final VoidCallback onSendMessage;
  final People people;

  ChatConversationView({
    required this.messages,
    required this.chatController,
    required this.onSendMessage,
    required this.people,
  });

  @override
  _ChatConversationViewState createState() => _ChatConversationViewState();
}

class _ChatConversationViewState extends State<ChatConversationView> {
  bool _isHistoryVisible = false;

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
    widget.chatController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  /// When the user decides to finish the current chat and start a new one,
  /// save the current session (if not empty) into the session history.
  void _startNewChat(People people) {
    setState(() {
      if (_currentMessages.isNotEmpty) {
        // Create a session title including the current date/time.
        final now = DateTime.now();
        final formattedDate = DateFormat(defaultDatetimeFormat).format(now);
        String sessionTitle = "Chat with ${people.name} ## $formattedDate";
        _sessionHistory[sessionTitle] = List.from(_currentMessages);
      }
      // Clear current messages to start a new chat.
      _currentMessages = [];
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

  void _loadSession(String sessionTitle) {
    setState(() {
      _currentMessages = List.from(_sessionHistory[sessionTitle] ?? []);
    });
  }

  // void _handleSendMessage() {
  //   String message = widget.chatController.text.trim();
  //   if (message.isEmpty) return;
  //   widget.onSendMessage();
  //   // Optionally, clear the text field after sending
  //   widget.chatController.clear();
  // }

  /// Get a list of session titles for the left sidebar.
  List<String> get _chatHistoryTitles {
    return _sessionHistory.keys.toList();
  }

  void dispose() {
    widget.chatController.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (_isHistoryVisible)
          SafeArea(
            child: LeftSidebar(
              // Pass the list of session titles.
              chatHistory: _chatHistoryTitles,
              currentPeople: widget.people,
              // When "New Chat" is pressed in the sidebar, finish current session.
              onNewChat: (people) => _startNewChat(people),
              // When a session is selected from the sidebar, load its messages.
              onSessionSelected: (sessionTitle) {
                _loadSession(sessionTitle);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Selected session: $sessionTitle"),
                    action: SnackBarAction(
                      label: "OK",
                      onPressed: () {
                        // pass
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              top: kToolbarHeight + 16.0,
              bottom: 16.0,
            ),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column with toggle and new chat buttons
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _isHistoryVisible
                                  ? Icons.keyboard_arrow_left
                                  : Icons.keyboard_arrow_right,
                              size: 32,
                              color: Colors.white,
                            ),
                            tooltip:
                                _isHistoryVisible
                                    ? 'Hide History'
                                    : 'Show History',
                            onPressed: _toggleHistory,
                          ),
                          SizedBox(height: 8),
                          IconButton(
                            icon: Icon(
                              Icons.add,
                              size: 32,
                              color: Colors.white,
                            ),
                            tooltip: 'New Chat',
                            onPressed: () => _startNewChat(widget.people),
                          ),
                        ],
                      ),
                      // Right side with text bubbles
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.only(
                            top: 0,
                            left: 8,
                            right: 8,
                            bottom: 8,
                          ),
                          itemCount: _currentMessages.length,
                          itemBuilder: (context, index) {
                            bool isUser =
                                !_currentMessages[index].startsWith("AI:");
                            return Container(
                              margin: EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    isUser
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          isUser ? Colors.white : Colors.blue,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            0.7,
                                      ),
                                      child: Text(_currentMessages[index]),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
                          textInputAction: TextInputAction.send,
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 5,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Type your message...",
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2.0,
                                color: Colors.white,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                          ),
                          onSubmitted: (value) {
                            _handleSendMessage();
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon:
                            widget.chatController.text.isNotEmpty
                                ? Icon(Icons.send, color: Colors.white)
                                : Icon(Icons.send, color: Colors.grey),
                        onPressed:
                            widget.chatController.text.isNotEmpty
                                ? _handleSendMessage
                                : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
