import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:momentime/models/event.dart';

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
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}