import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/task.dart';

abstract class TaskFirestoreDataSource {
  Future<void> addTask(Task task);
  Stream<List<Task>> getTasks();
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
}

class TaskFirestoreDataSourceImpl implements TaskFirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current authenticated user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Get the user's tasks collection reference
  CollectionReference<Map<String, dynamic>> get _tasksCollection {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  @override
  Future<void> addTask(Task task) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final now = DateTime.now();
    final taskData = task.toMap();
    taskData['createdAt'] = Timestamp.fromDate(now);
    taskData['updatedAt'] = Timestamp.fromDate(now);

    return _tasksCollection.doc(task.id).set(taskData);
  }

  @override
  Stream<List<Task>> getTasks() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _tasksCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Ensure ID is included
            return Task.fromMap(data);
          }).toList();
        });
  }

  @override
  Future<void> updateTask(Task task) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final taskData = task.toMap();
    taskData['updatedAt'] = Timestamp.fromDate(DateTime.now());

    return _tasksCollection.doc(task.id).update(taskData);
  }

  @override
  Future<void> deleteTask(String id) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _tasksCollection.doc(id).delete();
  }
}
