// 1. Update imports at the top to import the new ChatSession model.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/people.dart';
import '../models/chat_session.dart'; // <-- Added import for the new session model
import '../services/api_service.dart';


final String defaultDatetimeFormat = 'yyyy-MM-dd HH:mm:ss';

/// Remove the old SessionWithDate class since ChatSession is now defined in the models folder.
// You can delete the following class if no longer needed:
//
// class SessionWithDate {
//   final String fullTitle;
//   final String mainTitle;
//   final DateTime date;
//
//   SessionWithDate({
//     required this.fullTitle,
//     required this.mainTitle,
//     required this.date,
//   });
// }

// 1. Update the LeftSidebar widget definition to accept the new parameter.
class LeftSidebar extends StatefulWidget {
  final People currentPeople;
  final Function(ChatSession) onSessionSelected;
  final Function() onNewChat;


  const LeftSidebar({
    Key? key,
    required this.currentPeople,
    required this.onSessionSelected,
    required this.onNewChat,
  }) : super(key: key);

  @override
  _LeftSidebarState createState() => _LeftSidebarState();
}

class _LeftSidebarState extends State<LeftSidebar> {
  final ApiService _apiService = ApiService();
  List<ChatSession> _sessions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  @override
  void didUpdateWidget(LeftSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPeople.id != widget.currentPeople.id) {
      _loadSessions();
    }
  }

  Future<void> _loadSessions() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final sessions = await _apiService.getSessionsByPeopleId(
        widget.currentPeople.id!,
      );
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createNewSession() async {
    try {
      final session = await _apiService.createSession(widget.currentPeople.id!);
      setState(() {
        _sessions.insert(0, session); // Add new session at the beginning
      });
      widget.onSessionSelected(session);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create new session: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  /// Determine the section name based on the last message time.
  String _getSectionName(DateTime date) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfYesterday = startOfToday.subtract(Duration(days: 1));
    final startOf7DaysAgo = startOfToday.subtract(Duration(days: 7));

    if (date.isAfter(startOfToday)) {
      return 'Today';
    } else if (date.isAfter(startOfYesterday)) {
      return 'Yesterday';
    } else if (date.isAfter(startOf7DaysAgo)) {
      return 'Previous 7 days';
    } else {
      return 'Earlier';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. Use the provided chatHistory directly as a list of ChatSession objects.
    final sessionList = chatHistory;

    // Group sessions by section.
    Map<String, List<ChatSession>> grouped = {};
    for (var s in sessionList) {
      final sectionName = _getSectionName(s.lastMessageTime);
      grouped.putIfAbsent(sectionName, () => []).add(s);
    }

    // Assemble a list of items: section headers and session items.
    List<dynamic> items = [];
    final sectionsOrder = ['Today', 'Yesterday', 'Previous 7 days', 'Earlier'];
    for (var section in sectionsOrder) {
      if (grouped.containsKey(section)) {
        items.add(section);
        items.addAll(grouped[section]!);
      }
    }

    return Container(
      width: 300,
      color: Colors.grey[850],
      child: Column(
        children: [_buildHeader(), Expanded(child: _buildSessionsList())],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(bottom: BorderSide(color: Colors.grey[800]!, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.currentPeople.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            widget.currentPeople.relationship,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _createNewSession,
            icon: Icon(Icons.add),
            label: Text('New Consultation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              minimumSize: Size(double.infinity, 40),

            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error loading sessions', style: TextStyle(color: Colors.red)),
            SizedBox(height: 8),
            ElevatedButton(onPressed: _loadSessions, child: Text('Retry')),
          ],
        ),
      );
    }

    if (_sessions.isEmpty) {
      return Center(
        child: Text(
          'No sessions yet.\nStart a new consultation!',
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return ListTile(
          title: Text(
            session.title,
            style: TextStyle(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _formatDate(session.createdAt),
            style: TextStyle(color: Colors.white70),
          ),
          onTap: () => widget.onSessionSelected(session),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
