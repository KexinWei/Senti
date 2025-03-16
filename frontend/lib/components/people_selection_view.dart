import 'package:flutter/material.dart';
import '../models/people.dart';
import 'create_people_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController relationshipController = TextEditingController();

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select the Person You Are Chatting With:",
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
                  crossAxisCount: 4,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  childAspectRatio: 1.3,
                ),
                itemBuilder: (context, index) {
                  if (index < peoples.length) {
                    final people = peoples[index];
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => onPeopleSelected(people),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.transparent,
                              backgroundImage: AssetImage(
                                'icons8-person-94.png',
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              people.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // "Create New People" cell.
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return CreatePeopleDialog(
                                onCreatePeople: onCreatePeople,
                              );
                            },
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Add New",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
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
      ),
    );
  }
}
