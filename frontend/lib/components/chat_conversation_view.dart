import 'package:flutter/material.dart';
import '../models/people.dart';
import '../models/chat_session.dart';
import '../models/message.dart';
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

  ChatSession? _currentSession;
  List<ChatSession> _sessionHistory = [];

  @override
  void initState() {
    super.initState();
    widget.chatController.addListener(_onTextChanged);
    _currentSession = ChatSession(
      sessionId: UniqueKey().toString(), // or use another unique identifier
      title: "Chat with ${widget.people.name}",
      lastMessageTime: DateTime.now(),
      messages: [],
    );
  }

  void _onTextChanged() {
    setState(() {});
  }

  /// When the user decides to finish the current chat and start a new one,
  /// clear the current session so that a new session is created upon the next message.
  void _startNewChat(People people) {
    setState(() {
      _currentSession = null;
    });
  }

  void _handleSendMessage() {
    final text = widget.chatController.text.trim();
    if (text.isEmpty) return;
    widget.onSendMessage();

    setState(() {
      final now = DateTime.now();

      // If no session is active, create a new one.
      if (_currentSession == null) {
        _currentSession = ChatSession(
          sessionId: UniqueKey().toString(),
          title: "Chat with ${widget.people.name}",
          lastMessageTime: now,
          messages: [],
        );
      } else {
        // Update the session's last message time and title.
        _currentSession!.lastMessageTime = now;
        _currentSession!.title = "Chat with ${widget.people.name}";
      }

      // Create a new message (you can customize the sender logic as needed).
      Message newUserMessage = Message(
        sessionId: _currentSession!.sessionId,
        sender: "You",
        content: text,
        createdAt: now,
      );
      _currentSession!.messages.add(newUserMessage);

      // Optionally, add a dummy AI reply:
      Message aiReply = Message(
        sessionId: _currentSession!.sessionId,
        sender: "AI",
        content: "This is a dummy reply",
        createdAt: now,
      );
      _currentSession!.messages.add(aiReply);

      // Update session history: if this session is not already in history, add it.
      if (!_sessionHistory.contains(_currentSession)) {
        _sessionHistory.add(_currentSession!);
      }
    });
    widget.chatController.clear();
  }

  /// Toggle the visibility of the left sidebar.
  void _toggleHistory() {
    setState(() {
      _isHistoryVisible = !_isHistoryVisible;
    });
  }

  void _loadSession(String sessionId) {
    setState(() {
      _currentSession = _sessionHistory.firstWhere(
        (session) => session.sessionId == sessionId,
        orElse:
            () =>
                _currentSession!, // Optionally handle the case where the session is not found.
      );
    });
  }

  // void _handleSendMessage() {
  //   String message = widget.chatController.text.trim();
  //   if (message.isEmpty) return;
  //   widget.onSendMessage();
  //   // Optionally, clear the text field after sending
  //   widget.chatController.clear();
  // }

  @override
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
              chatHistory: _sessionHistory,
              currentPeople: widget.people,
              // When "New Chat" is pressed in the sidebar, finish current session.
              onNewChat: (people) => _startNewChat(people),
              // When a session is selected from the sidebar, load its messages.
              onSessionSelected: (sessionTitle) {
                _loadSession(sessionTitle);
              },
              currentSessionId: _currentSession?.sessionId,
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
                          itemCount: _currentSession?.messages.length ?? 0,
                          itemBuilder: (context, index) {
                            final message = _currentSession!.messages[index];
                            bool isUser = message.sender != "AI";
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
                                          isUser
                                              ? Colors.white
                                              : Colors.blue[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            0.7,
                                      ),
                                      child: Text(message.content),
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
                            hintStyle: TextStyle(color: Colors.grey),
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
