import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/todo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyTodoApp()));
}

class MyTodoApp extends ConsumerWidget {
  const MyTodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Todos App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: TodoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
