import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';

class TodoScreen extends ConsumerWidget {
  TodoScreen({super.key});

  final TextEditingController inputController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoList = ref.watch(todoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("My Todos")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: inputController,
                    decoration: const InputDecoration(
                      hintText: "What do you want to do?",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final text = inputController.text.trim();
                    if (text.isNotEmpty) {
                      ref.read(todoProvider.notifier).add(text);
                      inputController.clear();
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          Expanded(
            child: todoList.isEmpty
                ? const Center(child: Text("Nothing to show here"))
                : ListView.builder(
                    itemCount: todoList.length,
                    itemBuilder: (_, index) {
                      final item = todoList[index];

                      return ListTile(
                        leading: Checkbox(
                          value: item.isDone,
                          onChanged: (_) {
                            ref
                                .read(todoProvider.notifier)
                                .toggleStatus(item.id);
                          },
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            decoration: item.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showEditDialog(
                                  context,
                                  ref,
                                  item.id,
                                  item.title,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                ref.read(todoProvider.notifier).remove(item.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext ctx,
    WidgetRef ref,
    String id,
    String currentTitle,
  ) {
    final editCtrl = TextEditingController(text: currentTitle);

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text("Edit Task"),
        content: TextField(
          controller: editCtrl,
          decoration: const InputDecoration(hintText: "Update todo title"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final updatedText = editCtrl.text.trim();
              if (updatedText.isNotEmpty) {
                ref.read(todoProvider.notifier).updateTitle(id, updatedText);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
