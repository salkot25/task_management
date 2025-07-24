import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void addTask(String title, String description, DateTime dueDate) {
    const uuid = Uuid();
    final newTask = Task(
      id: uuid.v4(),
      title: title,
      description: description,
      dueDate: dueDate,
    );
    _tasks.add(newTask);
    notifyListeners();
  }

  void toggleTaskStatus(String id) {
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex != -1) {
      _tasks[taskIndex] = _tasks[taskIndex].copyWith(
        isCompleted: !_tasks[taskIndex].isCompleted,
      );
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}
