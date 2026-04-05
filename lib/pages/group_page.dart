import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:momentime/backend/database_manager.dart';
import 'package:momentime/models/group.dart';
import 'package:momentime/models/message.dart';
import 'package:momentime/pages/groups_page.dart';

import '../backend/account_manager.dart';

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
      // --- 1. BARRE DU HAUT ---
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group.name),
            Text(
              "${widget.group.members.length} membres",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          // Bouton Calendrier
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              print("Ouvrir le calendrier du groupe");
              // Ta future logique calendrier ici
            },
          ),
          // Bouton Options / Détails / Ajouter membres
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showGroupOptions(context);
            },
          ),
        ],
      ),

      // --- 2. LISTE DES MESSAGES ---
      body: Column(
        children: [
          Expanded(
            child:
              widget.group.messages.isEmpty ?
              const Center(child: Text("Aucun message pour le moment")) :
              ListView.builder(
              reverse: true, // Pour que les derniers messages soient en bas
              itemCount: widget.group.messages.length,
              itemBuilder: (context, index) {
                // On inverse l'index à cause du 'reverse: true'
                final msg = widget.group.messages.reversed.toList()[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // --- 3. BARRE D'ENVOI ---
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Widget pour le champ de texte en bas
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
                  hintText: "Envoyer un message...",
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
                  setState(() {
                    widget.group.messages.add(Message("0", FirebaseAuth.instance.currentUser!.uid, _messageController.text, Timestamp.fromDate(DateTime.now())));
                    _messageController.clear();
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour une bulle de message (Design basique)
  Widget _buildMessageBubble(Message message) {
    // On définit le futur à attendre
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
            if(message.senderId.compareTo(FirebaseAuth.instance.currentUser!.uid) == 0)
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text("Modifier"),
                onTap: () => Navigator.pop(context), //TODO
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text("Supprimer", style: TextStyle(color: Colors.red)),
                onTap: () {
                  DatabaseManager().deleteMessage(widget.group.id, FirebaseAuth.instance.currentUser!.uid, message.id);
                },
              ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
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
                          return Text("Chargement de l'auteur...");
                        }

                        // On récupère le nom si disponible, sinon on garde l'ID
                        final authorName = snapshot.data ?? message.senderId;

                        return Text(
                          "Auteur : $authorName\nDate : ${message.timestamp.toDate().toString()}"
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour afficher le menu d'options
  void _showGroupOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text("Ajouter des membres"),
              onTap: () => showDialog(context: context, builder: (context) {
                  return Column(
                    children: [

                    ],
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("Détails du groupe"),
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
              title: const Text("Quitter le groupe", style: TextStyle(color: Colors.red)),
              onTap: () async {
                await DatabaseManager().leaveGroup(widget.group.id, FirebaseAuth.instance.currentUser!.uid);
                Navigator.push(context, MaterialPageRoute(builder: (_) => GroupsPage()));
              }
            ),
          ],
        );
      },
    );
  }
}