import 'dart:developer';
import 'package:byte_todo/providers/todo_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      log("Something went wrong");
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      log("Something went wrong");
    }
    return null;
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
      final FacebookAuth facebookAuth = FacebookAuth.instance;
      await facebookAuth.logOut();
    } catch (e) {
      log("Something went wrong");
    }
  }

  Future<void> currentUserProvider(WidgetRef ref) async {
    final user = _auth.currentUser;
    if (user != null) {
      ref.read(emailProvider.notifier).state = user.email ?? 'Guest';
    } else {
      ref.read(emailProvider.notifier).state = 'Guest';
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } catch (e) {
      print(e);
      return null;
    }
  }

  // sign in with Facebook popup
  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );
        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      } else {
        log("Facebook sign-in failed: ${result.status}");
      }
    } catch (e) {
      log("Facebook sign-in failed: $e");
    }
    return null;
  }
}
