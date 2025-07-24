import '../../domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<void> addTransaction(Transaction transaction);
  Stream<List<Transaction>> getTransactions();
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id); // Corrected method name to deleteTransaction
}