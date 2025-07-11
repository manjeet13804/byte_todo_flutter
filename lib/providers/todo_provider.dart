import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/todo_model.dart';
import 'dart:math';

final todoProvider = StateNotifierProvider<TodoController, List<Todo>>((ref) {
  return TodoController();
});

class TodoController extends StateNotifier<List<Todo>> {
  TodoController() : super([]);

  void add(String title) {
    final todo = Todo(id: Random().nextInt(99999).toString(), title: title);
    state = [...state, todo];
  }

  void remove(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  void toggleStatus(String id) {
    state = state.map((t) {
      if (t.id == id) {
        return t.copyWith(isDone: !t.isDone);
      }
      return t;
    }).toList();
  }

  void updateTitle(String id, String newTitle) {
    state = state.map((t) {
      if (t.id == id) {
        return t.copyWith(title: newTitle);
      }
      return t;
    }).toList();
  }
}
