import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/todo_model.dart';

// This is the main provider that manages all todo operations in the app
final todoProvider = StreamProvider<List<Todo>>((ref) {
  final _collection = FirebaseFirestore.instance.collection('todos');
  return _collection.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Todo.fromMap(data);
    }).toList();
  });
});

// handles all the CRUD operations with Firebase
class TodoProvider {
  // Firebase connection setup
  final _firestore = FirebaseFirestore.instance;
  final _collection = FirebaseFirestore.instance.collection('todos');

  // Sets up real-time updates so any changes in Firebase instantly appear in the app

  // Adds a new todo to Firebase and automatically shows in app
  Future<void> add(String title) async {
    if (title.trim().isEmpty) return; // Don't allow to add empty todos

    try {
      // Create a new document reference to get a unique ID
      final docRef = _collection.doc();
      final newTodo = Todo(id: docRef.id, title: title.trim(), isDone: false);

      // Save the todo to Firebase
      await docRef.set(newTodo.toMap());
    } catch (e) {
      print('Error adding todo: $e');
    }
  }

  // Permanently removes a todo from Firebase
  Future<void> remove(String id) async {
    if (id.isEmpty) return; // Safety check

    try {
      await _collection.doc(id).delete();
    } catch (e) {
      print('Error deleting todo: $e');
    }
  }

  // Toggles a todo between done and not done
  Future<void> toggleStatus(String id) async {
    if (id.isEmpty) return; // Safety check
    final todos = await _collection.get().then((snapshot) {
      return snapshot.docs.map((doc) => Todo.fromMap(doc.data())).toList();
    });
    try {
      // Find the todo in our current state
      final todoIndex = todos.indexWhere((todo) => todo.id == id);
      if (todoIndex == -1) return; // Todo not found

      final currentTodo = todos[todoIndex];
      final newStatus = !currentTodo.isDone; // Flip the status

      // Update Firebase with the new status and timestamp
      await _collection.doc(id).update({
        'isDone': newStatus,
        'completedAt': newStatus ? FieldValue.serverTimestamp() : null,
      });
    } catch (e) {
      print('Error updating todo status: $e');
    }
  }

  // Updates the text of an existing todo
  Future<void> updateTitle(String id, String newTitle) async {
    if (id.isEmpty || newTitle.trim().isEmpty) return; // Safety checks

    try {
      // Update Firebase with new title and timestamp
      await _collection.doc(id).update({
        'title': newTitle.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating todo title: $e');
    }
  }

  // Removes all completed todos at once
  Future<void> clearCompleted(List<Todo> todos) async {
    try {
      // Find all todos that are marked as done
      final completedTodos = todos.where((todo) => todo.isDone).toList();
      if (completedTodos.isEmpty) return; // Nothing to clear

      // Use batch operation for better performance when deleting multiple items
      final batch = _firestore.batch();
      for (final todo in completedTodos) {
        batch.delete(_collection.doc(todo.id));
      }
      await batch.commit(); // Execute all deletions at once
    } catch (e) {
      print('Error clearing completed todos: $e');
    }
  }

  // Provides stats about todos (total, completed, pending)
  static Map<String, int> getStatistics(List<Todo> todos) {
    final total = todos.length;
    final completed = todos.where((todo) => todo.isDone).length;
    final pending = total - completed;

    return {'total': total, 'completed': completed, 'pending': pending};
  }

  // Searches through todos by title
  List<Todo> searchTodos(List<Todo> todos, String query) {
    if (query.trim().isEmpty)
      return todos; // Return all todos if no search query
    return todos
        .where((todo) => todo.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
