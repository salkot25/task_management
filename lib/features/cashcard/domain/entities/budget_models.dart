import 'package:flutter/material.dart';

// Enhanced Budget Category model
class BudgetCategory {
  final String name;
  final double budgetAmount;
  final double spentAmount;
  final Color color;
  final IconData icon;

  BudgetCategory({
    required this.name,
    required this.budgetAmount,
    required this.spentAmount,
    required this.color,
    required this.icon,
  });

  double get remainingAmount => budgetAmount - spentAmount;
  double get progressPercentage =>
      budgetAmount > 0 ? spentAmount / budgetAmount : 0.0;
  bool get isOverBudget => spentAmount > budgetAmount;

  // Create a copy with updated values
  BudgetCategory copyWith({
    String? name,
    double? budgetAmount,
    double? spentAmount,
    Color? color,
    IconData? icon,
  }) {
    return BudgetCategory(
      name: name ?? this.name,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'budgetAmount': budgetAmount,
      'spentAmount': spentAmount,
      'colorValue': color.value,
      'iconCodePoint': icon.codePoint,
    };
  }

  // Create from map
  factory BudgetCategory.fromMap(Map<String, dynamic> map) {
    return BudgetCategory(
      name: map['name'] ?? '',
      budgetAmount: (map['budgetAmount'] ?? 0).toDouble(),
      spentAmount: (map['spentAmount'] ?? 0).toDouble(),
      color: Color(map['colorValue'] ?? Colors.grey.value),
      icon: IconData(
        map['iconCodePoint'] ?? Icons.category.codePoint,
        fontFamily: 'MaterialIcons',
      ),
    );
  }
}

// Budget Status for specific category
class BudgetStatus {
  final String categoryName;
  final double budgetAmount;
  final double spentAmount;
  final double remainingAmount;
  final double progressPercentage;
  final bool isOverBudget;

  BudgetStatus({
    required this.categoryName,
    required this.budgetAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.progressPercentage,
    required this.isOverBudget,
  });
}

// Budget Recommendation types
enum RecommendationType {
  createBudget,
  increaseBudget,
  decreaseBudget,
  optimizeBudget,
}

// Budget Recommendation model
class BudgetRecommendation {
  final RecommendationType type;
  final String categoryName;
  final double currentAmount;
  final double recommendedAmount;
  final String reason;

  BudgetRecommendation({
    required this.type,
    required this.categoryName,
    required this.currentAmount,
    required this.recommendedAmount,
    required this.reason,
  });
}

// Alert types for budget notifications
enum AlertType { overBudget, approaching, underBudget, goalAchieved }

// Budget Alert model
class BudgetAlert {
  final AlertType type;
  final String categoryName;
  final double amount;
  final String message;
  final DateTime timestamp;

  BudgetAlert({
    required this.type,
    required this.categoryName,
    required this.amount,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Get alert color based on type
  Color get alertColor {
    switch (type) {
      case AlertType.overBudget:
        return Colors.red;
      case AlertType.approaching:
        return Colors.orange;
      case AlertType.underBudget:
        return Colors.blue;
      case AlertType.goalAchieved:
        return Colors.green;
    }
  }

  // Get alert icon based on type
  IconData get alertIcon {
    switch (type) {
      case AlertType.overBudget:
        return Icons.warning;
      case AlertType.approaching:
        return Icons.warning_amber;
      case AlertType.underBudget:
        return Icons.info;
      case AlertType.goalAchieved:
        return Icons.check_circle;
    }
  }
}

// Budget Insights model
class BudgetInsights {
  final double totalBudget;
  final double totalSpent;
  final double totalRemaining;
  final double averageDailySpending;
  final int daysInMonth;
  final int overBudgetCategories;
  final String topSpendingCategory;
  final double topSpendingAmount;
  final double savingsRate;

  BudgetInsights({
    required this.totalBudget,
    required this.totalSpent,
    required this.totalRemaining,
    required this.averageDailySpending,
    required this.daysInMonth,
    required this.overBudgetCategories,
    required this.topSpendingCategory,
    required this.topSpendingAmount,
    required this.savingsRate,
  });

  // Calculate projected spending
  double get projectedMonthlySpending => averageDailySpending * daysInMonth;

  // Check if on track
  bool get isOnTrack => projectedMonthlySpending <= totalBudget;

  // Calculate budget health score (0-100)
  double get healthScore {
    if (totalBudget == 0) return 0;

    double score = 100;

    // Deduct points for over budget
    if (totalSpent > totalBudget) {
      score -= ((totalSpent - totalBudget) / totalBudget * 50).clamp(0, 50);
    }

    // Deduct points for multiple over budget categories
    score -= (overBudgetCategories * 10).clamp(0, 30);

    // Add points for staying within budget
    if (totalSpent <= totalBudget * 0.9) {
      score += 10;
    }

    return score.clamp(0, 100);
  }
}

// Spending Pattern Analysis
class SpendingPattern {
  final String categoryName;
  final List<double> monthlySpending;
  final double averageSpending;
  final double trend; // positive = increasing, negative = decreasing
  final String trendDescription;

  SpendingPattern({
    required this.categoryName,
    required this.monthlySpending,
    required this.averageSpending,
    required this.trend,
    required this.trendDescription,
  });
}
