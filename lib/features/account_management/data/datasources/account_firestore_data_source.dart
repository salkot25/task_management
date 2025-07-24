import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/account.dart';

abstract class AccountFirestoreDataSource {
  Future<void> addAccount(Account account);
  Stream<List<Account>> getAccounts();
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(String id);
}

class AccountFirestoreDataSourceImpl implements AccountFirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addAccount(Account account) {
    return _firestore.collection('accounts').doc(account.id).set(account.toMap());
  }

  @override
  Stream<List<Account>> getAccounts() {
    return _firestore.collection('accounts').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Account.fromMap(doc.data())).toList();
    });
  }

  @override
  Future<void> updateAccount(Account account) {
    return _firestore.collection('accounts').doc(account.id).update(account.toMap());
  }

  @override
  Future<void> deleteAccount(String id) {
    return _firestore.collection('accounts').doc(id).delete();
  }
}
