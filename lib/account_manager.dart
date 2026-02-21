import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
}