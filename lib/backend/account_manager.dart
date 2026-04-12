import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'database_manager.dart';

class AccountManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'main'
  );

  Stream<User?> get userStatus => _auth.authStateChanges();

  Future<void> signUp(String email, String password, String username) async {
    final snapshot = await _db.collection('users')
        .where('username', isEqualTo: username).get();
    
    if (snapshot.docs.isNotEmpty) throw "Ce nom d'utilisateur est déjà pris.";

    UserCredential res = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    await _db.collection('users').doc(res.user!.uid).set({
      'username': username,
      'email': email,
      'groups': [],
    });
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<String> getUsernameFromId(String id) async {
    if(id == "system") return "System";
    DocumentSnapshot doc = await _db.collection("users").doc(id).get();
    if (doc.exists) {
      return doc.get("username") as String;
    } else {
      return "Utilisateur introuvable";
    }
  }

  Future<void> deleteAccount() async {
    User? user = _auth.currentUser;
    if (user == null) throw "Aucun utilisateur connecté.";

    try {
      String uid = user.uid;

      // 1. Récupérer la liste des groupes de l'utilisateur pour les quitter proprement
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();

      if (userDoc.exists) {
        List<dynamic> groupIds = userDoc.get('groups') ?? [];

        // 2. Faire quitter l'utilisateur de chaque groupe
        // On utilise DatabaseManager().leaveGroup pour gérer la logique de suppression du groupe si vide
        for (String groupId in groupIds) {
          await DatabaseManager().leaveGroup(groupId, uid);
        }

        // 3. Supprimer les sous-collections (comme 'events')
        // Note: Firestore ne supprime pas automatiquement les sous-collections d'un doc supprimé
        QuerySnapshot events = await _db.collection('users').doc(uid).collection('events').get();
        for (var doc in events.docs) {
          await doc.reference.delete();
        }

        // 4. Supprimer le document utilisateur dans Firestore
        await _db.collection('users').doc(uid).delete();
      }

      // 5. Enfin, supprimer l'utilisateur de Firebase Authentication
      await user.delete();

      print("Compte supprimé avec succès.");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw "Cette action nécessite une reconnexion récente.";
      }
      rethrow;
    } catch (e) {
      print("Erreur lors de la suppression du compte : $e");
      rethrow;
    }
  }

  Future<void> updateUsername(String newUsername) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    // Vérifier si le pseudo est déjà pris
    final snapshot = await _db.collection('users')
        .where('username', isEqualTo: newUsername).get();

    if (snapshot.docs.isNotEmpty) throw "Ce nom d'utilisateur est déjà pris.";

    // Mise à jour du document
    await _db.collection('users').doc(user.uid).update({
      'username': newUsername,
    });
  }

  bool listContainsIgnoreCase(List<String>? list, String s) {
    return list!.any(
          (element) => element.toLowerCase().contains(s.toLowerCase()),
    );
  }

  Future<Map<String, String>> searchUsersFromUsername(String search) async {
    Map<String, String> ids = {};
    try {
      dynamic querySnapshot;
      if(search.isEmpty) {
        querySnapshot = await _db
            .collection('users')
            .where('username', isNull: false)
            .get();
      }else {
        querySnapshot = await _db
            .collection('users')
            .where('username', isGreaterThanOrEqualTo: search)
            .where('username', isLessThanOrEqualTo: '$search\uf8ff')
            .get();
      }

      for (var doc in querySnapshot.docs) {
        ids.putIfAbsent(doc.id, () => doc.get("username"));
      }
    } catch (e) {
      print(search);
      print("Erreur lors de la recherche : $e");
    }
    return ids;
  }
}