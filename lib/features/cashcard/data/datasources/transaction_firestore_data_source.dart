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

    return _transactionsCollection
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              // Ensure the document ID matches the transaction ID
              data['id'] = doc.id;
              return entity.Transaction.fromMap(data);
            }).toList();
          } catch (e) {
            print('Error processing transaction documents: $e');
            return <entity.Transaction>[];
          }
        })
        .handleError((error) {
          print('Error in transaction stream: $error');
          return <entity.Transaction>[];
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

    // Use set with merge instead of update to handle non-existing documents
    return _transactionsCollection
        .doc(transaction.id)
        .set(transactionData, SetOptions(merge: true));
  }

  @override
  Future<void> deleteTransaction(String id) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      return await _transactionsCollection.doc(id).delete();
    } catch (e) {
      // Log the error but don't throw if document doesn't exist
      print('Error deleting transaction $id: $e');
      if (e.toString().contains('not-found')) {
        // Document already doesn't exist, consider this a successful deletion
        return;
      }
      rethrow;
    }
  }
}
