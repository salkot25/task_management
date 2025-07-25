import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/utils/design_system/app_colors.dart';
import 'package:myapp/utils/design_system/app_spacing.dart';
import 'package:myapp/utils/design_system/app_typography.dart';
import 'package:myapp/utils/design_system/app_components.dart';

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
  double get progressPercentage => spentAmount / budgetAmount;
  bool get isOverBudget => spentAmount > budgetAmount;
}

class BudgetManagement extends StatefulWidget {
  final List<BudgetCategory> categories;
  final Function(BudgetCategory) onAddCategory;
  final Function(BudgetCategory, double) onUpdateBudget;

  const BudgetManagement({
    super.key,
    required this.categories,
    required this.onAddCategory,
    required this.onUpdateBudget,
  });

  @override
  State<BudgetManagement> createState() => _BudgetManagementState();
}

class _BudgetManagementState extends State<BudgetManagement> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final totalBudget = widget.categories.fold(
      0.0,
      (sum, cat) => sum + cat.budgetAmount,
    );
    final totalSpent = widget.categories.fold(
      0.0,
      (sum, cat) => sum + cat.spentAmount,
    );
    final overallProgress = totalBudget > 0 ? totalSpent / totalBudget : 0.0;

    return Column(
      children: [
        // Overall Budget Overview
        _buildOverallBudgetCard(totalBudget, totalSpent, overallProgress),
        const SizedBox(height: AppSpacing.lg),

        // Budget Categories List
        _buildBudgetCategoriesList(),
        const SizedBox(height: AppSpacing.lg),

        // Add Budget Category Button
        _buildAddBudgetButton(),
        const SizedBox(height: AppSpacing.lg),

        // Budget Tips
        _buildBudgetTips(),
      ],
    );
  }

  Widget _buildOverallBudgetCard(
    double totalBudget,
    double totalSpent,
    double progress,
  ) {
    final remaining = totalBudget - totalSpent;
    final isOverBudget = totalSpent > totalBudget;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: AppComponents.standardBorderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Monthly Budget Overview',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Budget amounts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Budget',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(totalBudget),
                    style: AppTypography.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isOverBudget ? 'Over Budget' : 'Remaining',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(remaining.abs()),
                    style: AppTypography.titleMedium.copyWith(
                      color: isOverBudget
                          ? AppColors.warningColor
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Spent: ${(progress * 100).toStringAsFixed(1)}%',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(totalSpent),
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (progress > 1.0 ? 1.0 : progress),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isOverBudget ? AppColors.errorColor : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCategoriesList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(color: AppColors.greyLightColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(Icons.category, color: AppColors.primaryColor, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Budget Categories',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (widget.categories.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 48,
                      color: AppColors.greyColor,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'No budget categories yet',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.greyColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Add your first budget category below',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...widget.categories.map(
              (category) => _buildBudgetCategoryCard(category),
            ),
        ],
      ),
    );
  }

  Widget _buildBudgetCategoryCard(BudgetCategory category) {
    return Container(
      margin: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppComponents.smallRadius),
        border: Border.all(color: category.color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(category.icon, color: category.color, size: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  category.name,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (category.isOverBudget)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Over Budget',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(Icons.edit, size: 16, color: AppColors.greyColor),
                onPressed: () => _showEditBudgetDialog(category),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(category.spentAmount)}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.greyColor,
                ),
              ),
              Text(
                'Budget: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(category.budgetAmount)}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.greyColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          // Progress bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.greyExtraLightColor,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: category.progressPercentage > 1.0
                  ? 1.0
                  : category.progressPercentage,
              child: Container(
                decoration: BoxDecoration(
                  color: category.isOverBudget
                      ? AppColors.errorColor
                      : category.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(category.progressPercentage * 100).toStringAsFixed(1)}% used',
                style: AppTypography.bodySmall.copyWith(
                  color: category.isOverBudget
                      ? AppColors.errorColor
                      : AppColors.greyColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                category.isOverBudget
                    ? 'Over by ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(-category.remainingAmount)}'
                    : '${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(category.remainingAmount)} left',
                style: AppTypography.bodySmall.copyWith(
                  color: category.isOverBudget
                      ? AppColors.errorColor
                      : AppColors.successColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddBudgetButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ElevatedButton.icon(
        onPressed: _showAddBudgetDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Budget Category'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppComponents.standardBorderRadius,
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetTips() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.infoColor.withOpacity(0.1),
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(
          color: AppColors.infoColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.infoColor, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Budget Tips',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.infoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildTipItem(
            'Follow the 50/30/20 rule: 50% needs, 30% wants, 20% savings',
          ),
          _buildTipItem('Review and adjust your budget monthly'),
          _buildTipItem('Track your spending regularly to stay on target'),
          _buildTipItem('Set realistic budget limits based on your income'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.infoColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              tip,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.greyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetDialog() {
    _categoryController.clear();
    _budgetController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Budget Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g., Food, Transport, Entertainment',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _budgetController,
              decoration: const InputDecoration(
                labelText: 'Budget Amount',
                hintText: 'e.g., 1000000',
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addBudgetCategory,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(BudgetCategory category) {
    _budgetController.text = category.budgetAmount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${category.name} Budget'),
        content: TextField(
          controller: _budgetController,
          decoration: const InputDecoration(
            labelText: 'Budget Amount',
            prefixText: 'Rp ',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _updateBudgetCategory(category),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _addBudgetCategory() {
    if (_categoryController.text.isNotEmpty &&
        _budgetController.text.isNotEmpty) {
      final budgetAmount = double.tryParse(_budgetController.text);
      if (budgetAmount != null && budgetAmount > 0) {
        final newCategory = BudgetCategory(
          name: _categoryController.text,
          budgetAmount: budgetAmount,
          spentAmount: 0,
          color: _getCategoryColor(_categoryController.text),
          icon: _getCategoryIcon(_categoryController.text),
        );

        widget.onAddCategory(newCategory);
        Navigator.pop(context);
      }
    }
  }

  void _updateBudgetCategory(BudgetCategory category) {
    final budgetAmount = double.tryParse(_budgetController.text);
    if (budgetAmount != null && budgetAmount > 0) {
      widget.onUpdateBudget(category, budgetAmount);
      Navigator.pop(context);
    }
  }

  Color _getCategoryColor(String categoryName) {
    final colors = [
      AppColors.primaryColor,
      AppColors.successColor,
      AppColors.warningColor,
      AppColors.errorColor,
      AppColors.infoColor,
    ];
    return colors[categoryName.hashCode % colors.length];
  }

  IconData _getCategoryIcon(String categoryName) {
    final lowerName = categoryName.toLowerCase();

    if (lowerName.contains('food') || lowerName.contains('makan')) {
      return Icons.restaurant;
    } else if (lowerName.contains('transport') ||
        lowerName.contains('travel')) {
      return Icons.directions_car;
    } else if (lowerName.contains('entertainment') ||
        lowerName.contains('hiburan')) {
      return Icons.movie;
    } else if (lowerName.contains('health') || lowerName.contains('medical')) {
      return Icons.local_hospital;
    } else if (lowerName.contains('shopping') ||
        lowerName.contains('belanja')) {
      return Icons.shopping_bag;
    } else if (lowerName.contains('utility') || lowerName.contains('bill')) {
      return Icons.receipt;
    } else {
      return Icons.category;
    }
  }
}
