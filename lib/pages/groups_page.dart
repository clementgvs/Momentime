import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:momentime/backend/account_manager.dart';

import '../backend/database_manager.dart';
import '../models/group.dart';
import 'group_page.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  late Group groupToAdd;
  List<Group> groups = [];
  String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> addGroup(BuildContext context, Group group) async {
    print("Add group : \n${group.toString()}");

    Navigator.pop(context);

    await DatabaseManager().createGroup(group.name, uid);

    _loadGroups();
    groupToAdd = Group("0", "Name", [uid], []);
  }

  Future<void> _loadGroups() async {
    List<Group> fetchedGroups = await DatabaseManager().getGroupList(uid);

    setState(() {
      groups = fetchedGroups;
    });
  }

  @override
  void initState() {
    _loadGroups();
    groupToAdd = Group("0", "Name", [uid], []);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController groupNameController = TextEditingController();

    return Center(
      child: Stack(
        children: [
          Padding(padding: EdgeInsetsGeometry.directional(start: 15, end: 15,),
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                Group currentGroup = groups[index];

                // On définit le futur à attendre
                Future<List<String>> fetchUsernames() async {
                  List<String> names = [];
                  for (String id in currentGroup.members) {
                    names.add(await AccountManager().getUsernameFromId(id));
                  }
                  return names;
                }

                return FutureBuilder<List<String>>(
                  future: fetchUsernames(),
                  builder: (context, snapshot) {
                    // En attendant les données
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Card(
                        child: Container(
                          margin: EdgeInsetsGeometry.directional(bottom: 10),
                          child: ListTile(
                            title: Text(currentGroup.name),
                            trailing: const Text("Chargement des membres..."),
                          ),
                        ),
                      );
                    }

                    // Une fois les données reçues
                    return Card(
                      child: Container(
                        margin: EdgeInsetsGeometry.directional(bottom: 3, top: 3),
                        child: ListTile(
                          title: Text(currentGroup.name),
                          trailing: Text(snapshot.data?.join(", ") ?? "Aucun membre"),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GroupPage(group: currentGroup))),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  alignment: Alignment.center,
                  title: Text('Ajouter un évènement'),
                  content: SingleChildScrollView(
                    padding: EdgeInsetsGeometry.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: groupNameController,
                          maxLength: 50,
                          expands: false,
                          maxLines: 1,
                          minLines: 1,
                          onSubmitted: (value) => setState(() => groupToAdd.setName(value)),
                          onChanged: (value) => setState(() => groupToAdd.setName(value)),
                          decoration: InputDecoration(
                            hintText: 'Enter the event name',
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => addGroup(context, groupToAdd),
                      child: Text('Ajouter'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Annuler'),
                    ),
                  ],
                ),
              ),
              shape: CircleBorder(),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}