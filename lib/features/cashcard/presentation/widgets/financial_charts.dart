import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:myapp/features/cashcard/domain/entities/transaction.dart';
import 'package:myapp/utils/design_system/app_colors.dart';
import 'package:myapp/utils/design_system/app_spacing.dart';
import 'package:myapp/utils/design_system/app_typography.dart';
import 'package:myapp/utils/design_system/app_components.dart';

class FinancialCharts extends StatelessWidget {
  final List<Transaction> transactions;
  final double totalIncome;
  final double totalExpense;

  const FinancialCharts({
    super.key,
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Spending Trends Chart
        _buildSpendingTrendsChart(context),
        const SizedBox(height: AppSpacing.lg),

        // Income vs Expense Chart
        _buildIncomeExpenseChart(context),
        const SizedBox(height: AppSpacing.lg),

        // Category Distribution Chart
        _buildCategoryDistributionChart(context),
        const SizedBox(height: AppSpacing.lg),

        // Weekly Overview Chart
        _buildWeeklyOverviewChart(context),
      ],
    );
  }

  Widget _buildSpendingTrendsChart(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(color: AppColors.greyLightColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor.withOpacity(0.1),
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
                'Spending Trends (Last 7 Days)',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(height: 200, child: LineChart(_buildSpendingTrendsData())),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseChart(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(color: AppColors.greyLightColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor.withOpacity(0.1),
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
                'Income vs Expense',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(height: 200, child: BarChart(_buildIncomeExpenseData())),
          const SizedBox(height: AppSpacing.md),
          _buildIncomeExpenseLegend(),
        ],
      ),
    );
  }

  Widget _buildCategoryDistributionChart(BuildContext context) {
    final categoryData = _getCategoryDistribution();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(color: AppColors.greyLightColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor.withOpacity(0.1),
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
              Icon(Icons.pie_chart, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Expense by Category',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: PieChart(_buildCategoryPieData(categoryData)),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: _buildCategoryLegend(categoryData)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyOverviewChart(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(color: AppColors.greyLightColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor.withOpacity(0.1),
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
                Icons.calendar_view_week,
                color: AppColors.primaryColor,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Weekly Overview',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(height: 200, child: BarChart(_buildWeeklyOverviewData())),
        ],
      ),
    );
  }

  LineChartData _buildSpendingTrendsData() {
    final last7Days = _getLast7DaysData();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 50000,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.greyLightColor,
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              return Text(
                '${(value / 1000).toInt()}K',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.greyColor,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              final index = value.toInt();
              if (index >= 0 && index < days.length) {
                return Text(
                  days[index],
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.greyColor,
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: last7Days,
          isCurved: true,
          color: AppColors.primaryColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppColors.primaryColor,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primaryColor.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  BarChartData _buildIncomeExpenseData() {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: [totalIncome, totalExpense].reduce((a, b) => a > b ? a : b) * 1.2,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final value = NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(rod.toY);
            return BarTooltipItem(
              value,
              AppTypography.bodySmall.copyWith(color: Colors.white),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              return Text(
                '${(value / 1000000).toStringAsFixed(1)}M',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.greyColor,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              switch (value.toInt()) {
                case 0:
                  return Text(
                    'Income',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.greyColor,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                case 1:
                  return Text(
                    'Expense',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.greyColor,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                default:
                  return const Text('');
              }
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: totalIncome > 0 ? totalIncome / 5 : 100000,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.greyLightColor,
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      borderData: FlBorderData(show: false),
      barGroups: [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              toY: totalIncome,
              color: AppColors.successColor,
              width: 40,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(
              toY: totalExpense,
              color: AppColors.errorColor,
              width: 40,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  PieChartData _buildCategoryPieData(Map<String, double> categoryData) {
    final colors = [
      AppColors.primaryColor,
      AppColors.successColor,
      AppColors.warningColor,
      AppColors.errorColor,
      AppColors.infoColor,
    ];

    int index = 0;
    return PieChartData(
      pieTouchData: PieTouchData(
        touchCallback: (FlTouchEvent event, pieTouchResponse) {},
      ),
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      sections: categoryData.entries.map((entry) {
        final color = colors[index % colors.length];
        index++;

        final percentage = (entry.value / totalExpense) * 100;
        return PieChartSectionData(
          color: color,
          value: entry.value,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 50,
          titleStyle: AppTypography.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      }).toList(),
    );
  }

  BarChartData _buildWeeklyOverviewData() {
    final weeklyData = _getWeeklyData();

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: weeklyData.reduce((a, b) => a > b ? a : b) * 1.2,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final value = NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(rod.toY);
            return BarTooltipItem(
              value,
              AppTypography.bodySmall.copyWith(color: Colors.white),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              return Text(
                '${(value / 1000).toInt()}K',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.greyColor,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              final index = value.toInt();
              if (index >= 0 && index < days.length) {
                return Text(
                  days[index],
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.greyColor,
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.greyLightColor,
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(7, (index) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: weeklyData[index],
              color: AppColors.primaryColor,
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildIncomeExpenseLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Income', AppColors.successColor),
        const SizedBox(width: AppSpacing.lg),
        _buildLegendItem('Expense', AppColors.errorColor),
      ],
    );
  }

  Widget _buildCategoryLegend(Map<String, double> categoryData) {
    final colors = [
      AppColors.primaryColor,
      AppColors.successColor,
      AppColors.warningColor,
      AppColors.errorColor,
      AppColors.infoColor,
    ];

    int index = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categoryData.entries.map((entry) {
        final color = colors[index % colors.length];
        index++;

        final percentage = (entry.value / totalExpense) * 100;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '${entry.key} (${percentage.toStringAsFixed(1)}%)',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.greyColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: AppColors.greyColor),
        ),
      ],
    );
  }

  List<FlSpot> _getLast7DaysData() {
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) {
      return DateTime(now.year, now.month, now.day - (6 - index));
    });

    return last7Days.asMap().entries.map((entry) {
      final day = entry.value;
      final dayTransactions = transactions
          .where(
            (t) =>
                t.date.year == day.year &&
                t.date.month == day.month &&
                t.date.day == day.day &&
                t.type == TransactionType.expense,
          )
          .toList();

      final totalForDay = dayTransactions.fold(0.0, (sum, t) => sum + t.amount);
      return FlSpot(entry.key.toDouble(), totalForDay);
    }).toList();
  }

  List<double> _getWeeklyData() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      final day = startOfWeek.add(Duration(days: index));
      final dayTransactions = transactions
          .where(
            (t) =>
                t.date.year == day.year &&
                t.date.month == day.month &&
                t.date.day == day.day &&
                t.type == TransactionType.expense,
          )
          .toList();

      return dayTransactions.fold(0.0, (sum, t) => sum + t.amount);
    });
  }

  Map<String, double> _getCategoryDistribution() {
    final categoryMap = <String, double>{};

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        final category = _getCategoryFromDescription(transaction.description);
        categoryMap[category] =
            (categoryMap[category] ?? 0) + transaction.amount;
      }
    }

    // Sort by amount and take top 5
    final sortedEntries = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final result = <String, double>{};
    for (int i = 0; i < sortedEntries.length && i < 5; i++) {
      result[sortedEntries[i].key] = sortedEntries[i].value;
    }

    return result;
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
}
