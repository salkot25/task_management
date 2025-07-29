import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/transaction.dart' as entity;

abstract class TransactionFirestoreDataSource {
  Future<void> addTransaction(entity.Transaction transaction);
  Stream<List<entity.Transaction>> getTransactions();
  Future<void> updateTransaction(entity.Transaction transaction);
  Future<void> deleteTransaction(String id);
}

class TransactionFirestoreDataSourceImpl
    implements TransactionFirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _transactionsCollection {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('transactions');
  }

  @override
  Future<void> addTransaction(entity.Transaction transaction) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }
    // Only send allowed fields to Firestore
    final transactionData = {
      'amount': transaction.amount,
      'type': transaction.type.name,
      'description': transaction.description,
      'date': transaction.date.toIso8601String(),
      if (transaction.category != null)
        'category': transaction.category.toString().split('.').last,
    };
    return _transactionsCollection.doc(transaction.id).set(transactionData);
  }

  @override
  Stream<List<entity.Transaction>> getTransactions() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _transactionsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Ensure the document ID matches the transaction ID
        data['id'] = doc.id;
        return entity.Transaction.fromMap(data);
      }).toList();
    });
  }

  @override
  Future<void> updateTransaction(entity.Transaction transaction) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final transactionData = transaction.toMap();
    transactionData['userId'] = _currentUserId;
    transactionData['updatedAt'] = FieldValue.serverTimestamp();

    return _transactionsCollection.doc(transaction.id).update(transactionData);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _transactionsCollection.doc(id).delete();
  }
}
