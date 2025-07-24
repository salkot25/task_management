import 'package:flutter/material.dart';
import 'package:myapp/features/cashcard/domain/entities/transaction.dart';
import 'package:myapp/features/cashcard/domain/repositories/transaction_repository.dart';

class CashcardProvider with ChangeNotifier {
  final TransactionRepository repository;
  List<Transaction> _transactions = [];

  // Added for filtering
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _showAllTime = true; // New flag for all time view

  // Added for tracking the selected transaction type in the modal
  TransactionType _selectedTransactionType =
      TransactionType.expense; // Default to expense

  CashcardProvider(this.repository) {
    _listenToTransactions();
  }

  List<Transaction> get transactions {
    if (_showAllTime) {
      return _transactions; // Return all transactions if showAllTime is true
    } else {
      // Apply month/year filter
      return _transactions.where((transaction) {
        // Add null checks for transaction
        return transaction.date.month == _selectedMonth &&
            transaction.date.year == _selectedYear;
      }).toList();
    }
  }

  // Getter for selected month and year
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  bool get showAllTime => _showAllTime; // Getter for the new flag

  // Getter for the selected transaction type in the modal
  TransactionType get selectedTransactionType => _selectedTransactionType;

  // Calculate total income for the *currently displayed* transactions (filtered or all time)
  double get totalIncome {
    return transactions
        .where((transaction) => transaction.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Calculate total expense for the *currently displayed* transactions (filtered or all time)
  double get totalExpense {
    return transactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Calculate overall balance (across ALL transactions, regardless of filter)
  double get balance {
    double totalIncomeAll = _transactions
        .where((transaction) => transaction.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
    double totalExpenseAll = _transactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
    return totalIncomeAll - totalExpenseAll;
  }

  void _listenToTransactions() {
    repository.getTransactions().listen((newTransactions) {
      _transactions = newTransactions;
      // Sort transactions by date in descending order
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    });
  }

  Future<void> addTransaction(Transaction transaction) async {
    await repository.addTransaction(transaction);
    // Data will be updated via the stream listener, so no need to add to _transactions list directly
  }

  Future<void> deleteTransaction(String id) async {
    await repository.deleteTransaction(id); // Call delete method on repository
    // Data will be updated via the stream listener, so no need to remove from _transactions list directly
  }

  // Method to set the filter by month and year
  void setFilter(int month, int year) {
    _selectedMonth = month;
    _selectedYear = year;
    _showAllTime = false; // Disable all time when setting a specific filter
    notifyListeners();
  }

  // Method to set the filter to show all time
  void setShowAllTime(bool value) {
    _showAllTime = value;
    notifyListeners();
  }

  // Method to update the selected transaction type in the modal
  void setSelectedTransactionType(TransactionType type) {
    _selectedTransactionType = type;
    notifyListeners();
  }

  // You might want a method to clear the filter later
  // void clearFilter() {
  //   _selectedMonth = DateTime.now().month;
  //   _selectedYear = DateTime.now().year;
  //   notifyListeners();
  // }
}
