import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  Future<void> _loadGroups() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    List<Group> fetchedEvents = await DatabaseManager().getEventList(uid);

    setState(() {
      events = fetchedEvents;
    });
  }

  @override
  void initState() {
    _loadGroups();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ListView.builder(
              itemCount: ,
              itemBuilder: (context, index) => ListTile(
                title: Text("sfs"),
              ),
          ),
        ],
      ),
    );
  }
}