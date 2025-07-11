import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/todo_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyTodoApp()));
}

class MyTodoApp extends StatelessWidget {
  const MyTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todos with Riverpod',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: TodoScreen(),
    );
  }
}
