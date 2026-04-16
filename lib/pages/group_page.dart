import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:momentime/backend/database_manager.dart';
import 'package:momentime/models/group.dart';
import 'package:momentime/models/message.dart';

import '../backend/account_manager.dart';
import 'group_calendar-page.dart';

class GroupPage extends StatefulWidget {
  final Group group;

  const GroupPage({super.key, required this.group});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group.name),
            Text(
              widget.group.members.length>1 ? "${widget.group.members.length} members" : "${widget.group.members.length} member",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GroupCalendarPage(group: widget.group)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showGroupOptions(context);
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child:
              widget.group.messages.isEmpty ?
              const Center(child: Text("No message for the moment.")) :
              ListView.builder(
              reverse: true,
              itemCount: widget.group.messages.length,
              itemBuilder: (context, index) {
                final msg = widget.group.messages.toList()[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "Send a message...",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: () async {
                if (_messageController.text.isNotEmpty) {
                  print("Envoi de : ${_messageController.text}");
                  await DatabaseManager().sendMessage(widget.group.id, FirebaseAuth.instance.currentUser!.uid, _messageController.text);
                  //widget.group.messages.add(Message("0", FirebaseAuth.instance.currentUser!.uid, _messageController.text, Timestamp.fromDate(DateTime.now())));
                  _messageController.clear();

                  widget.group.messages = await DatabaseManager().getGroupMessages(widget.group.id);
                  setState(() {});
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour une bulle de message
  Widget _buildMessageBubble(Message message) {
    return FutureBuilder<String>(
      future: fetchUsername(message.senderId),
      builder: (context, snapshot) {
        // En attendant les données
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            title: Text(message.senderId, style: const TextStyle(fontSize: 10)),
            subtitle: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(message.text),
            ),
          );
        }

        // Une fois les données reçues
        return ListTile(
          title: Text(snapshot.data!, style: const TextStyle(fontSize: 10)),
          subtitle: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(message.text),
          ),
          onLongPress: () => _showMessageOptions(context, message),
        );
      },
    );
  }

  Future<String> fetchUsername(String uid) async {
    String name = await AccountManager().getUsernameFromId(uid);
    return name;
  }

  void _showMessageOptions(BuildContext context, Message message){
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("Informations"),
              onTap: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  alignment: Alignment.center,
                  title: Text('Informations'),
                  content: SingleChildScrollView(
                    padding: EdgeInsetsGeometry.all(40),
                    child: FutureBuilder<String>(
                      future: fetchUsername(message.senderId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text("Loading author...");
                        }

                        // On récupère le nom si disponible, sinon on garde l'ID
                        final authorName = snapshot.data ?? message.senderId;

                        return Text(
                            "Author : $authorName\nDate : ${message.timestamp.toDate().toString()}"
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            if(message.senderId == FirebaseAuth.instance.currentUser!.uid)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red,),
                title: const Text("Delete", style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context, true);
                  await DatabaseManager().deleteMessage(widget.group.id, FirebaseAuth.instance.currentUser!.uid, message.id);

                  widget.group.messages = await DatabaseManager().getGroupMessages(widget.group.id);
                  setState(() {});
                },
              ),
          ],
        );
      },
    );
  }

  void _showGroupOptions(BuildContext context) async {
    Map<String, String> searchedMap = await AccountManager().searchUsersFromUsername("");
    showModalBottomSheet(
      context: context,
      builder: (context) {
        TextEditingController usernameController = TextEditingController();
        List<String> idsToAdd = List.empty(growable: true);
        List<MapEntry<String, String>> userEntries = searchedMap.entries.toList();
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text("Add members"),
              onTap: () => showDialog(
                context: context,
                builder: (context) => StatefulBuilder(
                  builder: (context, StateSetter setDialogState) => AlertDialog(
                    title: const Text('Add members'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: usernameController,
                            onChanged: (value) async {
                              searchedMap = await AccountManager().searchUsersFromUsername(value);
                              setDialogState(() {
                                userEntries = searchedMap.entries.toList();
                              });
                            },
                            decoration: const InputDecoration(hintText: 'Search a username...'),
                          ),
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 250,
                            ),
                            child: userEntries.isEmpty
                                ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("No user found"),
                            )
                                : ListView.builder(
                              shrinkWrap: true,
                              itemCount: userEntries.length,
                              itemBuilder: (context, index) {
                                final String userId = userEntries[index].key;
                                final String username = userEntries[index].value;
                                return ListTile(
                                  dense: true,
                                  leading: CircleAvatar(child: Text(username[0])),
                                  title: Text(username),
                                  onTap: () {
                                    if (idsToAdd.contains(userId)) {
                                      idsToAdd.remove(userId);
                                    } else {
                                      idsToAdd.add(userId);
                                    }
                                    setState(() {});
                                  },
                                  trailing: Checkbox(
                                    value: idsToAdd.contains(userId),
                                    onChanged: (bool? checked) {
                                      if (checked == true) {
                                        idsToAdd.add(userId);
                                      } else {
                                        idsToAdd.remove(userId);
                                      }
                                      setState(() {});
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context, true);
                          for(String id in idsToAdd) {
                            if(!widget.group.members.contains(id)) {
                              await DatabaseManager().addUserToGroup(widget.group.id, id);
                            }
                          }
                          await DatabaseManager().getGroupList(FirebaseAuth.instance.currentUser!.uid);
                          setState(() {});
                        },
                        child: Text('Add'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Cancel'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("Group details"),
              onTap: () => showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(widget.group.name),
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text("Leave group", style: TextStyle(color: Colors.red)),
              onTap: () async {
                await DatabaseManager().leaveGroup(widget.group.id, FirebaseAuth.instance.currentUser!.uid);
                Navigator.pop(context);
                Navigator.pop(context, true);
              }
            ),
          ],
        );
      },
    );
  }
}