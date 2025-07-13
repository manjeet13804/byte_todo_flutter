import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';

class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoList = ref.watch(todoProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Todos"),
        backgroundColor: Colors.deepPurple.shade100,
      ),
      body: Column(
        children: [
          _buildAddTodoSection(ref),

          Expanded(
            child: todoList.isEmpty
                ? _buildEmptyState()
                : _buildTodoList(todoList, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTodoSection(WidgetRef ref) {
    final TextEditingController inputController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
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
    );
  }

  void _addTodo(WidgetRef ref, TextEditingController controller, String text) {
    final trimmedText = text.trim();
    if (trimmedText.isNotEmpty) {
      ref.read(todoProvider.notifier).add(trimmedText);
      controller.clear();
    }
  }

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

  Widget _buildTodoItem(BuildContext context, WidgetRef ref, dynamic todo) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: todo.isDone,
          onChanged: (_) =>
              ref.read(todoProvider.notifier).toggleStatus(todo.id),
          activeColor: Colors.deepPurple,
        ),
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
        trailing: _buildActionButtons(context, ref, todo),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    dynamic todo,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _showEditDialog(context, ref, todo.id, todo.title),
          tooltip: "Edit todo",
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _showDeleteConfirmation(context, ref, todo),
          tooltip: "Delete todo",
        ),
      ],
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    String id,
    String currentTitle,
  ) {
    final editController = TextEditingController(text: currentTitle);
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
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              final updatedText = editController.text.trim();
              if (updatedText.isNotEmpty) {
                ref.read(todoProvider.notifier).updateTitle(id, updatedText);
              }
              Navigator.of(context).pop();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    dynamic todo,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Todo"),
        content: Text("Are you sure you want to delete '${todo.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              ref.read(todoProvider.notifier).remove(todo.id);
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
