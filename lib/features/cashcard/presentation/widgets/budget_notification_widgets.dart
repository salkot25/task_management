import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clarity/features/cashcard/presentation/provider/cashcard_provider.dart';
import 'package:clarity/utils/design_system/app_colors.dart';
import 'package:clarity/utils/design_system/app_spacing.dart';
import 'package:clarity/utils/design_system/app_typography.dart';
import 'package:clarity/utils/design_system/app_components.dart';

class BudgetNotificationWidget extends StatelessWidget {
  const BudgetNotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CashcardProvider>(
      builder: (context, provider, child) {
        final alerts = provider.getBudgetAlerts();

        if (alerts.isEmpty) {
          return const SizedBox.shrink();
        }

        // Show only the most critical alert
        final criticalAlert = alerts.first;

        return Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: criticalAlert.alertColor.withValues(alpha: 0.1),
            borderRadius: AppComponents.standardBorderRadius,
            border: Border.all(
              color: criticalAlert.alertColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                criticalAlert.alertIcon,
                color: criticalAlert.alertColor,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget Alert',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: criticalAlert.alertColor,
                      ),
                    ),
                    Text(
                      criticalAlert.message,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              if (alerts.length > 1)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: criticalAlert.alertColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+${alerts.length - 1}',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class BudgetInsightsWidget extends StatelessWidget {
  const BudgetInsightsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CashcardProvider>(
      builder: (context, provider, child) {
        final categories = provider.budgetCategories;

        if (categories.isEmpty) {
          return _buildEmptyBudgetState();
        }

        final totalBudget = categories.fold(
          0.0,
          (sum, cat) => sum + cat.budgetAmount,
        );
        final totalSpent = categories.fold(
          0.0,
          (sum, cat) => sum + cat.spentAmount,
        );
        final overBudgetCount = categories.where((c) => c.isOverBudget).length;

        return Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppComponents.standardBorderRadius,
            border: Border.all(color: AppColors.greyLightColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.insights, color: AppColors.primaryColor, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Budget Insights',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Insights Grid
              Row(
                children: [
                  Expanded(
                    child: _buildInsightMetric(
                      'Total Budget',
                      'Rp ${_formatNumber(totalBudget)}',
                      AppColors.primaryColor,
                      Icons.account_balance_wallet,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildInsightMetric(
                      'Spent',
                      'Rp ${_formatNumber(totalSpent)}',
                      totalSpent > totalBudget
                          ? AppColors.errorColor
                          : AppColors.successColor,
                      Icons.trending_down,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              Row(
                children: [
                  Expanded(
                    child: _buildInsightMetric(
                      'Remaining',
                      'Rp ${_formatNumber(totalBudget - totalSpent)}',
                      totalBudget - totalSpent > 0
                          ? AppColors.successColor
                          : AppColors.errorColor,
                      Icons.savings,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildInsightMetric(
                      'Over Budget',
                      '$overBudgetCount categories',
                      overBudgetCount > 0
                          ? AppColors.errorColor
                          : AppColors.successColor,
                      Icons.warning,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyBudgetState() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.greyExtraLightColor,
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(color: AppColors.greyLightColor, width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: AppColors.greyColor,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No Budget Set',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.greyColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create budget categories to track your spending',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.greyColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightMetric(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppComponents.smallRadius),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }
}

// Widget untuk menampilkan progress budget dalam transaction list
class BudgetProgressIndicator extends StatelessWidget {
  final String categoryName;

  const BudgetProgressIndicator({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Consumer<CashcardProvider>(
      builder: (context, provider, child) {
        final budgetStatus = provider.getBudgetStatus(categoryName);

        if (budgetStatus.budgetAmount == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(top: AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.greyExtraLightColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: budgetStatus.progressPercentage > 1.0
                        ? 1.0
                        : budgetStatus.progressPercentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: budgetStatus.isOverBudget
                            ? AppColors.errorColor
                            : AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${(budgetStatus.progressPercentage * 100).toStringAsFixed(0)}%',
                style: AppTypography.bodySmall.copyWith(
                  color: budgetStatus.isOverBudget
                      ? AppColors.errorColor
                      : AppColors.greyColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
