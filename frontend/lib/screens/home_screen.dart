import 'package:flutter/material.dart';
import '../models/target.dart';
import '../components/target_selection_view.dart';
import '../components/chat_conversation_view.dart';
import '../components/left_sidebar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> messages = [];
  List<String> chatHistory =
      []; // This list stores conversation session titles.
  final TextEditingController _chatController = TextEditingController();
  bool _showAddUserForm = false;

  // Dummy AI target generation helper.
  Target _createGeneratedTarget(String name, String relationship) {
    return Target(
      name: name,
      relationship: relationship,
      currentMood: _generateMood(name, relationship),
      preferences: _generatePreferences(name, relationship),
      personality: _generatePersonality(name, relationship),
    );
  }

  String _generateMood(String name, String relationship) => "Happy";
  List<String> _generatePreferences(String name, String relationship) => [
    "reading",
    "music",
  ];
  List<String> _generatePersonality(String name, String relationship) => [
    "friendly",
    "outgoing",
  ];

  late List<Target> targets = [
    _createGeneratedTarget("Alice Johnson", "Friend"),
    _createGeneratedTarget("Bob Smith", "Colleague"),
  ];

  Target? selectedTarget;

  void _sendMessage() {
    String message = _chatController.text;
    if (message.isNotEmpty) {
      setState(() {
        messages.add(message);
      });
      _chatController.clear();
    }
  }

  // Save current conversation session title to history (if any messages exist),
  // then clear current conversation and selected target.
  void _startNewChat() {
    if (selectedTarget != null && messages.isNotEmpty) {
      // Create a session title (for example, "Chat with Alice - 10:30 AM")
      String sessionTitle = "Chat with ${selectedTarget!.name}";
      chatHistory.add(sessionTitle);
    }
    setState(() {
      selectedTarget = null;
      messages.clear();
      _showAddUserForm = false;
    });
  }

  void _selectTarget(Target target) {
    setState(() {
      selectedTarget = target;
      messages.clear();
      _showAddUserForm = false;
    });
  }

  // Updated to use positional parameters.
  void _createTarget(String name, String relationship) {
    Target newTarget = _createGeneratedTarget(name, relationship);
    setState(() {
      targets.add(newTarget);
      selectedTarget = newTarget;
      messages.clear();
      _showAddUserForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading:
            selectedTarget != null
                ? IconButton(
                  icon: Icon(Icons.home),
                  tooltip: "Home",
                  onPressed: _startNewChat,
                )
                : null,
        title:
            selectedTarget != null
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(selectedTarget!.name),
                    Text(
                      "${selectedTarget!.relationship} | ${selectedTarget!.currentMood}",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                )
                : Text("Chat App"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                CircleAvatar(child: Icon(Icons.person)),
                SizedBox(width: 8),
                Text("User Name"),
              ],
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child:
                selectedTarget == null
                    ? TargetSelectionView(
                      targets: targets,
                      showAddUserForm: _showAddUserForm,
                      onTargetSelected: _selectTarget,
                      onShowAddForm: () {
                        setState(() {
                          _showAddUserForm = true;
                        });
                      },
                      onCreateTarget: _createTarget,
                    )
                    : ChatConversationView(
                      messages: messages,
                      chatController: _chatController,
                      onSendMessage: _sendMessage,
                      target: selectedTarget!,
                    ),
          ),
        ],
      ),
    );
  }
}
