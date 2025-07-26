import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/features/cashcard/domain/entities/transaction.dart'
    as entity;
import 'package:myapp/features/cashcard/domain/repositories/transaction_repository.dart';
import 'package:myapp/features/cashcard/domain/entities/budget_models.dart';

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
    _initializeDefaultBudgetCategories();
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
    // Auto-update budget if it's an expense with category
    if (transaction.type == entity.TransactionType.expense &&
        transaction.category != null) {
      _autoUpdateBudgetSpending(transaction);
    }
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

  void resetBudgetSpending() {
    for (int i = 0; i < _budgetCategories.length; i++) {
      final category = _budgetCategories[i];
      _budgetCategories[i] = BudgetCategory(
        name: category.name,
        budgetAmount: category.budgetAmount,
        spentAmount: 0, // Reset spending to 0
        color: category.color,
        icon: category.icon,
      );
    }
    notifyListeners();
  }

  void _initializeDefaultBudgetCategories() {
    if (_budgetCategories.isEmpty) {
      // Add some default budget categories
      final defaultCategories = [
        BudgetCategory(
          name: 'Food & Dining',
          budgetAmount: 2000000, // 2 juta
          spentAmount: 0,
          color: _getCategoryColorByName('Food & Dining'),
          icon: _getCategoryIconByName('Food & Dining'),
        ),
        BudgetCategory(
          name: 'Transportation',
          budgetAmount: 1000000, // 1 juta
          spentAmount: 0,
          color: _getCategoryColorByName('Transportation'),
          icon: _getCategoryIconByName('Transportation'),
        ),
        BudgetCategory(
          name: 'Entertainment',
          budgetAmount: 500000, // 500 ribu
          spentAmount: 0,
          color: _getCategoryColorByName('Entertainment'),
          icon: _getCategoryIconByName('Entertainment'),
        ),
      ];

      _budgetCategories.addAll(defaultCategories);
      // Update spending based on existing transactions
      _updateBudgetSpending();
    }
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

  // Auto-update budget spending when a new transaction is added
  void _autoUpdateBudgetSpending(entity.Transaction transaction) {
    if (transaction.type == entity.TransactionType.expense) {
      String categoryName;

      // Get category name from transaction or description
      if (transaction.category != null) {
        categoryName = transaction.getCategoryDisplayName();
      } else {
        categoryName = _getCategoryFromDescription(transaction.description);
      }

      // Update the corresponding budget category
      for (int i = 0; i < _budgetCategories.length; i++) {
        if (_budgetCategories[i].name == categoryName) {
          final category = _budgetCategories[i];
          _budgetCategories[i] = BudgetCategory(
            name: category.name,
            budgetAmount: category.budgetAmount,
            spentAmount: category.spentAmount + transaction.amount,
            color: category.color,
            icon: category.icon,
          );
          break;
        }
      }
    }
  }

  // Get budget status for a specific category
  BudgetStatus getBudgetStatus(String categoryName) {
    final category = _budgetCategories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => BudgetCategory(
        name: categoryName,
        budgetAmount: 0,
        spentAmount: 0,
        color: Colors.grey,
        icon: Icons.category,
      ),
    );

    return BudgetStatus(
      categoryName: categoryName,
      budgetAmount: category.budgetAmount,
      spentAmount: category.spentAmount,
      remainingAmount: category.remainingAmount,
      progressPercentage: category.progressPercentage,
      isOverBudget: category.isOverBudget,
    );
  }

  // Get budget recommendations based on spending patterns
  List<BudgetRecommendation> getBudgetRecommendations() {
    final recommendations = <BudgetRecommendation>[];

    // Analyze spending patterns for the last 3 months
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    final recentTransactions = _transactions
        .where(
          (t) =>
              t.date.isAfter(threeMonthsAgo) &&
              t.type == entity.TransactionType.expense,
        )
        .toList();

    // Calculate average monthly spending per category
    final categorySpending = <String, double>{};
    for (final transaction in recentTransactions) {
      final categoryName = transaction.category != null
          ? transaction.getCategoryDisplayName()
          : _getCategoryFromDescription(transaction.description);

      categorySpending[categoryName] =
          (categorySpending[categoryName] ?? 0) + transaction.amount;
    }

    // Generate recommendations
    categorySpending.forEach((category, totalSpent) {
      final avgMonthlySpent = totalSpent / 3; // 3 months average
      final existingBudget = _budgetCategories
          .where((b) => b.name == category)
          .firstOrNull;

      if (existingBudget == null) {
        // Recommend creating budget for categories with significant spending
        if (avgMonthlySpent > 100000) {
          // Rp 100,000 threshold
          recommendations.add(
            BudgetRecommendation(
              type: RecommendationType.createBudget,
              categoryName: category,
              currentAmount: 0,
              recommendedAmount: (avgMonthlySpent * 1.2)
                  .roundToDouble(), // 20% buffer
              reason:
                  'You spend an average of ${_formatCurrency(avgMonthlySpent)} monthly in this category',
            ),
          );
        }
      } else {
        // Recommend adjusting existing budget
        final currentBudget = existingBudget.budgetAmount;
        final recommendedBudget = avgMonthlySpent * 1.1; // 10% buffer

        if (currentBudget < avgMonthlySpent * 0.8) {
          recommendations.add(
            BudgetRecommendation(
              type: RecommendationType.increaseBudget,
              categoryName: category,
              currentAmount: currentBudget,
              recommendedAmount: recommendedBudget,
              reason:
                  'Your current budget is too low based on spending patterns',
            ),
          );
        } else if (currentBudget > avgMonthlySpent * 1.5) {
          recommendations.add(
            BudgetRecommendation(
              type: RecommendationType.decreaseBudget,
              categoryName: category,
              currentAmount: currentBudget,
              recommendedAmount: recommendedBudget,
              reason: 'You can reduce this budget and allocate funds elsewhere',
            ),
          );
        }
      }
    });

    return recommendations;
  }

  // Auto-create budget based on spending patterns
  void autoCreateBudgetCategories() {
    final recommendations = getBudgetRecommendations()
        .where((r) => r.type == RecommendationType.createBudget)
        .toList();

    for (final recommendation in recommendations) {
      if (!_budgetCategories.any(
        (b) => b.name == recommendation.categoryName,
      )) {
        final newCategory = BudgetCategory(
          name: recommendation.categoryName,
          budgetAmount: recommendation.recommendedAmount,
          spentAmount: _calculateCategorySpending(recommendation.categoryName),
          color: _getCategoryColorByName(recommendation.categoryName),
          icon: _getCategoryIconByName(recommendation.categoryName),
        );
        _budgetCategories.add(newCategory);
      }
    }
    notifyListeners();
  }

  // Get budget alerts (notifications)
  List<BudgetAlert> getBudgetAlerts() {
    final alerts = <BudgetAlert>[];

    for (final category in _budgetCategories) {
      if (category.isOverBudget) {
        alerts.add(
          BudgetAlert(
            type: AlertType.overBudget,
            categoryName: category.name,
            amount: category.spentAmount - category.budgetAmount,
            message:
                'You\'ve exceeded your ${category.name} budget by ${_formatCurrency(category.spentAmount - category.budgetAmount)}',
          ),
        );
      } else if (category.progressPercentage > 0.8) {
        alerts.add(
          BudgetAlert(
            type: AlertType.approaching,
            categoryName: category.name,
            amount: category.remainingAmount,
            message:
                'You\'re approaching your ${category.name} budget limit. ${_formatCurrency(category.remainingAmount)} remaining',
          ),
        );
      }
    }

    return alerts;
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  Color _getCategoryColorByName(String categoryName) {
    final colorMap = {
      'Food & Dining': Colors.orange,
      'Transportation': Colors.blue,
      'Shopping': Colors.purple,
      'Health & Medical': Colors.red,
      'Entertainment': Colors.pink,
      'Utilities': Colors.green,
      'Education': Colors.indigo,
      'Reward P2TL': Colors.amber,
      'Others': Colors.grey,
    };
    return colorMap[categoryName] ?? Colors.grey;
  }

  IconData _getCategoryIconByName(String categoryName) {
    final iconMap = {
      'Food & Dining': Icons.restaurant,
      'Transportation': Icons.directions_car,
      'Shopping': Icons.shopping_bag,
      'Health & Medical': Icons.local_hospital,
      'Entertainment': Icons.movie,
      'Utilities': Icons.receipt,
      'Education': Icons.school,
      'Reward P2TL': Icons.card_giftcard,
      'Others': Icons.category,
    };
    return iconMap[categoryName] ?? Icons.category;
  }

  // Public methods for external access
  Color getCategoryColorByName(String categoryName) {
    return _getCategoryColorByName(categoryName);
  }

  IconData getCategoryIconByName(String categoryName) {
    return _getCategoryIconByName(categoryName);
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
