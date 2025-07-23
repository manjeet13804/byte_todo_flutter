import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../screens/todo_screen.dart';
import 'signup_screen.dart';

final emailProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
final isLoadingProvider = StateProvider<bool>((ref) => false);
final errorProvider = StateProvider<String?>((ref) => null);

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  Future<void> _signIn(WidgetRef ref) async {
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: ref.read(emailProvider).trim(),
        password: ref.read(passwordProvider),
      );
      Navigator.pushReplacement(
        ref.context,
        MaterialPageRoute(builder: (context) => const TodoScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ref.read(errorProvider.notifier).state = e.message;
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _signInWithGoogle(WidgetRef ref) async {
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
      ref.read(errorProvider.notifier).state = 'Google sign-in failed: $e';
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _signInWithFacebook(WidgetRef ref) async {
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    try {
      final facebookProvider = FacebookAuthProvider();
      final userCredential = await FirebaseAuth.instance.signInWithPopup(
        facebookProvider,
      );
      final email = userCredential.user?.email ?? 'Guest';
      ref.read(emailProvider.notifier).state = email;

      Navigator.pushReplacement(
        ref.context,
        MaterialPageRoute(builder: (context) => const TodoScreen()),
      );
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
      appBar: AppBar(title: const Text('Sign In')),
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
                onPressed: isLoading ? null : () => _signIn(ref),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Sign In'),
              ),
            ),
            // Sign in with Google button
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : () => _signInWithGoogle(ref),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Sign In with Google'),
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
              onPressed: isLoading ? null : () => _signInWithFacebook(ref),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Sign In with Facebook'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            // Sign up button
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              child: const Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
