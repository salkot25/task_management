import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clarity/features/cashcard/domain/entities/transaction.dart'
    as entity;
import 'package:clarity/features/cashcard/domain/repositories/transaction_repository.dart';
import 'package:clarity/features/cashcard/domain/entities/budget_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class CashcardProvider with ChangeNotifier {
  // Icon mapping for budget categories (const)
  static const Map<String, IconData> iconMap = {
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'shopping_bag': Icons.shopping_bag,
    'local_hospital': Icons.local_hospital,
    'movie': Icons.movie,
    'receipt': Icons.receipt,
    'school': Icons.school,
    'card_giftcard': Icons.card_giftcard,
    'category': Icons.category,
  };
  final TransactionRepository repository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<entity.Transaction> _transactions = [];
  List<BudgetCategory> _budgetCategories = [];
  final List<BudgetActivity> _budgetActivities = [];
  StreamSubscription? _budgetSubscription;
  bool _isUpdatingBudgetSpending = false;

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
    _listenToBudgets();

    // Delay initial budget spending update to allow both listeners to initialize
    Future.delayed(const Duration(seconds: 2), () {
      if (_budgetCategories.isNotEmpty && _transactions.isNotEmpty) {
        debugPrint('Initial budget spending update after delay...');
        _updateBudgetSpending();
      }
    });
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
    repository.getTransactions().listen(
      (newTransactions) {
        try {
          final oldTransactionCount = _transactions.length;
          _transactions = newTransactions;
          // Sort transactions by date in descending order
          _transactions.sort((a, b) => b.date.compareTo(a.date));

          // Only update budget spending if transactions changed AND we have budget categories
          if (_transactions.length != oldTransactionCount &&
              _budgetCategories.isNotEmpty) {
            debugPrint('Transactions changed, updating budget spending...');

            // Immediately update budget categories with real-time calculations
            _budgetCategories = _budgetCategories.map((category) {
              final realTimeSpent = _calculateCategorySpending(category.name);
              debugPrint(
                'Transaction change - Budget ${category.name}: ${category.spentAmount} -> $realTimeSpent',
              );
              return category.copyWith(spentAmount: realTimeSpent);
            }).toList();

            // Also update the database asynchronously
            _updateBudgetSpending();
          }

          notifyListeners();
        } catch (e) {
          debugPrint('Error processing transaction data: $e');
          notifyListeners();
        }
      },
      onError: (error) {
        debugPrint('Error listening to transactions: $error');
        // Initialize empty transactions on error
        _transactions = [];
        notifyListeners();
      },
    );
  }

  void _listenToBudgets() {
    _budgetSubscription?.cancel();
    final user = _auth.currentUser;
    if (user == null) return;
    _budgetSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('budgets')
        .snapshots()
        .listen(
          (snapshot) {
            try {
              final previousCategoryCount = _budgetCategories.length;

              // Load budget categories from Firestore
              final categoriesFromDb = snapshot.docs.map((doc) {
                final data = doc.data();
                return BudgetCategory(
                  name: data['name'] ?? '',
                  budgetAmount: (data['budgetAmount'] ?? 0).toDouble(),
                  spentAmount: (data['spentAmount'] ?? 0).toDouble(),
                  color: Color(data['colorValue'] ?? Colors.grey.value),
                  icon: iconMap[data['iconName']] ?? Icons.category,
                );
              }).toList();

              // Update the budget categories with real-time spending calculation
              _budgetCategories = categoriesFromDb.map((category) {
                // Only calculate real-time spending if we have transactions
                if (_transactions.isNotEmpty) {
                  final realTimeSpent = _calculateCategorySpending(
                    category.name,
                  );
                  debugPrint(
                    'Budget ${category.name}: DB=${category.spentAmount}, Calculated=$realTimeSpent',
                  );

                  // Use the real-time calculated amount instead of DB amount
                  return category.copyWith(spentAmount: realTimeSpent);
                } else {
                  // If no transactions yet, use the DB amount
                  debugPrint(
                    'Budget ${category.name}: Using DB amount=${category.spentAmount} (no transactions yet)',
                  );
                  return category;
                }
              }).toList();

              // If budget categories just loaded for the first time, force update database
              if (previousCategoryCount == 0 && _budgetCategories.isNotEmpty) {
                debugPrint(
                  'Budget categories loaded, updating spending amounts...',
                );
                // Force update database with calculated amounts
                Future.microtask(() => _forceUpdateAllBudgetSpending());
              }

              notifyListeners();
            } catch (e) {
              debugPrint('Error processing budget data: $e');
              notifyListeners();
            }
          },
          onError: (error) {
            debugPrint('Error listening to budgets: $error');
            // Initialize empty budget categories on error
            _budgetCategories = [];
            notifyListeners();
          },
        );
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

  // Budget Activities Getter
  List<BudgetActivity> get budgetActivities {
    // Return recent activities (last 10)
    final sortedActivities = List<BudgetActivity>.from(_budgetActivities)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedActivities.take(10).toList();
  }

  // Add budget activity
  void _addBudgetActivity(BudgetActivity activity) {
    _budgetActivities.add(activity);
    // Keep only last 50 activities to prevent memory issues
    if (_budgetActivities.length > 50) {
      _budgetActivities.removeRange(0, _budgetActivities.length - 50);
    }
    notifyListeners();
  }

  // Check for over budget and create activity
  void _checkOverBudgetAndCreateActivity(BudgetCategory category) {
    if (category.isOverBudget) {
      final exceededAmount = category.spentAmount - category.budgetAmount;
      // Check if we already have a recent over budget activity for this category
      final recentOverBudget = _budgetActivities
          .where(
            (activity) =>
                activity.categoryName == category.name &&
                activity.type == BudgetActivityType.overBudget &&
                DateTime.now().difference(activity.timestamp).inHours < 1,
          )
          .isNotEmpty;

      if (!recentOverBudget) {
        _addBudgetActivity(
          BudgetActivity.overBudget(
            categoryName: category.name,
            exceededAmount: exceededAmount,
          ),
        );
      }
    }
  }

  // Budget Management Methods
  Future<void> addBudgetCategory(BudgetCategory category) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('budgets')
        .doc(category.name);
    // Cari nama icon dari iconMap
    final iconName = iconMap.entries
        .firstWhere(
          (e) => e.value == category.icon,
          orElse: () => const MapEntry('category', Icons.category),
        )
        .key;
    await docRef.set({
      'name': category.name,
      'budgetAmount': category.budgetAmount,
      'spentAmount': category.spentAmount,
      'colorValue': category.color.value,
      'iconName': iconName,
    });

    // Add budget activity
    _addBudgetActivity(
      BudgetActivity.created(
        categoryName: category.name,
        amount: category.budgetAmount,
      ),
    );
  }

  Future<void> updateBudgetCategory(
    BudgetCategory category,
    double newBudgetAmount,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('budgets')
        .doc(category.name);
    // Use set with merge instead of update to handle non-existing documents
    await docRef.set({
      'budgetAmount': newBudgetAmount,
    }, SetOptions(merge: true));

    // Add budget activity
    _addBudgetActivity(
      BudgetActivity.updated(
        categoryName: category.name,
        oldAmount: category.budgetAmount,
        newAmount: newBudgetAmount,
      ),
    );
  }

  Future<void> removeBudgetCategory(String categoryName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Find the category to get the amount for activity
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

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('budgets')
        .doc(categoryName);
    await docRef.delete();

    // Add budget activity
    _addBudgetActivity(
      BudgetActivity.deleted(
        categoryName: categoryName,
        amount: category.budgetAmount,
      ),
    );
  }

  Future<void> resetBudgetSpending() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final batch = _firestore.batch();
    final budgetsRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('budgets');
    for (final category in _budgetCategories) {
      final docRef = budgetsRef.doc(category.name);
      // Use set with merge instead of update to handle non-existing documents
      batch.set(docRef, {'spentAmount': 0}, SetOptions(merge: true));
    }
    await batch.commit();

    // Add budget activity for month reset
    _addBudgetActivity(BudgetActivity.resetMonth());
  }

  Future<void> _updateBudgetSpending() async {
    // Prevent recursive calls
    if (_isUpdatingBudgetSpending) {
      debugPrint('Budget spending update skipped - already in progress');
      return;
    }

    debugPrint('Starting budget spending update...');

    try {
      _isUpdatingBudgetSpending = true;
      final user = _auth.currentUser;
      if (user == null) return;

      // Only update if we have budget categories
      if (_budgetCategories.isEmpty) {
        debugPrint('No budget categories to update');
        return;
      }

      final batch = _firestore.batch();
      final budgetsRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('budgets');

      int updatedCount = 0;
      for (final category in _budgetCategories) {
        final spent = _calculateCategorySpending(category.name);

        // Only update if spending amount has changed
        if (spent != category.spentAmount) {
          updatedCount++;
          final docRef = budgetsRef.doc(category.name);
          batch.set(docRef, {'spentAmount': spent}, SetOptions(merge: true));

          // Check for over budget after updating spent amount
          final updatedCategory = category.copyWith(spentAmount: spent);
          _checkOverBudgetAndCreateActivity(updatedCategory);
        }
      }

      if (updatedCount > 0) {
        await batch.commit();
        debugPrint('Budget spending updated for $updatedCount categories');
      } else {
        debugPrint('No budget spending changes detected');
      }
    } catch (e) {
      debugPrint('Error updating budget spending: $e');
      // Don't rethrow the error to prevent cascading failures
    } finally {
      _isUpdatingBudgetSpending = false;
      debugPrint('Budget spending update completed');
    }
  }

  // Force update all budget spending without checking for changes
  Future<void> _forceUpdateAllBudgetSpending() async {
    // Prevent recursive calls
    if (_isUpdatingBudgetSpending) {
      debugPrint('Force budget spending update skipped - already in progress');
      return;
    }

    debugPrint('Starting FORCE budget spending update...');

    try {
      _isUpdatingBudgetSpending = true;
      final user = _auth.currentUser;
      if (user == null) return;

      // Only update if we have budget categories
      if (_budgetCategories.isEmpty) {
        debugPrint('No budget categories to force update');
        return;
      }

      final batch = _firestore.batch();
      final budgetsRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('budgets');

      for (final category in _budgetCategories) {
        final spent = _calculateCategorySpending(category.name);
        final docRef = budgetsRef.doc(category.name);

        // Always update regardless of current value
        batch.set(docRef, {'spentAmount': spent}, SetOptions(merge: true));
        debugPrint(
          'Force updating ${category.name}: ${category.spentAmount} -> $spent',
        );

        // Check for over budget after updating spent amount
        final updatedCategory = category.copyWith(spentAmount: spent);
        _checkOverBudgetAndCreateActivity(updatedCategory);
      }

      await batch.commit();
      debugPrint(
        'Force budget spending update completed for ${_budgetCategories.length} categories',
      );
    } catch (e) {
      debugPrint('Error in force updating budget spending: $e');
      // Don't rethrow the error to prevent cascading failures
    } finally {
      _isUpdatingBudgetSpending = false;
    }
  }

  Future<void> _autoUpdateBudgetSpending(entity.Transaction transaction) async {
    if (transaction.type == entity.TransactionType.expense) {
      if (transaction.category != null) {
        // ignore: unused_local_variable
        final _ = transaction.getCategoryDisplayName();
      } else {
        // ignore: unused_local_variable
        final _ = _getCategoryFromDescription(transaction.description);
      }
      await _updateBudgetSpending();
    }
  }

  Future<void> autoCreateBudgetCategories() async {
    final recommendations = getBudgetRecommendations()
        .where((r) => r.type == RecommendationType.createBudget)
        .toList();
    final user = _auth.currentUser;
    if (user == null) return;
    final budgetsRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('budgets');
    final batch = _firestore.batch();

    // Keep track of created categories for activity logging
    final createdCategories = <BudgetCategory>[];

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

        createdCategories.add(newCategory);

        final iconName = iconMap.entries
            .firstWhere(
              (e) => e.value == newCategory.icon,
              orElse: () => const MapEntry('category', Icons.category),
            )
            .key;
        final docRef = budgetsRef.doc(newCategory.name);
        batch.set(docRef, {
          'name': newCategory.name,
          'budgetAmount': newCategory.budgetAmount,
          'spentAmount': newCategory.spentAmount,
          'colorValue': newCategory.color.value,
          'iconName': iconName,
        });
      }
    }
    await batch.commit();

    // Add activities for all created categories
    for (final category in createdCategories) {
      _addBudgetActivity(
        BudgetActivity.autoCreated(
          categoryName: category.name,
          amount: category.budgetAmount,
        ),
      );
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
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    debugPrint('=== Calculating spending for $categoryName ===');
    debugPrint('Current month: $currentMonth, Current year: $currentYear');
    debugPrint('Total transactions: ${_transactions.length}');

    // Filter transactions for current month and year, and expense type only
    final monthlyExpenses = _transactions
        .where(
          (transaction) =>
              transaction.type == entity.TransactionType.expense &&
              transaction.date.month == currentMonth &&
              transaction.date.year == currentYear,
        )
        .toList();

    debugPrint('Monthly expenses (${monthlyExpenses.length}):');
    for (var tx in monthlyExpenses) {
      debugPrint('  - ${tx.description}: ${tx.amount} (${tx.date})');
    }

    // Filter by category
    final categoryTransactions = monthlyExpenses.where((transaction) {
      final txCategoryName = transaction.category != null
          ? transaction.getCategoryDisplayName()
          : _getCategoryFromDescription(transaction.description);

      debugPrint(
        '  Transaction: ${transaction.description} -> Category: $txCategoryName',
      );
      return txCategoryName == categoryName;
    }).toList();

    final totalSpent = categoryTransactions.fold(
      0.0,
      (sum, transaction) => sum + transaction.amount,
    );

    debugPrint(
      'Found ${categoryTransactions.length} transactions for $categoryName this month',
    );
    debugPrint('Total spent: Rp${totalSpent.toStringAsFixed(0)}');
    debugPrint('===========================================');

    return totalSpent;
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

  // Refresh method to reload data with error handling
  Future<void> refresh() async {
    try {
      // Re-setup listeners to get fresh data from Firestore
      _listenToTransactions();
      _listenToBudgets();
      notifyListeners();
    } catch (e) {
      // Handle any errors during refresh
      debugPrint('Error during refresh: $e');
      // Still notify listeners to update UI
      notifyListeners();
    }
  }

  // Force update budget spending for debugging
  Future<void> forceUpdateBudgetSpending() async {
    debugPrint('=== FORCE UPDATE BUDGET SPENDING ===');
    debugPrint('Budget categories count: ${_budgetCategories.length}');
    debugPrint('Transactions count: ${_transactions.length}');

    for (var category in _budgetCategories) {
      debugPrint(
        'Category: ${category.name} - Current spent: ${category.spentAmount}',
      );
    }

    await _updateBudgetSpending();
  }

  @override
  void dispose() {
    _budgetSubscription?.cancel();
    super.dispose();
  }

  // You might want a method to clear the filter later
  // void clearFilter() {
  //   _selectedMonth = DateTime.now().month;
  //   _selectedYear = DateTime.now().year;
  //   notifyListeners();
  // }
}
