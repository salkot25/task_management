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
    // Only allow constant icons for tree shaking
    IconData icon = Icons.category;
    // Optionally, you can map string/icon name to a constant icon here if needed
    // Example: if (map['iconName'] == 'food') icon = Icons.fastfood;

    return BudgetCategory(
      name: map['name'] ?? '',
      budgetAmount: (map['budgetAmount'] ?? 0).toDouble(),
      spentAmount: (map['spentAmount'] ?? 0).toDouble(),
      color: Color(map['colorValue'] ?? Colors.grey.value),
      icon: icon,
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

// Budget Activity model for tracking budget changes
enum BudgetActivityType {
  created,
  updated,
  deleted,
  overBudget,
  resetMonth,
  autoCreated,
}

class BudgetActivity {
  final String id;
  final String categoryName;
  final BudgetActivityType type;
  final String description;
  final DateTime timestamp;
  final double? oldAmount;
  final double? newAmount;
  final IconData icon;
  final Color color;

  BudgetActivity({
    required this.id,
    required this.categoryName,
    required this.type,
    required this.description,
    required this.timestamp,
    this.oldAmount,
    this.newAmount,
    required this.icon,
    required this.color,
  });

  // Create activity for budget creation
  factory BudgetActivity.created({
    required String categoryName,
    required double amount,
  }) {
    return BudgetActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categoryName: categoryName,
      type: BudgetActivityType.created,
      description: 'New budget of ${_formatCurrency(amount)} created',
      timestamp: DateTime.now(),
      newAmount: amount,
      icon: Icons.add_circle,
      color: Colors.green,
    );
  }

  // Create activity for budget update
  factory BudgetActivity.updated({
    required String categoryName,
    required double oldAmount,
    required double newAmount,
  }) {
    return BudgetActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categoryName: categoryName,
      type: BudgetActivityType.updated,
      description:
          'Budget updated from ${_formatCurrency(oldAmount)} to ${_formatCurrency(newAmount)}',
      timestamp: DateTime.now(),
      oldAmount: oldAmount,
      newAmount: newAmount,
      icon: Icons.edit,
      color: Colors.blue,
    );
  }

  // Create activity for budget deletion
  factory BudgetActivity.deleted({
    required String categoryName,
    required double amount,
  }) {
    return BudgetActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categoryName: categoryName,
      type: BudgetActivityType.deleted,
      description: 'Budget of ${_formatCurrency(amount)} deleted',
      timestamp: DateTime.now(),
      oldAmount: amount,
      icon: Icons.delete,
      color: Colors.red,
    );
  }

  // Create activity for over budget alert
  factory BudgetActivity.overBudget({
    required String categoryName,
    required double exceededAmount,
  }) {
    return BudgetActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categoryName: categoryName,
      type: BudgetActivityType.overBudget,
      description: 'Exceeded budget by ${_formatCurrency(exceededAmount)}',
      timestamp: DateTime.now(),
      newAmount: exceededAmount,
      icon: Icons.warning,
      color: Colors.orange,
    );
  }

  // Create activity for month reset
  factory BudgetActivity.resetMonth() {
    return BudgetActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categoryName: 'All Categories',
      type: BudgetActivityType.resetMonth,
      description: 'Budget month reset - all spending amounts cleared',
      timestamp: DateTime.now(),
      icon: Icons.refresh,
      color: Colors.purple,
    );
  }

  // Create activity for auto creation
  factory BudgetActivity.autoCreated({
    required String categoryName,
    required double amount,
  }) {
    return BudgetActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categoryName: categoryName,
      type: BudgetActivityType.autoCreated,
      description: 'Auto-created budget of ${_formatCurrency(amount)}',
      timestamp: DateTime.now(),
      newAmount: amount,
      icon: Icons.auto_fix_high,
      color: Colors.teal,
    );
  }

  // Helper method to format currency
  static String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      final millions = amount / 1000000;
      if (millions == millions.truncate()) {
        return 'Rp${millions.truncate()} jt';
      } else {
        return 'Rp${millions.toStringAsFixed(1)} jt';
      }
    } else if (amount >= 1000) {
      final thousands = amount / 1000;
      if (thousands == thousands.truncate()) {
        return 'Rp${thousands.truncate()} rb';
      } else {
        return 'Rp${thousands.toStringAsFixed(0)} rb';
      }
    } else {
      return 'Rp${amount.toStringAsFixed(0)}';
    }
  }

  // Get relative time description
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryName': categoryName,
      'type': type.name,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'oldAmount': oldAmount,
      'newAmount': newAmount,
      'iconCodePoint': icon.codePoint,
      'colorValue': color.value,
    };
  }

  // Create from map
  factory BudgetActivity.fromMap(Map<String, dynamic> map) {
    return BudgetActivity(
      id: map['id'] ?? '',
      categoryName: map['categoryName'] ?? '',
      type: BudgetActivityType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => BudgetActivityType.created,
      ),
      description: map['description'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      oldAmount: map['oldAmount']?.toDouble(),
      newAmount: map['newAmount']?.toDouble(),
      icon: IconData(
        map['iconCodePoint'] ?? Icons.info.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      color: Color(map['colorValue'] ?? Colors.blue.value),
    );
  }
}
