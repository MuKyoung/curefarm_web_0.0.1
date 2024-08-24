import 'package:curefarm_beta/AuthScene/view_models/signup_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool get isLoggedIn => user != null;
  User? get user => _firebaseAuth.currentUser;
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  Future<UserCredential> emailSignUp(String email, String password) async {
    return _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> emailSignIn(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}

final authRepo = Provider((ref) => AuthenticationRepository());

final authState = StreamProvider((ref) {
  final repo = ref.read(authRepo);
  return repo.authStateChanges();
});
