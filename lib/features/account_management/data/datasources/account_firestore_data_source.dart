import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/account.dart';

abstract class AccountFirestoreDataSource {
  Future<void> addAccount(Account account);
  Stream<List<Account>> getAccounts();
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(String id);
}

class AccountFirestoreDataSourceImpl implements AccountFirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _accountsCollection {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('accounts');
  }

  @override
  Future<void> addAccount(Account account) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Add timestamp and userId to account data
    final accountData = account.toMap();
    accountData['userId'] = _currentUserId;
    accountData['createdAt'] = FieldValue.serverTimestamp();
    accountData['updatedAt'] = FieldValue.serverTimestamp();

    return _accountsCollection.doc(account.id).set(accountData);
  }

  @override
  Stream<List<Account>> getAccounts() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _accountsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Ensure the document ID matches the account ID
        data['id'] = doc.id;
        return Account.fromMap(data);
      }).toList();
    });
  }

  @override
  Future<void> updateAccount(Account account) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final accountData = account.toMap();
    accountData['userId'] = _currentUserId;
    accountData['updatedAt'] = FieldValue.serverTimestamp();

    return _accountsCollection.doc(account.id).update(accountData);
  }

  @override
  Future<void> deleteAccount(String id) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _accountsCollection.doc(id).delete();
  }
}
