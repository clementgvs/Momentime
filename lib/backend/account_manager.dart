import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

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
    DocumentSnapshot doc = await _db.collection("users").doc(id).get();
    if (doc.exists) {
      return doc.get("username") as String;
    } else {
      return "Utilisateur introuvable";
    }
  }

  bool listContainsIgnoreCase(List<String>? list, String s) {
    return list!.any(
          (element) => element.toLowerCase().contains(s.toLowerCase()),
    );
  }

  Future<List<String>> searchUsersFromUsername(String search) async {
    List<String> ids = List.empty(growable: true);
    try {
      final querySnapshot = await _db
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: search)
          .where('username', isLessThanOrEqualTo: '$search\uf8ff')
          .get();

      for (var doc in querySnapshot.docs) {
        ids.add(doc.id);
      }
    } catch (e) {
      print("Erreur lors de la recherche : $e");
    }
    return ids;
  }
}