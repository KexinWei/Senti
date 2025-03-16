import 'package:flutter/material.dart';

class CreatePeopleDialog extends StatefulWidget {
  final Function(String name, String relationship) onCreatePeople;

  const CreatePeopleDialog({Key? key, required this.onCreatePeople})
    : super(key: key);

  @override
  _CreatePeopleDialogState createState() => _CreatePeopleDialogState();
}

class _CreatePeopleDialogState extends State<CreatePeopleDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController relationshipController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Create a New Person"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: "People Name"),
          ),
          TextField(
            controller: relationshipController,
            decoration: InputDecoration(labelText: "Relationship"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.isNotEmpty &&
                relationshipController.text.isNotEmpty) {
              widget.onCreatePeople(
                nameController.text,
                relationshipController.text,
              );
              Navigator.of(context).pop();
            }
          },
          child: Text("Create"),
        ),
      ],
    );
  }
}
