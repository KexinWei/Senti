import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/people.dart';

final String defaultDatetimeFormat = 'yyyy-MM-dd HH:mm:ss';

/// A simple class to parse session strings.
class SessionWithDate {
  final String fullTitle;  // e.g., "Chat with Alice ## 2023-03-15 14:20"
  final String mainTitle;  // e.g., "Chat with Alice"
  final DateTime date;     // Parsed date

  SessionWithDate({
    required this.fullTitle,
    required this.mainTitle,
    required this.date,
  });
}

class LeftSidebar extends StatelessWidget {

  final List<String> chatHistory;
  final People currentPeople;
  final Function(People) onNewChat;
  final Function(String) onSessionSelected;

  const LeftSidebar({
    required this.chatHistory,
    required this.currentPeople,
    required this.onNewChat,
    required this.onSessionSelected,
  });

  /// Parse a session string (e.g. "Chat with Alice ## 2023-03-15 14:20")
  SessionWithDate _parseSessionTitle(String fullTitle) {
    final splitted = fullTitle.split('##');
    if (splitted.length == 2) {
      final mainPart = splitted[0].trim();
      final dateString = splitted[1].trim();
      try {
        final date = DateFormat(defaultDatetimeFormat).parse(dateString);
        return SessionWithDate(fullTitle: fullTitle, mainTitle: mainPart, date: date);
      } catch (e) {
        return SessionWithDate(fullTitle: fullTitle, mainTitle: mainPart, date: DateTime.now());
      }
    } else {
      return SessionWithDate(fullTitle: fullTitle, mainTitle: fullTitle, date: DateTime.now());
    }
  }

  /// Determine the section name based on the date.
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
    // Parse session strings.
    final sessionList = chatHistory.map((title) => _parseSessionTitle(title)).toList();

    // Group sessions by section.
    Map<String, List<SessionWithDate>> grouped = {};
    for (var s in sessionList) {
      final sectionName = _getSectionName(s.date);
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
      width: 250,
      color: Colors.grey[850],
      child: Column(
        children: [
          // New Chat button.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: Text("New Chat"),
              onPressed: () => onNewChat(currentPeople),
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                if (item is String) {
                  // Section header.
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  );
                } else if (item is SessionWithDate) {
                  return ListTile(
                    title: Text(item.mainTitle),
                    subtitle: Text(DateFormat(defaultDatetimeFormat).format(item.date)),
                    onTap: () => onSessionSelected(item.fullTitle),
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
