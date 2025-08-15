import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:developer' as developer;

class TaskProvider with ChangeNotifier {
  final TaskRepository taskRepository;
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Task>>? _tasksSubscription;
  StreamSubscription<User?>? _authSubscription;

  TaskProvider({required this.taskRepository}) {
    _initializeTaskStream();
  }

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => FirebaseAuth.instance.currentUser != null;

  void _initializeTaskStream() {
    // Listen to authentication state changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      if (user != null) {
        _setupTaskStream();
      } else {
        // User signed out, clean up and stop listening
        _tasksSubscription?.cancel();
        _tasks = [];
        _isLoading = false;
        _error = null;
        notifyListeners();
      }
    });
  }

  void _setupTaskStream() {
    try {
      // Cancel any existing subscription before creating a new one
      _tasksSubscription?.cancel();

      _isLoading = true;
      _error = null;
      notifyListeners();

      _tasksSubscription = taskRepository.getTasks().listen(
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
    TimeOfDay? dueTime, {
    RecurrenceType recurrenceType = RecurrenceType.none,
    int recurrenceInterval = 1,
    DateTime? recurrenceEndDate,
  }) async {
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
        dueTime: dueTime,
        recurrenceType: recurrenceType,
        recurrenceInterval: recurrenceInterval,
        recurrenceEndDate: recurrenceEndDate,
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

      // If this is a recurring task and it's being marked as completed,
      // create the next instance
      if (!taskToUpdate.isCompleted && taskToUpdate.isRecurring) {
        await _createNextRecurringInstance(taskToUpdate);
      }

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

  /// Create the next instance of a recurring task
  Future<void> _createNextRecurringInstance(Task completedTask) async {
    try {
      final nextInstance = completedTask.createNextInstance();
      if (nextInstance != null) {
        const uuid = Uuid();
        final taskWithId = nextInstance.copyWith(id: uuid.v4());
        await taskRepository.addTask(taskWithId);

        developer.log(
          'Created next recurring instance for task: ${completedTask.title}',
          name: 'TaskProvider._createNextRecurringInstance',
        );
      }
    } catch (e) {
      developer.log(
        'Error creating next recurring instance: $e',
        name: 'TaskProvider._createNextRecurringInstance',
        error: e,
      );
      // Don't rethrow here as we don't want to break the main toggle operation
    }
  }

  /// Delete a recurring task and optionally all its future instances
  Future<void> deleteRecurringTask(
    String id, {
    bool deleteAllInstances = false,
  }) async {
    if (!isAuthenticated) {
      _error = 'Please sign in to delete tasks';
      notifyListeners();
      return;
    }

    try {
      _error = null;

      if (deleteAllInstances) {
        final taskToDelete = _tasks.firstWhere((task) => task.id == id);
        final parentId = taskToDelete.parentTaskId ?? id;

        // Find all instances of this recurring task
        final allInstances = _tasks
            .where(
              (task) => task.id == parentId || task.parentTaskId == parentId,
            )
            .toList();

        // Delete all instances
        for (final instance in allInstances) {
          await taskRepository.deleteTask(instance.id);
        }
      } else {
        // Delete only this instance
        await taskRepository.deleteTask(id);
      }

      // The listener will update _tasks and notifyListeners()
    } catch (e) {
      developer.log(
        'Error deleting recurring task: $e',
        name: 'TaskProvider.deleteRecurringTask',
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

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
