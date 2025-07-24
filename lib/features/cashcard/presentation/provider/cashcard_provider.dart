import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';

class CashcardProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];
  
  // Added for filtering
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _showAllTime = false; // Added for the new filter

  List<Transaction> get transactions {
    if (_showAllTime) {
      return _transactions;
    } else {
      return _transactions.where((transaction) {
        return transaction.date.month == _selectedMonth && transaction.date.year == _selectedYear;
      }).toList();
    }
  }
  
   // Get all transactions regardless of filter (for calculating total income/expense/balance)
  List<Transaction> get allTransactions => _transactions;


  double get totalIncome {
    return transactions // Use filtered transactions for current view calculations
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
     return transactions // Use filtered transactions for current view calculations
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get balance {
     // Calculate balance based on ALL transactions, not just filtered ones
     final totalIncomeAll = _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, item) => sum + item.amount);

    final totalExpenseAll = _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, item) => sum + item.amount);

    return totalIncomeAll - totalExpenseAll;
  }
  
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  bool get showAllTime => _showAllTime; // Getter for the new filter
  
  void setFilter(int month, int year) {
    _selectedMonth = month;
    _selectedYear = year;
    _showAllTime = false; // Ensure showAllTime is false when a specific month/year is set
    notifyListeners();
  }
  
  void setShowAllTime(bool value) { // Setter for the new filter
    _showAllTime = value;
    notifyListeners();
  }

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    // Sort transactions by date in descending order
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((transaction) => transaction.id == id);
    notifyListeners();
  }
}
