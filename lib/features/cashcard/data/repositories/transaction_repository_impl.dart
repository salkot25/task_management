import '../../domain/entities/transaction.dart' as entity;
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_firestore_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionFirestoreDataSource dataSource;

  TransactionRepositoryImpl(this.dataSource);

  @override
  Future<void> addTransaction(entity.Transaction transaction) {
    return dataSource.addTransaction(transaction);
  }

  @override
  Stream<List<entity.Transaction>> getTransactions() {
    return dataSource.getTransactions();
  }

  @override
  Future<void> updateTransaction(entity.Transaction transaction) {
    return dataSource.updateTransaction(transaction);
  }

  @override
  Future<void> deleteTransaction(String id) {
    return dataSource.deleteTransaction(id);
  }
}
