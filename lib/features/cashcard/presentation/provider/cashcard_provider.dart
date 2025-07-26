import 'package:flutter/material.dart';
import 'package:myapp/features/cashcard/domain/entities/transaction.dart'
    as entity;
import 'package:myapp/features/cashcard/domain/repositories/transaction_repository.dart';
import 'package:myapp/features/cashcard/presentation/widgets/budget_management.dart';

class CashcardProvider with ChangeNotifier {
  final TransactionRepository repository;
  List<entity.Transaction> _transactions = [];
  final List<BudgetCategory> _budgetCategories = [];

  // Added for filtering
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _showAllTime = true; // New flag for all time view

  // Added for tracking the selected transaction type in the modal
  entity.TransactionType _selectedTransactionType =
      entity.TransactionType.expense; // Default to expense

  // Added for tracking the selected expense category in the modal
  entity.ExpenseCategory _selectedExpenseCategory =
      entity.ExpenseCategory.others; // Default to others

  CashcardProvider(this.repository) {
    _listenToTransactions();
  }

  List<entity.Transaction> get transactions {
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

  List<BudgetCategory> get budgetCategories => _budgetCategories;

  // Getter for the selected transaction type in the modal
  entity.TransactionType get selectedTransactionType =>
      _selectedTransactionType;

  // Getter for the selected expense category in the modal
  entity.ExpenseCategory get selectedExpenseCategory =>
      _selectedExpenseCategory;

  // Calculate total income for the *currently displayed* transactions (filtered or all time)
  double get totalIncome {
    return transactions
        .where(
          (transaction) => transaction.type == entity.TransactionType.income,
        )
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Calculate total expense for the *currently displayed* transactions (filtered or all time)
  double get totalExpense {
    return transactions
        .where(
          (transaction) => transaction.type == entity.TransactionType.expense,
        )
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Calculate overall balance (across ALL transactions, regardless of filter)
  double get balance {
    double totalIncomeAll = _transactions
        .where(
          (transaction) => transaction.type == entity.TransactionType.income,
        )
        .fold(0.0, (sum, item) => sum + item.amount);
    double totalExpenseAll = _transactions
        .where(
          (transaction) => transaction.type == entity.TransactionType.expense,
        )
        .fold(0.0, (sum, item) => sum + item.amount);
    return totalIncomeAll - totalExpenseAll;
  }

  void _listenToTransactions() {
    repository.getTransactions().listen((newTransactions) {
      _transactions = newTransactions;
      // Sort transactions by date in descending order
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      // Update budget spending when transactions change
      _updateBudgetSpending();
      notifyListeners();
    });
  }

  Future<void> addTransaction(entity.Transaction transaction) async {
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
  void setSelectedTransactionType(entity.TransactionType type) {
    _selectedTransactionType = type;
    notifyListeners();
  }

  // Method to update the selected expense category in the modal
  void setSelectedExpenseCategory(entity.ExpenseCategory category) {
    _selectedExpenseCategory = category;
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
              transaction.type == entity.TransactionType.expense &&
              (transaction.category != null
                  ? transaction.getCategoryDisplayName() == categoryName
                  : _getCategoryFromDescription(transaction.description) ==
                        categoryName),
        )
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  String _getCategoryFromDescription(String description) {
    final lowerDesc = description.toLowerCase();

    if (lowerDesc.contains('reward') ||
        lowerDesc.contains('p2tl') ||
        lowerDesc.contains('cashback') ||
        lowerDesc.contains('points')) {
      return 'Reward P2TL';
    } else if (lowerDesc.contains('food') ||
        lowerDesc.contains('makan') ||
        lowerDesc.contains('lunch') ||
        lowerDesc.contains('dinner')) {
      return 'Food & Dining';
    } else if (lowerDesc.contains('transport') ||
        lowerDesc.contains('gas') ||
        lowerDesc.contains('fuel') ||
        lowerDesc.contains('bensin')) {
      return 'Transportation';
    } else if (lowerDesc.contains('shop') ||
        lowerDesc.contains('buy') ||
        lowerDesc.contains('beli') ||
        lowerDesc.contains('belanja')) {
      return 'Shopping';
    } else if (lowerDesc.contains('health') ||
        lowerDesc.contains('medical') ||
        lowerDesc.contains('hospital') ||
        lowerDesc.contains('dokter')) {
      return 'Health & Medical';
    } else if (lowerDesc.contains('entertainment') ||
        lowerDesc.contains('movie') ||
        lowerDesc.contains('game') ||
        lowerDesc.contains('hiburan')) {
      return 'Entertainment';
    } else if (lowerDesc.contains('utilities') ||
        lowerDesc.contains('listrik') ||
        lowerDesc.contains('air') ||
        lowerDesc.contains('internet')) {
      return 'Utilities';
    } else if (lowerDesc.contains('education') ||
        lowerDesc.contains('school') ||
        lowerDesc.contains('course') ||
        lowerDesc.contains('belajar')) {
      return 'Education';
    } else {
      return 'Others';
    }
  }

  // Method to get ExpenseCategory enum from description (public version)
  entity.ExpenseCategory getExpenseCategoryFromDescription(String description) {
    return _getExpenseCategoryFromDescription(description);
  }

  // Method to get ExpenseCategory enum from description
  entity.ExpenseCategory _getExpenseCategoryFromDescription(
    String description,
  ) {
    final lowerDesc = description.toLowerCase();

    if (lowerDesc.contains('reward') ||
        lowerDesc.contains('p2tl') ||
        lowerDesc.contains('cashback') ||
        lowerDesc.contains('points')) {
      return entity.ExpenseCategory.rewardP2TL;
    } else if (lowerDesc.contains('food') ||
        lowerDesc.contains('makan') ||
        lowerDesc.contains('lunch') ||
        lowerDesc.contains('dinner')) {
      return entity.ExpenseCategory.food;
    } else if (lowerDesc.contains('transport') ||
        lowerDesc.contains('gas') ||
        lowerDesc.contains('fuel') ||
        lowerDesc.contains('bensin')) {
      return entity.ExpenseCategory.transport;
    } else if (lowerDesc.contains('shop') ||
        lowerDesc.contains('buy') ||
        lowerDesc.contains('beli') ||
        lowerDesc.contains('belanja')) {
      return entity.ExpenseCategory.shopping;
    } else if (lowerDesc.contains('health') ||
        lowerDesc.contains('medical') ||
        lowerDesc.contains('hospital') ||
        lowerDesc.contains('dokter')) {
      return entity.ExpenseCategory.health;
    } else if (lowerDesc.contains('entertainment') ||
        lowerDesc.contains('movie') ||
        lowerDesc.contains('game') ||
        lowerDesc.contains('hiburan')) {
      return entity.ExpenseCategory.entertainment;
    } else if (lowerDesc.contains('utilities') ||
        lowerDesc.contains('listrik') ||
        lowerDesc.contains('air') ||
        lowerDesc.contains('internet')) {
      return entity.ExpenseCategory.utilities;
    } else if (lowerDesc.contains('education') ||
        lowerDesc.contains('school') ||
        lowerDesc.contains('course') ||
        lowerDesc.contains('belajar')) {
      return entity.ExpenseCategory.education;
    } else {
      return entity.ExpenseCategory.others;
    }
  }

  // You might want a method to clear the filter later
  // void clearFilter() {
  //   _selectedMonth = DateTime.now().month;
  //   _selectedYear = DateTime.now().year;
  //   notifyListeners();
  // }
}
