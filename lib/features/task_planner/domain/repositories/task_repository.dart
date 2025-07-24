import '../../domain/entities/task.dart';
import '../../data/datasources/task_firestore_data_source.dart';

abstract class TaskRepository {
  Future<void> addTask(Task task);
  Stream<List<Task>> getTasks();
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
}

class TaskRepositoryImpl implements TaskRepository {
  final TaskFirestoreDataSource firestoreDataSource;

  TaskRepositoryImpl({required this.firestoreDataSource});

  @override
  Future<void> addTask(Task task) {
    return firestoreDataSource.addTask(task);
  }

  @override
  Stream<List<Task>> getTasks() {
    return firestoreDataSource.getTasks();
  }

  @override
  Future<void> updateTask(Task task) {
    return firestoreDataSource.updateTask(task);
  }

  @override
  Future<void> deleteTask(String id) {
    return firestoreDataSource.deleteTask(id);
  }
}
