import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:momentime/models/event.dart';
import 'package:momentime/models/group.dart';

import '../models/message.dart';

class DatabaseManager {
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'main'
  );

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
          doc.id,
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

      // 3. Transformer en liste de Future<Group>
      Iterable<Future<Group>> groupFutures = groupSnapshots.docs.map((doc) async {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // On récupère les messages pour ce groupe spécifique
        List<Message> messages = await getGroupMessages(doc.id);

        return Group(
          doc.id,
          data['name'] ?? 'Sans nom',
          List<String>.from(data['members'] ?? []),
          messages,
        );
      });

      // 4. On attend que TOUS les groupes soient chargés avant de retourner la liste
      return await Future.wait(groupFutures);

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
        doc.id,
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
      'messages' : [],
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

  Future<void> leaveGroup(String groupId, String userId) async {
    try {
      DocumentReference groupRef = _db.collection('groups').doc(groupId);
      DocumentSnapshot groupDoc = await groupRef.get();

      if (!groupDoc.exists) {
        print("Le groupe n'existe pas.");
        return;
      }

      List<dynamic> members = groupDoc.get('members') ?? List.empty(growable: true);

      if (members.length <= 1) {
        // Si l'utilisateur est seul, on supprime carrément le groupe
        await deleteGroup(groupId);
        print("Dernier membre parti, groupe supprimé.");
      } else {
        final batch = _db.batch();

        // Retirer l'utilisateur de la liste des membres du groupe
        batch.update(groupRef, {
          'members': FieldValue.arrayRemove([userId])
        });

        // Retirer le groupe de la liste 'groups' de l'utilisateur
        DocumentReference userRef = _db.collection('users').doc(userId);
        batch.update(userRef, {
          'groups': FieldValue.arrayRemove([groupId])
        });

        // Ajouter un message système dans la sous-collection du groupe
        DocumentReference msgRef = groupRef.collection('messages').doc();
        batch.set(msgRef, {
          'senderId': 'system',
          'text': 'Un membre a quitté le groupe.',
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Exécution de toutes les opérations en une fois
        await batch.commit();
        print("L'utilisateur a quitté le groupe avec succès.");
      }
    } catch (e) {
      print("Erreur lors du départ du groupe : $e");
      rethrow;
    }
  }

  Future<void> sendMessage(String groupId, String senderId, String text) async {
    try {
      await _db.collection('groups').doc(groupId).collection('messages').add({
        'senderId': senderId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Erreur Firestore lors de l'envoi : $e");
      rethrow;
    }
  }

  Future<void> deleteMessage(String groupId, String senderId, String messageId) async {
    final batch = _db.batch();
    if(senderId == FirebaseAuth.instance.currentUser!.uid) {
      batch.update(_db.collection('groups').doc(groupId), {
        'messages': FieldValue.arrayRemove([messageId])
      });

      await batch.commit();
    }
  }
}