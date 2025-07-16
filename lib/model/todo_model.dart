class Todo {
  final String id; 
  final String title; 
  final bool isDone; 
  
  //  creates a new todo 
  Todo({required this.id, required this.title, this.isDone = false});
  
  // Creates a copy of this todo 
  Todo copyWith({String? title, bool? isDone}) {
    return Todo(
      id: id, 
      title: title ?? this.title, 
      isDone: isDone ?? this.isDone, 
    );
  }

  // Converts todo object into a map 
  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'isDone': isDone};
  }

  // Creates a todo object from Firebase data 
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] ?? '', 
      title: map['title'] ?? '', 
      isDone: map['isDone'] ?? false, 
    );
  }
}