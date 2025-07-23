// sign up screen with email and password and sign in with Google and Facebook
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../screens/todo_screen.dart';
import 'auth_service.dart';
import 'signin_screen.dart';

final emailProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
final isLoadingProvider = StateProvider<bool>((ref) => false);
final errorProvider = StateProvider<String?>((ref) => null);

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  Future<void> _signUp(WidgetRef ref) async {
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;
    try {
      final user = await AuthService().createUserWithEmailAndPassword(
        ref.read(emailProvider).trim(),
        ref.read(passwordProvider),
      );
      if (user != null) {
        Navigator.pushReplacement(
          ref.context,
          MaterialPageRoute(builder: (context) => const TodoScreen()),
        );
      }
    } catch (e) {
      ref.read(errorProvider.notifier).state = 'Sign up failed: $e';
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _signUpWithGoogle(WidgetRef ref) async {
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      await FirebaseAuth.instance.signInWithPopup(googleProvider);
      // find the current user and update email provider
      final user = FirebaseAuth.instance.currentUser;
      ref.read(emailProvider.notifier).state = user?.email ?? 'Guest';
      Navigator.pushReplacement(
        ref.context,
        MaterialPageRoute(builder: (context) => const TodoScreen()),
      );
    } catch (e) {
      ref.read(errorProvider.notifier).state = 'Google sign-up failed: $e';
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _signUpWithFacebook(WidgetRef ref) async {
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;
    try {
      final user = await AuthService().signInWithFacebook();
      if (user != null) {
        Navigator.pushReplacement(
          ref.context,
          MaterialPageRoute(builder: (context) => const TodoScreen()),
        );
      }
    } catch (e) {
      ref.read(errorProvider.notifier).state = 'Facebook sign-in failed: $e';
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    final error = ref.watch(errorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) =>
                  ref.read(emailProvider.notifier).state = value,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) =>
                  ref.read(passwordProvider.notifier).state = value,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (error != null)
              Text(error, style: const TextStyle(color: Colors.red)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _signUp(ref),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Sign Up'),
              ),
            ),
            // Sign in with Google button
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : () => _signUpWithGoogle(ref),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Sign Up with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.deepOrangeAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  //
                ),
              ),
            ),
            // Sign in with Facebook button
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : () => _signUpWithFacebook(ref),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Sign Up with Facebook'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            // Sign in button
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                      );
                    },
              child: const Text('Already have an account? Sign In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
