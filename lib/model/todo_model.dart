class Todo {
  final String id;
  final String title;
  final bool isDone;

  Todo({required this.id, required this.title, this.isDone = false});

  Todo copyWith({String? title, bool? isDone}) {
    return Todo(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}
