import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:momentime/models/event.dart';
import 'package:momentime/models/group.dart';

import 'models/message.dart';

class DatabaseManager {
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'main');

  Future<void> addEvent(String userUid, Event event) {
    return _db.collection('users').doc(userUid).collection('events').add({
      'name': event.name,
      'start': event.from,
      'end': event.to,
      'color': event.background.toARGB32().toRadixString(16).padLeft(8, '0').substring(2),
      'isAllDay': event.isAllDay,
    });
  }

  Future<List<Event>> getEventList(String userUid) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("users")
          .doc(userUid)
          .collection("events")
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return Event(
          data['name'] ?? 'Sans nom',
          (data['start'] as Timestamp).toDate(),
          (data['end'] as Timestamp).toDate(),
          Color(int.parse("FF${data['color']}", radix: 16)), // Ajoute FF pour l'opacité
          data['isAllDay'] ?? false,
        );
      }).toList();
    } catch (e) {
      print("Erreur récupération events : $e");
      return [];
    }
  }

  Future<void> removeEvent(String userUid, String eventId) {
    return _db.collection('users').doc(userUid).collection('events').doc(eventId).delete();
  }

  Future<List<Group>> getGroupList(String userUid) async {
    try {
      // 1. Récupérer les IDs des groupes dans le document User
      DocumentSnapshot userDoc = await _db.collection('users').doc(userUid).get();

      if (!userDoc.exists) return [];

      List<dynamic> groupIds = userDoc.get('groups') ?? [];
      if (groupIds.isEmpty) return [];

      // 2. Récupérer les détails des groupes (Nom et Membres)
      QuerySnapshot groupSnapshots = await _db.collection('groups')
          .where(FieldPath.documentId, whereIn: groupIds)
          .get();

      // 3. Transformer en liste d'objets Group
      // On laisse la liste des messages vide au début (on les chargera quand on clique sur le groupe)
      return groupSnapshots.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return Group(
          data['name'] ?? 'Sans nom',
          List<String>.from(data['members'] ?? []),
          [], // La liste de Message est initialisée vide
        );
      }).toList();

    } catch (e) {
      print("Erreur lors de la récupération des objets Group : $e");
      return [];
    }
  }

  Future<List<Message>> getGroupMessages(String groupId) async {
    QuerySnapshot msgSnapshot = await _db
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .get();

    return msgSnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Message(
        // Adapte ici selon les paramètres de ton constructeur Message
        data['text'],
        data['senderId'],
        (data['timestamp'] as Timestamp),
      );
    }).toList();
  }

  Future<void> createGroup(String groupName, String creatorUid) async {
    DocumentReference groupRef = await _db.collection('groups').add({
      'name': groupName,
      'members': [creatorUid],
    });

    await _db.collection('users').doc(creatorUid).update({
      'groups': FieldValue.arrayUnion([groupRef.id])
    });
  }

  Future<void> deleteGroup(String groupId) async {
    final batch = _db.batch();

    try {
      DocumentSnapshot groupDoc = await _db.collection('groups').doc(groupId).get();
      
      if (!groupDoc.exists) return;

      List<dynamic> members = groupDoc.get('members');

      for (String memberUid in members) {
        DocumentReference userRef = _db.collection('users').doc(memberUid);
        batch.update(userRef, {
          'groups': FieldValue.arrayRemove([groupId])
        });
      }

      DocumentReference groupRef = _db.collection('groups').doc(groupId);
      batch.delete(groupRef);

      await batch.commit();
      print("Groupe et références membres supprimés avec succès.");
    } catch (e) {
      print("Erreur lors de la suppression : $e");
      rethrow;
    }
  }

  Future<void> sendMessage(String groupId, String senderId, String text) {
    return _db.collection('groups').doc(groupId).collection('messages').add({
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp() ,
    });
  }
}