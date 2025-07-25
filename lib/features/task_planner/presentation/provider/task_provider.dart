import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;

class TaskProvider with ChangeNotifier {
  final TaskRepository taskRepository;
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  TaskProvider({required this.taskRepository}) {
    _initializeTaskStream();
  }

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => FirebaseAuth.instance.currentUser != null;

  void _initializeTaskStream() {
    // Listen to authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _setupTaskStream();
      } else {
        _tasks = [];
        _error = null;
        notifyListeners();
      }
    });
  }

  void _setupTaskStream() {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      taskRepository.getTasks().listen(
        (taskList) {
          _tasks = taskList;
          _isLoading = false;
          _error = null;
          notifyListeners();
        },
        onError: (error) {
          developer.log(
            'Error getting tasks: $error',
            name: 'TaskProvider',
            error: error,
          );
          _error = _formatError(error);
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = _formatError(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(
    String title,
    String description,
    DateTime dueDate,
  ) async {
    if (!isAuthenticated) {
      _error = 'Please sign in to add tasks';
      notifyListeners();
      return;
    }

    try {
      _error = null;
      const uuid = Uuid();
      final now = DateTime.now();

      final newTask = Task(
        id: uuid.v4(),
        title: title,
        description: description,
        dueDate: dueDate,
        createdAt: now,
        updatedAt: now,
      );

      await taskRepository.addTask(newTask);
      // The listener will update _tasks and notifyListeners()
    } catch (e) {
      developer.log(
        'Error adding task: $e',
        name: 'TaskProvider.addTask',
        error: e,
      );
      _error = _formatError(e);
      notifyListeners();
      rethrow; // Re-throw for UI to handle
    }
  }

  Future<void> toggleTaskStatus(String id) async {
    if (!isAuthenticated) {
      _error = 'Please sign in to update tasks';
      notifyListeners();
      return;
    }

    try {
      _error = null;
      final taskToUpdate = _tasks.firstWhere((task) => task.id == id);
      final now = DateTime.now();

      final updatedTask = taskToUpdate.copyWith(
        isCompleted: !taskToUpdate.isCompleted,
        updatedAt: now,
        completedAt: !taskToUpdate.isCompleted ? now : null,
      );

      await taskRepository.updateTask(updatedTask);
      // The listener will update _tasks and notifyListeners()
    } catch (e) {
      developer.log(
        'Error toggling task status: $e',
        name: 'TaskProvider.toggleTaskStatus',
        error: e,
      );
      _error = _formatError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    if (!isAuthenticated) {
      _error = 'Please sign in to delete tasks';
      notifyListeners();
      return;
    }

    try {
      _error = null;
      await taskRepository.deleteTask(id);
      // The listener will update _tasks and notifyListeners()
    } catch (e) {
      developer.log(
        'Error deleting task: $e',
        name: 'TaskProvider.deleteTask',
        error: e,
      );
      _error = _formatError(e);
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Format error messages for user-friendly display
  String _formatError(dynamic error) {
    if (error.toString().contains('permission-denied')) {
      return 'Access denied. Please check your login status.';
    } else if (error.toString().contains('network')) {
      return 'Network error. Please check your connection.';
    } else if (error.toString().contains('User not authenticated')) {
      return 'Please sign in to access your tasks.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }
}
