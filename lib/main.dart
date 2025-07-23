import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/todo_screen.dart';
import 'auth/signin_screen.dart';
import 'auth/signup_screen.dart';

void main() async {
  // Make sure Flutter is ready before we do anything
  WidgetsFlutterBinding.ensureInitialized();

  // Connect to Firebase so we can store todos in the cloud
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyTodoApp()));
}

// Main app widget that sets up the overall project
class MyTodoApp extends ConsumerWidget {
  const MyTodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Todos App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: SignInScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
