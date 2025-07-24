import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_firestore_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository { // Use implements correctly
  final TransactionFirestoreDataSource dataSource;

  TransactionRepositoryImpl(this.dataSource);

  @override
  Future<void> addTransaction(Transaction transaction) {
    return dataSource.addTransaction(transaction);
  }

  @override
  Stream<List<Transaction>> getTransactions() {
    return dataSource.getTransactions();
  }

  @override
  Future<void> updateTransaction(Transaction transaction) {
    return dataSource.updateTransaction(transaction);
  }

  @override
  Future<void> deleteTransaction(String id) { // Renamed to match the contract
    return dataSource.deleteTask(id); // Call the actual method in datasource
  }
}