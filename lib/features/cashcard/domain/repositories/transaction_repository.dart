import '../entities/transaction.dart' as entity;

abstract class TransactionRepository {
  Future<void> addTransaction(entity.Transaction transaction);
  Stream<List<entity.Transaction>> getTransactions();
  Future<void> updateTransaction(entity.Transaction transaction);
  Future<void> deleteTransaction(String id);
}
