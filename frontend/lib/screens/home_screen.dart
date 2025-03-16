import 'package:flutter/material.dart';
import '../models/people.dart';
import '../components/people_selection_view.dart';
import '../components/chat_conversation_view.dart';

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

  // Dummy AI people generation helper.
  People _createGeneratedPeople(
    int id,
    String name,
    String relationship,
    String description,
    DateTime createdAt,
  ) {
    return People(
      id: id,
      name: name,
      relationship: relationship,
      description: description,
      createdAt: createdAt,
    );
  }

  late List<People> peoples = [
    _createGeneratedPeople(
      1,
      "Alice Johnson",
      "Friend",
      "bestie",
      DateTime.now(),
    ),
    _createGeneratedPeople(2, "Bob Smith", "Boss", "hater", DateTime.now()),
  ];

  People? selectedPeople;

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
  // then clear current conversation and selected people.
  void _startNewChat() {
    if (selectedPeople != null && messages.isNotEmpty) {
      // Create a session title (for example, "Chat with Alice - 10:30 AM")
      String sessionTitle = "Chat with ${selectedPeople!.name}";
      chatHistory.add(sessionTitle);
    }
    setState(() {
      selectedPeople = null;
      messages.clear();
      _showAddUserForm = false;
    });
  }

  void _selectPeople(People people) {
    setState(() {
      selectedPeople = people;
      messages.clear();
      _showAddUserForm = false;
    });
  }

  // Updated to use positional parameters.
  void _createPeople(String name, String relationship) {
    People newPeople = _createGeneratedPeople(
      5,
      name,
      relationship,
      "",
      DateTime.now(),
    );
    setState(() {
      peoples.add(newPeople);
      selectedPeople = newPeople;
      messages.clear();
      _showAddUserForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading:
            selectedPeople != null
                ? Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.home, size: 40, color: Colors.white),
                        tooltip: "Home",
                        onPressed: _startNewChat,
                      ),
                    ],
                  ),
                )
                : null,
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child:
              selectedPeople != null
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        selectedPeople!.name,
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        selectedPeople!.relationship,
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ],
                  )
                  : Text("Senti", style: TextStyle(color: Colors.white)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                SizedBox(width: 8),
                Text("Team Click", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1321), Color(0xFF1B3157)],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child:
                  selectedPeople == null
                      ? PeopleSelectionView(
                        peoples: peoples,
                        showAddUserForm: _showAddUserForm,
                        onPeopleSelected: _selectPeople,
                        onShowAddForm: () {
                          setState(() {
                            _showAddUserForm = true;
                          });
                        },
                        onCreatePeople: _createPeople,
                      )
                      : ChatConversationView(
                        messages: messages,
                        chatController: _chatController,
                        onSendMessage: _sendMessage,
                        people: selectedPeople!,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
