import 'package:flutter/material.dart';
import '../domain/entities/transaction.dart';

class CashcardProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];
  // Filter state
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _showAllTime = true; // New flag for all time view

  List<Transaction> get transactions {
    if (_showAllTime) {
      return _transactions; // Return all transactions if showAllTime is true
    } else {
      // Apply month/year filter
      return _transactions.where((transaction) {
        return transaction.date.month == _selectedMonth &&
               transaction.date.year == _selectedYear;
      }).toList();
    }
  }

  // Getter for selected month and year
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  bool get showAllTime => _showAllTime; // Getter for the new flag

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

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    // When a new transaction is added, perhaps reset to all time or show the month of the new transaction?
    // For now, let's just notify listeners.
    notifyListeners();
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((transaction) => transaction.id == id);
    notifyListeners();
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

  // You might want a method to clear the filter later
  // void clearFilter() {
  //   _selectedMonth = DateTime.now().month;
  //   _selectedYear = DateTime.now().year;
  //   notifyListeners();
  // }
}
