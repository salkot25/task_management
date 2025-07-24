
class Task {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime dueDate;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.dueDate,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  // Convert Task object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'dueDate': dueDate.toIso8601String(), // Convert DateTime to String
    };
  }

  // Create a Task object from a Firestore Map with error handling for dueDate
  factory Task.fromMap(Map<String, dynamic> map) {
    DateTime parsedDueDate;
    try {
      // Try to parse the dueDate string. Handle potential null or invalid format.
      final dueDateString = map['dueDate'];
      if (dueDateString != null) {
        parsedDueDate = DateTime.parse(dueDateString);
      } else {
        // Provide a default DateTime if dueDate is null
        parsedDueDate = DateTime.now(); // Or handle as appropriate for your app
      }
    } catch (e) {
      // Handle parsing errors, e.g., if the format is unexpected
      print('Error parsing dueDate: $e. Using current DateTime.'); // Log the error
      parsedDueDate = DateTime.now(); // Provide a default DateTime on error
    }

    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      dueDate: parsedDueDate,
    );
  }
}
