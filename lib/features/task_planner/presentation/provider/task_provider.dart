import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository taskRepository;
  // Initial state can be an empty list or loading indicator
  List<Task> _tasks = [];

  TaskProvider({required this.taskRepository}) {
    // Listen to the stream of tasks from the repository
    taskRepository.getTasks().listen((taskList) {
      _tasks = taskList;
      notifyListeners();
    });
  }

  List<Task> get tasks => _tasks;

  Future<void> addTask(String title, String description, DateTime dueDate) async {
    const uuid = Uuid();
    final newTask = Task(
      id: uuid.v4(),
      title: title,
      description: description,
      dueDate: dueDate,
    );
    await taskRepository.addTask(newTask);
    // The listener will update _tasks and notifyListeners()
  }

  Future<void> toggleTaskStatus(String id) async {
    final taskToUpdate = _tasks.firstWhere((task) => task.id == id);
    final updatedTask = taskToUpdate.copyWith(isCompleted: !taskToUpdate.isCompleted);
    await taskRepository.updateTask(updatedTask);
    // The listener will update _tasks and notifyListeners()
  }

  Future<void> deleteTask(String id) async {
    await taskRepository.deleteTask(id);
    // The listener will update _tasks and notifyListeners()
  }
}
