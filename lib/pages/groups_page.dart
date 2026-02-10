import 'package:flutter/material.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Text("Calendar"),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => print("Bouton cliqué !"),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}