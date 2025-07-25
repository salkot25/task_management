import 'package:flutter/material.dart';
import '../domain/entities/transaction.dart';
import '../presentation/widgets/budget_management.dart';

class CashcardProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];
  final List<BudgetCategory> _budgetCategories = [];

  // Filter state
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _showAllTime = true; // New flag for all time view

  // Transaction type selection for add form
  TransactionType _selectedTransactionType = TransactionType.expense;

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

  List<BudgetCategory> get budgetCategories => _budgetCategories;

  TransactionType get selectedTransactionType => _selectedTransactionType;

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
    // Update budget categories with new spending
    _updateBudgetSpending();
    notifyListeners();
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((transaction) => transaction.id == id);
    // Update budget categories after removing transaction
    _updateBudgetSpending();
    notifyListeners();
  }

  void setSelectedTransactionType(TransactionType type) {
    _selectedTransactionType = type;
    notifyListeners();
  }

  // Budget Management Methods
  void addBudgetCategory(BudgetCategory category) {
    _budgetCategories.add(category);
    notifyListeners();
  }

  void updateBudgetCategory(BudgetCategory category, double newBudgetAmount) {
    final index = _budgetCategories.indexWhere((c) => c.name == category.name);
    if (index != -1) {
      final updatedCategory = BudgetCategory(
        name: category.name,
        budgetAmount: newBudgetAmount,
        spentAmount: category.spentAmount,
        color: category.color,
        icon: category.icon,
      );
      _budgetCategories[index] = updatedCategory;
      notifyListeners();
    }
  }

  void removeBudgetCategory(String categoryName) {
    _budgetCategories.removeWhere((category) => category.name == categoryName);
    notifyListeners();
  }

  void _updateBudgetSpending() {
    for (int i = 0; i < _budgetCategories.length; i++) {
      final category = _budgetCategories[i];
      final categorySpending = _calculateCategorySpending(category.name);

      _budgetCategories[i] = BudgetCategory(
        name: category.name,
        budgetAmount: category.budgetAmount,
        spentAmount: categorySpending,
        color: category.color,
        icon: category.icon,
      );
    }
  }

  double _calculateCategorySpending(String categoryName) {
    return _transactions
        .where(
          (transaction) =>
              transaction.type == TransactionType.expense &&
              _getCategoryFromDescription(transaction.description) ==
                  categoryName,
        )
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  String _getCategoryFromDescription(String description) {
    final lowerDesc = description.toLowerCase();

    if (lowerDesc.contains('food') ||
        lowerDesc.contains('makan') ||
        lowerDesc.contains('lunch') ||
        lowerDesc.contains('dinner')) {
      return 'Food';
    } else if (lowerDesc.contains('transport') ||
        lowerDesc.contains('gas') ||
        lowerDesc.contains('fuel') ||
        lowerDesc.contains('bensin')) {
      return 'Transport';
    } else if (lowerDesc.contains('shop') ||
        lowerDesc.contains('buy') ||
        lowerDesc.contains('beli') ||
        lowerDesc.contains('belanja')) {
      return 'Shopping';
    } else if (lowerDesc.contains('health') ||
        lowerDesc.contains('medical') ||
        lowerDesc.contains('hospital') ||
        lowerDesc.contains('dokter')) {
      return 'Health';
    } else if (lowerDesc.contains('entertainment') ||
        lowerDesc.contains('movie') ||
        lowerDesc.contains('game') ||
        lowerDesc.contains('hiburan')) {
      return 'Entertainment';
    } else {
      return 'Others';
    }
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
