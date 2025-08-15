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
  final bool isAllTime;
  final String? selectedPeriod;

  const FinancialCharts({
    super.key,
    required this.transactions,
    this.isAllTime = false,
    this.selectedPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Calculate current period income and expense from filtered transactions
    final currentIncome = transactions
        .where((t) => t.type == entity.TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final currentExpense = transactions
        .where((t) => t.type == entity.TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    // Determine appropriate labels based on context
    final incomeLabel = isAllTime
        ? 'Total Income (All Time)'
        : selectedPeriod != null
        ? 'Income ($selectedPeriod)'
        : 'Current Period Income';
    final expenseLabel = isAllTime
        ? 'Total Expense (All Time)'
        : selectedPeriod != null
        ? 'Expense ($selectedPeriod)'
        : 'Current Period Expense';
    // Calculate previous period for comparison (only if not all time)
    final Map<String, double> prevPeriodData = isAllTime
        ? {'income': 0.0, 'expense': 0.0}
        : _getPreviousPeriodData();
    final prevIncome = prevPeriodData['income']!;
    final prevExpense = prevPeriodData['expense']!;

    // Safe percentage calculation with proper division by zero handling
    // Don't show percentage for all time since there's no meaningful comparison
    final incomeChange = isAllTime
        ? 0.0
        : (prevIncome > 0
              ? ((currentIncome - prevIncome) / prevIncome) * 100
              : (currentIncome > 0 ? 100.0 : 0.0));
    final expenseChange = isAllTime
        ? 0.0
        : (prevExpense > 0
              ? ((currentExpense - prevExpense) / prevExpense) * 100
              : (currentExpense > 0 ? 100.0 : 0.0));

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
                    incomeLabel,
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: '',
                      decimalDigits: 0,
                    ).format(currentIncome),
                    incomeChange,
                    Colors.green,
                    Icons.trending_up,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    expenseLabel,
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: '',
                      decimalDigits: 0,
                    ).format(currentExpense),
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
              color: isDarkMode
                  ? const Color(0xFF2D2D2D)
                  : Colors.white, // Gunakan putih murni untuk tab bar
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha: 0.4)
                      : Colors.black.withValues(
                          alpha: 0.08,
                        ), // Shadow lebih gelap untuk tab bar
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: -1,
                ),
              ],
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

    // Generate dynamic comparison label
    String comparisonLabel = 'vs last month';
    if (!isAllTime && selectedPeriod != null) {
      final parts = selectedPeriod!.split(' ');
      if (parts.length == 2) {
        // Support both English and Indonesian month names
        final monthNamesEnglish = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];
        final monthNamesIndonesian = [
          'Januari',
          'Februari',
          'Maret',
          'April',
          'Mei',
          'Juni',
          'Juli',
          'Agustus',
          'September',
          'Oktober',
          'November',
          'Desember',
        ];

        int monthIndex = monthNamesEnglish.indexOf(parts[0]);
        if (monthIndex == -1) {
          monthIndex = monthNamesIndonesian.indexOf(parts[0]);
        }

        final year = int.tryParse(parts[1]);
        if (monthIndex != -1 && year != null) {
          final targetMonth = monthIndex + 1;
          final previousMonth = targetMonth == 1 ? 12 : targetMonth - 1;
          final previousYear = targetMonth == 1 ? year - 1 : year;

          // Use the same language as selected period
          final isIndonesian = monthNamesIndonesian.contains(parts[0]);
          final previousMonthName = isIndonesian
              ? monthNamesIndonesian[previousMonth - 1]
              : monthNamesEnglish[previousMonth - 1];

          comparisonLabel = 'vs $previousMonthName $previousYear';
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2D2D2D)
            : Colors.white, // Gunakan putih murni untuk summary card
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(
          color: isDarkMode
              ? Colors.grey.withValues(alpha: 0.2)
              : AppColors.greyLightColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(
                    alpha: 0.1,
                  ), // Shadow lebih gelap untuk summary card
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -1,
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
                    '${_formatPercentage(changePercentage.abs())}% $comparisonLabel',
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

  // Helper method to format Indonesian currency for charts
  String _formatIndonesianCurrencyForChart(double amount) {
    if (amount.abs() >= 1000000000) {
      final billions = amount / 1000000000;
      return 'Rp${billions.toStringAsFixed(1)}B';
    } else if (amount.abs() >= 1000000) {
      final millions = amount / 1000000;
      return 'Rp${millions.toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      final thousands = amount / 1000;
      return 'Rp${thousands.toStringAsFixed(0)}K';
    } else {
      return 'Rp${amount.toStringAsFixed(0)}';
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

  // Helper method to get previous period data for comparison
  Map<String, double> _getPreviousPeriodData() {
    if (!isAllTime && selectedPeriod != null) {
      // Parse selected period to get previous month/year
      final parts = selectedPeriod!.split(' ');
      if (parts.length == 2) {
        // Support both English and Indonesian month names
        final monthNamesEnglish = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];
        final monthNamesIndonesian = [
          'Januari',
          'Februari',
          'Maret',
          'April',
          'Mei',
          'Juni',
          'Juli',
          'Agustus',
          'September',
          'Oktober',
          'November',
          'Desember',
        ];

        int monthIndex = monthNamesEnglish.indexOf(parts[0]);
        if (monthIndex == -1) {
          monthIndex = monthNamesIndonesian.indexOf(parts[0]);
        }

        final year = int.tryParse(parts[1]);

        if (monthIndex != -1 && year != null) {
          final targetMonth = monthIndex + 1;

          // Calculate previous month
          final previousMonth = targetMonth == 1 ? 12 : targetMonth - 1;
          final previousYear = targetMonth == 1 ? year - 1 : year;

          print(
            'Previous Period Debug: Selected=$selectedPeriod -> Previous=${monthNamesEnglish[previousMonth - 1]} $previousYear',
          );

          // Calculate income for previous month
          final prevIncome = transactions
              .where(
                (t) =>
                    t.type == entity.TransactionType.income &&
                    t.date.year == previousYear &&
                    t.date.month == previousMonth,
              )
              .fold(0.0, (sum, t) => sum + t.amount);

          // Calculate expense for previous month
          final prevExpense = transactions
              .where(
                (t) =>
                    t.type == entity.TransactionType.expense &&
                    t.date.year == previousYear &&
                    t.date.month == previousMonth,
              )
              .fold(0.0, (sum, t) => sum + t.amount);

          print(
            'Previous Period Debug: Income=$prevIncome, Expense=$prevExpense',
          );

          return {'income': prevIncome, 'expense': prevExpense};
        }
      }
    }

    // Fallback: use 30-60 days ago logic for current period or parsing failure
    final now = DateTime.now();
    final sixtyDaysAgo = now.subtract(const Duration(days: 60));
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final prevIncome = transactions
        .where(
          (t) =>
              t.type == entity.TransactionType.income &&
              t.date.isAfter(sixtyDaysAgo) &&
              t.date.isBefore(thirtyDaysAgo),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final prevExpense = transactions
        .where(
          (t) =>
              t.type == entity.TransactionType.expense &&
              t.date.isAfter(sixtyDaysAgo) &&
              t.date.isBefore(thirtyDaysAgo),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    print(
      'Previous Period Debug: Fallback 30-60 days ago - Income=$prevIncome, Expense=$prevExpense',
    );

    return {'income': prevIncome, 'expense': prevExpense};
  }

  // Helper method to calculate horizontal interval for charts
  double _getHorizontalInterval(double maxValue) {
    if (maxValue.abs() < 100000) {
      return 50000; // 50K intervals for small amounts
    } else if (maxValue.abs() < 1000000) {
      return 200000; // 200K intervals for medium amounts
    } else if (maxValue.abs() < 10000000) {
      return 2000000; // 2M intervals for large amounts
    } else {
      return maxValue.abs() / 5; // Dynamic intervals for very large amounts
    }
  }

  // Helper method to calculate minimum Y value for chart
  double _getMinY(List<FlSpot> spots) {
    if (spots.isEmpty) return 0.0;

    final minValue = spots
        .map((spot) => spot.y)
        .reduce((a, b) => a < b ? a : b);
    final maxValue = spots
        .map((spot) => spot.y)
        .reduce((a, b) => a > b ? a : b);

    // Add some padding below the minimum value
    if (minValue >= 0 && maxValue >= 0) {
      return 0.0; // Start from 0 for positive values
    } else {
      return minValue * 1.1; // Add 10% padding for negative values
    }
  }

  // Helper method to calculate maximum Y value for chart
  double _getMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 100000.0;

    final maxValue = spots
        .map((spot) => spot.y)
        .reduce((a, b) => a > b ? a : b);

    // Add some padding above the maximum value
    if (maxValue <= 0) {
      return 0.0; // End at 0 for negative values
    } else {
      return maxValue * 1.1; // Add 10% padding for positive values
    }
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

  // Build weekly trends data for monthly filter
  LineChartData _buildWeeklyTrendsData(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Parse selected period to get the target month/year
    if (selectedPeriod == null) {
      return _buildMonthlyTrendsData(context);
    }

    // Parse the selected period (could be in English or Indonesian format)
    final parts = selectedPeriod!.split(' ');
    if (parts.length != 2) {
      return _buildMonthlyTrendsData(context);
    } // Support both English and Indonesian month names
    final monthNamesEnglish = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final monthNamesIndonesian = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    int monthIndex = monthNamesEnglish.indexOf(parts[0]);
    if (monthIndex == -1) {
      monthIndex = monthNamesIndonesian.indexOf(parts[0]);
    }

    final year = int.tryParse(parts[1]);

    if (monthIndex == -1 || year == null) {
      return _buildMonthlyTrendsData(context);
    }

    final targetMonth = monthIndex + 1;
    final daysInMonth = DateTime(year, targetMonth + 1, 0).day;

    print('Weekly Debug: targetMonth=$targetMonth, daysInMonth=$daysInMonth');
    print(
      'Weekly Debug: transactions count for filtering=${transactions.length}',
    );

    final weeklyBalances = <FlSpot>[];
    double cumulativeBalance = 0.0;

    // Create 4 weeks of data (7 days each, last week may have fewer days)
    for (int week = 0; week < 4; week++) {
      final weekStart = (week * 7) + 1;
      final weekEnd = ((week + 1) * 7).clamp(1, daysInMonth);

      double weekIncome = 0.0;
      double weekExpense = 0.0;

      // Calculate income and expense for this week
      for (int day = weekStart; day <= weekEnd; day++) {
        final dayDate = DateTime(year, targetMonth, day);

        final dayIncome = transactions
            .where(
              (t) =>
                  t.type == entity.TransactionType.income &&
                  t.date.year == dayDate.year &&
                  t.date.month == dayDate.month &&
                  t.date.day == dayDate.day,
            )
            .fold(0.0, (sum, t) => sum + t.amount);

        final dayExpense = transactions
            .where(
              (t) =>
                  t.type == entity.TransactionType.expense &&
                  t.date.year == dayDate.year &&
                  t.date.month == dayDate.month &&
                  t.date.day == dayDate.day,
            )
            .fold(0.0, (sum, t) => sum + t.amount);

        weekIncome += dayIncome;
        weekExpense += dayExpense;
      }

      cumulativeBalance += (weekIncome - weekExpense);
      weeklyBalances.add(FlSpot(week.toDouble(), cumulativeBalance));

      print(
        'Weekly Debug: Week $week -> income=$weekIncome, expense=$weekExpense, cumulative=$cumulativeBalance',
      );
    }

    print('Weekly Debug: Final weeklyBalances length=${weeklyBalances.length}');
    for (var spot in weeklyBalances) {
      print('Weekly Debug: Week ${spot.x}: Balance=${spot.y}');
    }

    // Debug chart range
    final minY = _getMinY(weeklyBalances);
    final maxY = _getMaxY(weeklyBalances);
    final interval = _getHorizontalInterval(
      weeklyBalances.isNotEmpty ? weeklyBalances.last.y : 100000,
    );
    print(
      'Weekly Debug: Chart range - minY=$minY, maxY=$maxY, interval=$interval',
    );

    // Ensure we have data points - if all are zero, add some minimal variation
    if (weeklyBalances.every((spot) => spot.y == 0.0)) {
      // Add minimal variation to show a flat line instead of completely empty chart
      for (int i = 0; i < weeklyBalances.length; i++) {
        weeklyBalances[i] = FlSpot(i.toDouble(), 0.0);
      }
    }

    // Get the final balance for color calculation
    final finalBalance = weeklyBalances.isNotEmpty
        ? weeklyBalances.last.y
        : 0.0;

    return LineChartData(
      minY: _getMinY(weeklyBalances),
      maxY: _getMaxY(weeklyBalances),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _getHorizontalInterval(
          weeklyBalances.isNotEmpty ? weeklyBalances.last.y : 100000,
        ),
        getDrawingHorizontalLine: (value) => FlLine(
          color: isDarkMode
              ? Colors.white12
              : Colors.grey.withValues(alpha: 0.2),
          strokeWidth: 1,
        ),
      ),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) =>
              isDarkMode ? Colors.grey[800]! : Colors.white,
          tooltipPadding: const EdgeInsets.all(8),
          tooltipMargin: 8,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final weekNumber = barSpot.x.toInt() + 1;
              final formattedValue = NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp',
                decimalDigits: 0,
              ).format(barSpot.y);

              return LineTooltipItem(
                'Week $weekNumber\n$formattedValue',
                TextStyle(
                  color: finalBalance >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            getTitlesWidget: (value, meta) => Text(
              _formatIndonesianCurrencyForChart(value),
              style: AppTypography.bodySmall.copyWith(
                fontSize: 9,
                color: isDarkMode ? Colors.white70 : null,
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final weekLabels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
              final index = value.toInt();
              if (index >= 0 && index < weekLabels.length) {
                return Text(
                  weekLabels[index],
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 10,
                    color: isDarkMode ? Colors.white70 : null,
                  ),
                );
              }
              return const Text('');
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
          spots: weeklyBalances,
          isCurved: true,
          color: finalBalance >= 0 ? Colors.green : Colors.red,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: finalBalance >= 0 ? Colors.green : Colors.red,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: (finalBalance >= 0 ? Colors.green : Colors.red).withValues(
              alpha: 0.15,
            ),
          ),
        ),
      ],
    );
  }

  // Build monthly trends data (original logic)
  LineChartData _buildMonthlyTrendsData(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final oneYearAgo = DateTime(now.year - 1, now.month);

    final monthlyBalances = <FlSpot>[];
    double cumulativeBalance = 0.0;

    for (int i = 0; i < 12; i++) {
      final monthDate = DateTime(oneYearAgo.year, oneYearAgo.month + i);

      // Calculate income for this month
      final monthIncome = transactions
          .where(
            (t) =>
                t.type == entity.TransactionType.income &&
                t.date.year == monthDate.year &&
                t.date.month == monthDate.month,
          )
          .fold(0.0, (sum, t) => sum + t.amount);

      // Calculate expenses for this month
      final monthExpense = transactions
          .where(
            (t) =>
                t.type == entity.TransactionType.expense &&
                t.date.year == monthDate.year &&
                t.date.month == monthDate.month,
          )
          .fold(0.0, (sum, t) => sum + t.amount);

      // Update cumulative balance
      cumulativeBalance += (monthIncome - monthExpense);
      monthlyBalances.add(FlSpot(i.toDouble(), cumulativeBalance));
    }

    return LineChartData(
      minY: _getMinY(monthlyBalances),
      maxY: _getMaxY(monthlyBalances),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _getHorizontalInterval(cumulativeBalance),
        getDrawingHorizontalLine: (value) => FlLine(
          color: isDarkMode
              ? Colors.white12
              : Colors.grey.withValues(alpha: 0.2),
          strokeWidth: 1,
        ),
      ),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) =>
              isDarkMode ? Colors.grey[800]! : Colors.white,
          tooltipPadding: const EdgeInsets.all(8),
          tooltipMargin: 8,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            final oneYearAgo = DateTime(now.year - 1, now.month);
            return touchedBarSpots.map((barSpot) {
              final monthDate = DateTime(
                oneYearAgo.year,
                oneYearAgo.month + barSpot.x.toInt(),
              );
              final monthNames = [
                'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sep',
                'Oct',
                'Nov',
                'Dec',
              ];
              final monthName = monthNames[monthDate.month - 1];
              final formattedValue = NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp',
                decimalDigits: 0,
              ).format(barSpot.y);

              return LineTooltipItem(
                '$monthName ${monthDate.year}\n$formattedValue',
                TextStyle(
                  color: cumulativeBalance >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            getTitlesWidget: (value, meta) => Text(
              _formatIndonesianCurrencyForChart(value),
              style: AppTypography.bodySmall.copyWith(
                fontSize: 9,
                color: isDarkMode ? Colors.white70 : null,
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final oneYearAgo = DateTime(now.year - 1, now.month);
              final monthDate = DateTime(
                oneYearAgo.year,
                oneYearAgo.month + value.toInt(),
              );
              final monthNames = [
                'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sep',
                'Oct',
                'Nov',
                'Dec',
              ];
              return Text(
                monthNames[monthDate.month - 1],
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
          spots: monthlyBalances,
          isCurved: true,
          color: cumulativeBalance >= 0 ? Colors.green : Colors.red,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: cumulativeBalance >= 0 ? Colors.green : Colors.red,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: (cumulativeBalance >= 0 ? Colors.green : Colors.red)
                .withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }

  // Enhanced chart data methods
  LineChartData _buildEnhancedSpendingTrendsData(BuildContext context) {
    print('Chart Debug: isAllTime=$isAllTime, selectedPeriod=$selectedPeriod');
    print('Chart Debug: transactions count=${transactions.length}');

    // Check if we should show weekly trends (when monthly filter is active)
    if (!isAllTime && selectedPeriod != null) {
      print('Chart Debug: Building weekly trends');
      return _buildWeeklyTrendsData(context);
    }

    // Default: show monthly trends for all time or general view
    print('Chart Debug: Building monthly trends');
    return _buildMonthlyTrendsData(context);
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

    // Calculate total for percentage calculation
    final totalAmount = categoryData.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );

    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: categoryData.entries.map((entry) {
            final index = categoryData.keys.toList().indexOf(entry.key);
            final percentage = totalAmount > 0
                ? (entry.value / totalAmount) * 100
                : 0.0;

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
                  const SizedBox(width: 8),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white70 : AppColors.greyColor,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 8),
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

    // Determine which month to use based on filter
    int targetYear;
    int targetMonth;

    if (!isAllTime && selectedPeriod != null) {
      // Parse selected period to get the target month/year
      final parts = selectedPeriod!.split(' ');
      if (parts.length == 2) {
        // Support both English and Indonesian month names
        final monthNamesEnglish = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];
        final monthNamesIndonesian = [
          'Januari',
          'Februari',
          'Maret',
          'April',
          'Mei',
          'Juni',
          'Juli',
          'Agustus',
          'September',
          'Oktober',
          'November',
          'Desember',
        ];

        int monthIndex = monthNamesEnglish.indexOf(parts[0]);
        if (monthIndex == -1) {
          monthIndex = monthNamesIndonesian.indexOf(parts[0]);
        }

        final year = int.tryParse(parts[1]);

        if (monthIndex != -1 && year != null) {
          targetMonth = monthIndex + 1;
          targetYear = year;
        } else {
          // Fallback to current month if parsing fails
          targetYear = now.year;
          targetMonth = now.month;
        }
      } else {
        // Fallback to current month if parsing fails
        targetYear = now.year;
        targetMonth = now.month;
      }
    } else {
      // Use current month for all time or no filter
      targetYear = now.year;
      targetMonth = now.month;
    }

    final lastDayOfMonth = DateTime(targetYear, targetMonth + 1, 0).day;

    print(
      'Comparison Debug: Using targetMonth=$targetMonth, targetYear=$targetYear, lastDay=$lastDayOfMonth',
    );

    final weeklyData = <BarChartGroupData>[];

    // Define week periods for the month
    final weekPeriods = [
      {'start': 1, 'end': 7},
      {'start': 8, 'end': 14},
      {'start': 15, 'end': 21},
      {'start': 22, 'end': lastDayOfMonth}, // Last week extends to end of month
    ];

    for (int week = 0; week < weekPeriods.length; week++) {
      final weekStart = weekPeriods[week]['start']!;
      final weekEnd = weekPeriods[week]['end']!;

      double weekIncome = 0.0;
      double weekExpense = 0.0;

      // Calculate income and expense for this week period
      for (int day = weekStart; day <= weekEnd; day++) {
        final date = DateTime(targetYear, targetMonth, day);

        // Skip if the date is in the future (only for current month)
        if (targetYear == now.year &&
            targetMonth == now.month &&
            date.isAfter(now)) {
          continue;
        }

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

        weekIncome += dayIncome;
        weekExpense += dayExpense;
      }

      print(
        'Comparison Debug: Week $week ($weekStart-$weekEnd) -> income=$weekIncome, expense=$weekExpense',
      );

      weeklyData.add(
        BarChartGroupData(
          x: week,
          barRods: [
            BarChartRodData(
              toY: weekIncome,
              color: Colors.green,
              width: 12,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
              rodStackItems: [],
              backDrawRodData: BackgroundBarChartRodData(show: false),
            ),
            BarChartRodData(
              toY: weekExpense,
              color: Colors.red,
              width: 12,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
              rodStackItems: [],
              backDrawRodData: BackgroundBarChartRodData(show: false),
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
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) =>
              isDarkMode ? Colors.grey[800]! : Colors.white,
          tooltipPadding: const EdgeInsets.all(8),
          tooltipMargin: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final isIncome = rodIndex == 0;
            final value = rod.toY;
            final label = isIncome ? 'Income' : 'Expense';
            final formattedValue = NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp',
              decimalDigits: 0,
            ).format(value);

            return BarTooltipItem(
              '$label\n$formattedValue',
              TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            getTitlesWidget: (value, meta) => Text(
              _formatIndonesianCurrencyForChart(value),
              style: AppTypography.bodySmall.copyWith(
                fontSize: 9,
                color: isDarkMode ? Colors.white70 : null,
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final weekLabels = ['1-7', '8-14', '15-21', '22-$lastDayOfMonth'];
              return Text(
                weekLabels[value.toInt()],
                style: AppTypography.bodySmall.copyWith(
                  color: isDarkMode ? Colors.white70 : null,
                  fontSize: 10,
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
            : Colors.white, // Gunakan putih murni untuk spending trends chart
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(
          color: isDarkMode
              ? Colors.grey.withValues(alpha: 0.2)
              : AppColors.greyLightColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(
                    alpha: 0.1,
                  ), // Shadow lebih gelap untuk spending trends chart
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -2,
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
              Expanded(
                child: Text(
                  !isAllTime && selectedPeriod != null
                      ? 'Weekly Balance Trends ($selectedPeriod)'
                      : 'Monthly Balance Trends (12M)',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 220,
            child: LineChart(_buildEnhancedSpendingTrendsData(context)),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildBalanceTrendsInsight(context),
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
            : Colors.white, // Gunakan putih murni untuk category chart
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(
          color: isDarkMode
              ? Colors.grey.withValues(alpha: 0.2)
              : AppColors.greyLightColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(
                    alpha: 0.1,
                  ), // Shadow lebih gelap untuk category chart
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -2,
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
              Expanded(
                child: Text(
                  'Expense by Category',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
            : Colors.white, // Gunakan putih murni untuk comparison chart
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(
          color: isDarkMode
              ? Colors.grey.withValues(alpha: 0.2)
              : AppColors.greyLightColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(
                    alpha: 0.1,
                  ), // Shadow lebih gelap untuk comparison chart
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -2,
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
              Expanded(
                child: Text(
                  !isAllTime && selectedPeriod != null
                      ? 'Income vs Expense ($selectedPeriod)'
                      : 'Income vs Expense (Current Month)',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                    : AppColors.greyColor.withValues(alpha: 0.5),
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

  Widget _buildBalanceTrendsInsight(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentMonthBalance = _getCurrentMonthBalance();
    final previousMonthBalance = _getPreviousMonthBalance();
    final balanceChange = currentMonthBalance - previousMonthBalance;
    final balanceChangePercentage = previousMonthBalance != 0
        ? (balanceChange / previousMonthBalance.abs()) * 100
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode
              ? Colors.grey.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            balanceChange >= 0 ? Icons.trending_up : Icons.trending_down,
            color: balanceChange >= 0 ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              balanceChange >= 0
                  ? 'Balance increased by ${_formatIndonesianCurrency(balanceChange.abs())} this month'
                  : 'Balance decreased by ${_formatIndonesianCurrency(balanceChange.abs())} this month',
              style: AppTypography.bodySmall.copyWith(
                color: isDarkMode ? Colors.white70 : AppColors.greyDarkColor,
                fontSize: 11,
              ),
            ),
          ),
          if (balanceChangePercentage != 0.0) ...[
            Text(
              '${balanceChangePercentage >= 0 ? '+' : ''}${balanceChangePercentage.toStringAsFixed(1)}%',
              style: AppTypography.bodySmall.copyWith(
                color: balanceChange >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _getCurrentMonthBalance() {
    final now = DateTime.now();
    final currentMonthIncome = transactions
        .where(
          (t) =>
              t.type == entity.TransactionType.income &&
              t.date.year == now.year &&
              t.date.month == now.month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final currentMonthExpense = transactions
        .where(
          (t) =>
              t.type == entity.TransactionType.expense &&
              t.date.year == now.year &&
              t.date.month == now.month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    return currentMonthIncome - currentMonthExpense;
  }

  double _getPreviousMonthBalance() {
    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1);

    final previousMonthIncome = transactions
        .where(
          (t) =>
              t.type == entity.TransactionType.income &&
              t.date.year == previousMonth.year &&
              t.date.month == previousMonth.month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final previousMonthExpense = transactions
        .where(
          (t) =>
              t.type == entity.TransactionType.expense &&
              t.date.year == previousMonth.year &&
              t.date.month == previousMonth.month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    return previousMonthIncome - previousMonthExpense;
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
