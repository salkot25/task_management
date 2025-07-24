import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task.dart';

abstract class TaskFirestoreDataSource {
  Future<void> addTask(Task task);
  Stream<List<Task>> getTasks();
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
}

class TaskFirestoreDataSourceImpl implements TaskFirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addTask(Task task) {
    return _firestore.collection('tasks').doc(task.id).set(task.toMap());
  }

  @override
  Stream<List<Task>> getTasks() {
    return _firestore.collection('tasks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
    });
  }

  @override
  Future<void> updateTask(Task task) {
    return _firestore.collection('tasks').doc(task.id).update(task.toMap());
  }

  @override
  Future<void> deleteTask(String id) {
    return _firestore.collection('tasks').doc(id).delete();
  }
}
