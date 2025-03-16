import 'package:flutter/material.dart';
import '../models/people.dart';
import '../components/left_sidebar.dart';

class ChatConversationView extends StatefulWidget {
  final List<String> messages;
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
  List<String> chatHistory = [];

  @override
  void initState() {
    super.initState();
    widget.chatController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  // Save current conversation session title to history (if any messages exist),
  // then clear current conversation and selected people.
  void _startNewChat(People people) {
    if (widget.messages.isNotEmpty) {
      String sessionTitle = "Chat with ${people.name}";
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

  void _handleSendMessage() {
    String message = widget.chatController.text.trim();
    if (message.isEmpty) return;

    widget.onSendMessage();
    setState(() {
      widget.messages.add("AI: This is a dummy reply");
    });
    widget.chatController.clear();
  }

  void dispose() {
    widget.chatController.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine the mood color from the people's current mood.

    return Row(
      children: [
        if (_isHistoryVisible)
          SafeArea(
            child: LeftSidebar(
              chatHistory: chatHistory,
              currentPeople: widget.people,
              onNewChat: _startNewChat,
              onSessionSelected: (sessionTitle) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Selected session: $sessionTitle",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 16.0),
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
                          itemCount: widget.messages.length,
                          itemBuilder: (context, index) {
                            bool isUser =
                                !widget.messages[index].startsWith("AI:");
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
                                      child: Text(widget.messages[index]),
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
