// 1. Update imports at the top to import the new ChatSession model.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/people.dart';
import '../models/chat_session.dart'; // <-- Added import for the new session model

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
class LeftSidebar extends StatelessWidget {
  final List<ChatSession> chatHistory;
  final People currentPeople;
  final Function(People) onNewChat;
  final Function(String) onSessionSelected;
  final String? currentSessionId; // New parameter

  const LeftSidebar({
    required this.chatHistory,
    required this.currentPeople,
    required this.onNewChat,
    required this.onSessionSelected,
    this.currentSessionId, // Optional parameter to indicate selected session
  });

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
      margin: EdgeInsets.only(top: 16.0),
      width: 250,
      // Instead of using withOpacity, construct a color directly (if needed):
      color: Color.fromRGBO(66, 66, 66, 0.2),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title for the sidebar.
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Chat History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  if (item is String) {
                    // Section header.
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 16.0,
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    );
                  } else if (item is ChatSession) {
                    bool isSelected =
                        (currentSessionId != null &&
                            item.sessionId == currentSessionId);
                    return ListTile(
                      title: Text(
                        item.title,
                        style: TextStyle(
                          color: isSelected ? Colors.blue : Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat(
                          defaultDatetimeFormat,
                        ).format(item.lastMessageTime),
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.blue.shade200
                                  : Colors.white70,
                        ),
                      ),
                      onTap: () => onSessionSelected(item.sessionId),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
