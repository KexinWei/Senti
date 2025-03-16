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
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Who do you have a problem with?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Select a person you want to improve your communication with",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: peoples.length + 1,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  if (index < peoples.length) {
                    final people = peoples[index];
                    return _buildPersonCard(context, people);
                  } else {
                    return _buildAddNewCard(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonCard(BuildContext context, People people) {
    return Card(
      color: Colors.grey[800],
      child: InkWell(
        onTap: () => onPeopleSelected(people),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.blue[700],
                child: Text(
                  people.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                people.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                people.relationship,
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddNewCard(BuildContext context) {
    return Card(
      color: Colors.blue[700],
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder:
                (context) => CreatePeopleDialog(onCreatePeople: onCreatePeople),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Colors.white, size: 48),
            SizedBox(height: 8),
            Text(
              "Add New Person",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],

        ),
      ),
    );
  }
}
