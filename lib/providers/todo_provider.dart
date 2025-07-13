import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/todo_model.dart';

final todoProvider = StateNotifierProvider<TodoController, List<Todo>>((ref) {
  return TodoController();
});

class TodoController extends StateNotifier<List<Todo>> {
  TodoController() : super([]) {
    _setupRealtimeListener();
  }

  final _firestore = FirebaseFirestore.instance;
  final _collection = FirebaseFirestore.instance.collection('todos');

  void _setupRealtimeListener() {
    _collection.snapshots().listen(
      (snapshot) {
        try {
          state = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Todo.fromMap(data);
          }).toList();
        } catch (e) {
          print('Error fetching todos: $e');
        }
      },
      onError: (error) {
        print('Error listening to todos: $error');
      },
    );
  }

  Future<void> add(String title) async {
    if (title.trim().isEmpty) return;

    try {
      final docRef = _collection.doc();
      final newTodo = Todo(id: docRef.id, title: title.trim(), isDone: false);

      await docRef.set(newTodo.toMap());
    } catch (e) {
      print('Error adding todo: $e');
    }
  }

  Future<void> remove(String id) async {
    if (id.isEmpty) return;

    try {
      await _collection.doc(id).delete();
    } catch (e) {
      print('Error deleting todo: $e');
    }
  }

  Future<void> toggleStatus(String id) async {
    if (id.isEmpty) return;

    try {
      final todoIndex = state.indexWhere((todo) => todo.id == id);
      if (todoIndex == -1) return;

      final currentTodo = state[todoIndex];
      final newStatus = !currentTodo.isDone;

      await _collection.doc(id).update({
        'isDone': newStatus,
        'completedAt': newStatus ? FieldValue.serverTimestamp() : null,
      });
    } catch (e) {
      print('Error updating todo status: $e');
    }
  }

  Future<void> updateTitle(String id, String newTitle) async {
    if (id.isEmpty || newTitle.trim().isEmpty) return;

    try {
      await _collection.doc(id).update({
        'title': newTitle.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating todo title: $e');
    }
  }

  Future<void> clearCompleted() async {
    try {
      final completedTodos = state.where((todo) => todo.isDone).toList();
      if (completedTodos.isEmpty) return;

      final batch = _firestore.batch();
      for (final todo in completedTodos) {
        batch.delete(_collection.doc(todo.id));
      }
      await batch.commit();
    } catch (e) {
      print('Error clearing completed todos: $e');
    }
  }

  Map<String, int> get statistics {
    final total = state.length;
    final completed = state.where((todo) => todo.isDone).length;
    final pending = total - completed;

    return {'total': total, 'completed': completed, 'pending': pending};
  }

  List<Todo> searchTodos(String query) {
    if (query.trim().isEmpty) return state;
    return state
        .where((todo) => todo.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
