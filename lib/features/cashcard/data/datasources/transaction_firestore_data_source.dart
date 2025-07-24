import 'package:cloud_firestore/cloud_firestore.dart' as firestore; // Use prefix
import '../../domain/entities/transaction.dart';

abstract class TransactionFirestoreDataSource {
  Future<void> addTransaction(Transaction transaction);
  Stream<List<Transaction>> getTransactions();
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTask(String id); // Added delete method
}

class TransactionFirestoreDataSourceImpl implements TransactionFirestoreDataSource {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;

  @override
  Future<void> addTransaction(Transaction transaction) {
    return _firestore.collection('transactions').doc(transaction.id).set(transaction.toMap());
  }

  @override
  Stream<List<Transaction>> getTransactions() {
    return _firestore.collection('transactions').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Transaction.fromMap(doc.data())).toList();
    });
  }

  @override
  Future<void> updateTransaction(Transaction transaction) {
    return _firestore.collection('transactions').doc(transaction.id).update(transaction.toMap());
  }

  @override
  Future<void> deleteTask(String id) {
    return _firestore.collection('transactions').doc(id).delete();
  }
}