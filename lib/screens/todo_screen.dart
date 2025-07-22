import 'package:byte_todo/providers/todo_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart' as todo_prov;
import '../auth/signin_screen.dart' as signin;
import '../auth/auth_service.dart';
import '../providers/todo_provider.dart' as todo_prov;

// Main screen where users can manage their daily tasks
class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current list of todos from our provider
    final todoList = ref.watch(todoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Todos"),
        backgroundColor: Colors.deepPurple.shade100,
      ),
      body: todoList.when(
        data: (todoList) => Column(
          children: [
            // Top section where users can add new todos
            _buildAddTodoSection(ref),

            // Main content area it shows either empty state or todo list
            Expanded(
              child: todoList.isEmpty
                  ? _buildEmptyState()
                  : _buildTodoList(todoList, ref),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error loading todos: $e")),
      ),
    );
  }

  // Creates the input area where users can type and add new todos shows logged in user at top and sign out button
  Widget _buildAddTodoSection(WidgetRef ref) {
    final TextEditingController inputController = TextEditingController();
    final authServiceProvider = Provider<AuthService>((ref) => AuthService());
    final user = ref.watch(signin.emailProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the current user's email at the top and a sign out button
          Row(
            children: [
              Expanded(
                child: Text(
                  // Show the current user's email or 'Guest' if not logged in
                  "Logged in as: ${user ?? 'Guest'}",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await ref.read(authServiceProvider).signout();
                  Navigator.pushReplacement(
                    ref.context,
                    MaterialPageRoute(
                      builder: (context) => const signin.SignInScreen(),
                    ),
                  );
                },
                tooltip: "Sign out",
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: inputController,
                  decoration: const InputDecoration(
                    hintText: "What's on your mind?",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (text) => _addTodo(ref, inputController, text),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton.small(
                onPressed: () =>
                    _addTodo(ref, inputController, inputController.text),
                tooltip: "Add todo",
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Handles adding a new todo to the list
  Future<void> _addTodo(
    WidgetRef ref,
    TextEditingController controller,
    String text,
  ) async {
    final todoList = TodoProvider();
    final trimmedText = text.trim();
    // Only add if user actually typed something
    if (trimmedText.isNotEmpty) {
      await todoList.add(trimmedText);
      controller.clear(); // Clear the input field
    }
  }

  // Shows a friendly message when there are no todos yet
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "No todos yet!",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add your first task above",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // Creates a scrollable list of all todos
  Widget _buildTodoList(List<dynamic> todoList, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: todoList.length,
      itemBuilder: (context, index) {
        final todo = todoList[index];
        return _buildTodoItem(context, ref, todo);
      },
    );
  }

  // Creates each individual todo item with checkbox and actions
  Widget _buildTodoItem(BuildContext context, WidgetRef ref, dynamic todo) {
    final todoList = TodoProvider();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        // Checkbox to mark todo as done/undone
        leading: Checkbox(
          value: todo.isDone,
          onChanged: (_) async => await todoList.toggleStatus(todo.id),
          activeColor: const Color.fromRGBO(103, 58, 183, 1),
        ),
        // Todo text with strikethrough effect when completed
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isDone
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: todo.isDone ? Colors.grey.shade500 : Colors.black87,
            fontSize: 16,
          ),
        ),
        // Edit and delete buttons
        trailing: _buildActionButtons(context, ref, todo),
      ),
    );
  }

  // Creates the edit and delete buttons for each todo
  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    dynamic todo,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit button
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _showEditDialog(context, ref, todo.id, todo.title),
          tooltip: "Edit todo",
        ),
        // Delete button
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _showDeleteConfirmation(context, ref, todo),
          tooltip: "Delete todo",
        ),
      ],
    );
  }

  // Shows a dialog where users can edit their todo text
  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    String id,
    String currentTitle,
  ) {
    final editController = TextEditingController(text: currentTitle);
    final todoList = TodoProvider();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Todo"),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            hintText: "Update your todo",
            border: OutlineInputBorder(),
          ),
          autofocus: true, // Automatically focus the text field
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          // Save button
          FilledButton(
            onPressed: () async {
              final updatedText = editController.text.trim();
              // Only save if user entered something
              if (updatedText.isNotEmpty) {
                await todoList.updateTitle(id, updatedText);
              }
              Navigator.of(context).pop();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // Shows a confirmation dialog before deleting a todo
  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    dynamic todo,
  ) {
    final todoList = TodoProvider();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Todo"),
        content: Text("Are you sure you want to delete '${todo.title}'?"),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          // Delete button with red color to indicate danger
          FilledButton(
            onPressed: () async {
              await todoList.remove(todo.id);
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
