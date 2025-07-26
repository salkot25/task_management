import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Core imports
import '../../../../utils/app_colors.dart';
import '../../../../utils/design_system/app_components.dart';
import '../../../../utils/design_system/app_spacing.dart';
import '../../../../utils/design_system/app_typography.dart';

// Domain entities
import '../../domain/entities/transaction.dart' as entity;

class FinancialCharts extends StatelessWidget {
  final List<entity.Transaction> transactions;

  const FinancialCharts({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final lastIncome = _getLast30DaysIncome();
    final lastExpense = _getLast30DaysExpense();
    final prevIncome = _getPrevious30DaysIncome();
    final prevExpense = _getPrevious30DaysExpense();

    // Safe percentage calculation with proper division by zero handling
    final incomeChange = prevIncome > 0
        ? ((lastIncome - prevIncome) / prevIncome) * 100
        : (lastIncome > 0 ? 100.0 : 0.0);
    final expenseChange = prevExpense > 0
        ? ((lastExpense - prevExpense) / prevExpense) * 100
        : (lastExpense > 0 ? 100.0 : 0.0);

    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial Summary Cards
          Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Monthly Income',
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: '',
                      decimalDigits: 0,
                    ).format(lastIncome),
                    incomeChange,
                    Colors.green,
                    Icons.trending_up,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Monthly Expense',
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: '',
                      decimalDigits: 0,
                    ).format(lastExpense),
                    expenseChange,
                    Colors.red,
                    Icons.trending_down,
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar for Charts
          Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: isDarkMode
                  ? Colors.white70
                  : AppColors.greyColor,
              indicatorColor: AppColors.primaryColor,
              indicatorWeight: 3,
              labelStyle: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTypography.bodyMedium,
              tabs: const [
                Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
                Tab(icon: Icon(Icons.donut_large), text: 'Categories'),
                Tab(icon: Icon(Icons.compare_arrows), text: 'Comparison'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 380,
            child: TabBarView(
              children: [
                _buildEnhancedSpendingTrendsChart(context),
                _buildEnhancedCategoryChart(context),
                _buildEnhancedComparisonChart(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    double changePercentage,
    Color color,
    IconData icon,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2D2D2D)
            : Theme.of(context).cardColor,
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(
          color: isDarkMode
              ? Colors.grey.withOpacity(0.2)
              : AppColors.greyLightColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : AppColors.greyColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDarkMode ? Colors.white70 : AppColors.greyColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (changePercentage != 0.0) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  changePercentage > 0
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 14,
                  color: changePercentage > 0 ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${_formatPercentage(changePercentage.abs())}% vs last month',
                    style: AppTypography.bodySmall.copyWith(
                      color: changePercentage > 0 ? Colors.green : Colors.red,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Helper method to format percentage properly
  String _formatPercentage(double percentage) {
    if (percentage.isInfinite || percentage.isNaN) {
      return '∞';
    }

    if (percentage >= 1000000) {
      return '${(percentage / 1000000).toStringAsFixed(1)}M';
    } else if (percentage >= 1000) {
      return '${(percentage / 1000).toStringAsFixed(1)}K';
    } else if (percentage >= 100) {
      return percentage.toStringAsFixed(0);
    } else {
      return percentage.toStringAsFixed(1);
    }
  }

  // Helper method to format Indonesian currency
  String _formatIndonesianCurrency(double amount) {
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

  // Helper methods for financial calculations
  double _getLast30DaysIncome() {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    return transactions
        .where(
          (t) =>
              t.type == entity.TransactionType.income &&
              t.date.isAfter(thirtyDaysAgo),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _getLast30DaysExpense() {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    return transactions
        .where(
          (t) =>
              t.type == entity.TransactionType.expense &&
              t.date.isAfter(thirtyDaysAgo),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _getPrevious30DaysIncome() {
    final now = DateTime.now();
    final sixtyDaysAgo = now.subtract(const Duration(days: 60));
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final income = transactions
        .where(
          (t) =>
              t.type == entity.TransactionType.income &&
              t.date.isAfter(sixtyDaysAgo) &&
              t.date.isBefore(thirtyDaysAgo),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    return income; // Return actual value, handle division by zero in calculation
  }

  double _getPrevious30DaysExpense() {
    final now = DateTime.now();
    final sixtyDaysAgo = now.subtract(const Duration(days: 60));
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final expense = transactions
        .where(
          (t) =>
              t.type == entity.TransactionType.expense &&
              t.date.isAfter(sixtyDaysAgo) &&
              t.date.isBefore(thirtyDaysAgo),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    return expense; // Return actual value, handle division by zero in calculation
  }

  Map<String, double> _getCategoryDistribution() {
    final categoryMap = <String, double>{};

    for (final transaction in transactions) {
      if (transaction.type == entity.TransactionType.expense) {
        final categoryName = transaction.category != null
            ? _getCategoryDisplayNameFromExpenseType(transaction.category!)
            : 'Others';

        categoryMap[categoryName] =
            (categoryMap[categoryName] ?? 0) + transaction.amount;
      }
    }

    return categoryMap;
  }

  // Enhanced chart data methods
  LineChartData _buildEnhancedSpendingTrendsData(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 14));

    final dailyExpenses = <FlSpot>[];

    for (int i = 0; i < 14; i++) {
      final date = twoWeeksAgo.add(Duration(days: i));
      final dayExpenses = transactions
          .where(
            (t) =>
                t.type == entity.TransactionType.expense &&
                t.date.year == date.year &&
                t.date.month == date.month &&
                t.date.day == date.day,
          )
          .fold(0.0, (sum, t) => sum + t.amount);

      dailyExpenses.add(FlSpot(i.toDouble(), dayExpenses));
    }

    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) => Text(
              NumberFormat.compactCurrency(
                locale: 'id_ID',
                symbol: 'Rp',
              ).format(value),
              style: AppTypography.bodySmall.copyWith(
                fontSize: 10,
                color: isDarkMode ? Colors.white70 : null,
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final date = twoWeeksAgo.add(Duration(days: value.toInt()));
              return Text(
                '${date.day}/${date.month}',
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 10,
                  color: isDarkMode ? Colors.white70 : null,
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: dailyExpenses,
          isCurved: true,
          color: AppColors.primaryColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primaryColor.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  PieChartData _buildEnhancedCategoryPieData(Map<String, double> categoryData) {
    final colors = [
      AppColors.primaryColor,
      AppColors.secondaryColor,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];

    return PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      sections: categoryData.entries.map((entry) {
        final index = categoryData.keys.toList().indexOf(entry.key);
        final percentage =
            (entry.value / categoryData.values.reduce((a, b) => a + b)) * 100;

        return PieChartSectionData(
          color: colors[index % colors.length],
          value: entry.value,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: AppTypography.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEnhancedCategoryLegend(Map<String, double> categoryData) {
    final colors = [
      AppColors.primaryColor,
      AppColors.secondaryColor,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];

    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: categoryData.entries.map((entry) {
            final index = categoryData.keys.toList().indexOf(entry.key);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDarkMode ? Colors.white : null,
                      ),
                    ),
                  ),
                  Text(
                    _formatIndonesianCurrency(entry.value),
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : null,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  BarChartData _buildEnhancedWeeklyComparisonData(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    final weeklyData = <BarChartGroupData>[];

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dayIncome = transactions
          .where(
            (t) =>
                t.type == entity.TransactionType.income &&
                t.date.year == date.year &&
                t.date.month == date.month &&
                t.date.day == date.day,
          )
          .fold(0.0, (sum, t) => sum + t.amount);

      final dayExpense = transactions
          .where(
            (t) =>
                t.type == entity.TransactionType.expense &&
                t.date.year == date.year &&
                t.date.month == date.month &&
                t.date.day == date.day,
          )
          .fold(0.0, (sum, t) => sum + t.amount);

      weeklyData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dayIncome,
              color: Colors.green,
              width: 12,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: dayExpense,
              color: Colors.red,
              width: 12,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      groupsSpace: 20,
      barGroups: weeklyData,
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) => Text(
              NumberFormat.compactCurrency(
                locale: 'id_ID',
                symbol: 'Rp',
              ).format(value),
              style: AppTypography.bodySmall.copyWith(
                fontSize: 10,
                color: isDarkMode ? Colors.white70 : null,
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              return Text(
                days[value.toInt()],
                style: AppTypography.bodySmall.copyWith(
                  color: isDarkMode ? Colors.white70 : null,
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
    );
  }

  // Enhanced chart widgets
  Widget _buildEnhancedSpendingTrendsChart(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2D2D2D)
            : Theme.of(context).cardColor,
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(
          color: isDarkMode
              ? Colors.grey.withOpacity(0.2)
              : AppColors.greyLightColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : AppColors.greyColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Daily Spending Trends (Last 2 Weeks)',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: LineChart(_buildEnhancedSpendingTrendsData(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCategoryChart(BuildContext context) {
    final categoryData = _getCategoryDistribution();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2D2D2D)
            : Theme.of(context).cardColor,
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(
          color: isDarkMode
              ? Colors.grey.withOpacity(0.2)
              : AppColors.greyLightColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : AppColors.greyColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.donut_large, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Expense Distribution by Category',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (categoryData.isNotEmpty)
            Column(
              children: [
                Center(
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: PieChart(
                      _buildEnhancedCategoryPieData(categoryData),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildEnhancedCategoryLegend(categoryData),
              ],
            )
          else
            _buildNoCategoryDataWidget(),
        ],
      ),
    );
  }

  Widget _buildEnhancedComparisonChart(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2D2D2D)
            : Theme.of(context).cardColor,
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(
          color: isDarkMode
              ? Colors.grey.withOpacity(0.2)
              : AppColors.greyLightColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : AppColors.greyColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.compare_arrows,
                color: AppColors.primaryColor,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Daily Income vs Expense (This Week)',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: BarChart(_buildEnhancedWeeklyComparisonData(context)),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildWeeklyOverviewLegend(),
        ],
      ),
    );
  }

  Widget _buildNoCategoryDataWidget() {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Container(
          height: 140,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 48,
                color: isDarkMode
                    ? Colors.white30
                    : AppColors.greyColor.withOpacity(0.5),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No expense categories yet',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDarkMode ? Colors.white70 : AppColors.greyColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyOverviewLegend() {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Income',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : null,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Expense',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : null,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _getCategoryDisplayNameFromExpenseType(
    entity.ExpenseCategory category,
  ) {
    switch (category) {
      case entity.ExpenseCategory.food:
        return 'Food & Dining';
      case entity.ExpenseCategory.transport:
        return 'Transportation';
      case entity.ExpenseCategory.shopping:
        return 'Shopping';
      case entity.ExpenseCategory.health:
        return 'Health & Medical';
      case entity.ExpenseCategory.entertainment:
        return 'Entertainment';
      case entity.ExpenseCategory.utilities:
        return 'Bills & Utilities';
      case entity.ExpenseCategory.education:
        return 'Education';
      case entity.ExpenseCategory.rewardP2TL:
        return 'Reward P2TL';
      default:
        return 'Others';
    }
  }
}
