import 'package:flutter/material.dart';
import '../models/people.dart';

class PeopleSelectionView extends StatelessWidget {
  final List<People> peoples;
  final bool showAddUserForm;
  final Function(People) onPeopleSelected;
  final Function() onShowAddForm;
  final Function(String name, String relationship) onCreatePeople;

  PeopleSelectionView({
    required this.peoples,
    required this.showAddUserForm,
    required this.onPeopleSelected,
    required this.onShowAddForm,
    required this.onCreatePeople,
  });

  // Helper to get initials.
  String _getInitials(String name) {
    List<String> words = name.split(" ");
    if (words.isEmpty) return "";
    if (words.length == 1) return words[0][0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController relationshipController = TextEditingController();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select an Existing People",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: peoples.length + 1,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                if (index < peoples.length) {
                  final people = peoples[index];
                  final initials = _getInitials(people.name);
                  return GestureDetector(
                    onTap: () => onPeopleSelected(people),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          child: Text(initials, style: TextStyle(fontSize: 20)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          people.name,
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                } else {
                  // "Create New People" cell.
                  return GestureDetector(
                    onTap: onShowAddForm,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          child: Icon(Icons.add, size: 30),
                        ),
                        SizedBox(height: 4),
                        Text("New", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                }
              },
            ),
            if (showAddUserForm)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    "Create a New People",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "People Name"),
                  ),
                  TextField(
                    controller: relationshipController,
                    decoration: InputDecoration(labelText: "Relationship"),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty &&
                          relationshipController.text.isNotEmpty) {
                        onCreatePeople(
                          nameController.text,
                          relationshipController.text,
                        );
                      }
                    },
                    child: Text("Create People"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
