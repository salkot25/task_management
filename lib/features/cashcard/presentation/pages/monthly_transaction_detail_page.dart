import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:clarity/features/cashcard/domain/entities/transaction.dart';
import 'package:clarity/features/cashcard/presentation/provider/cashcard_provider.dart';
import 'package:clarity/utils/design_system/app_colors.dart';
import 'package:clarity/utils/design_system/app_spacing.dart';
import 'package:clarity/utils/design_system/app_typography.dart';
import 'package:clarity/presentation/widgets/standard_app_bar.dart';

class MonthlyTransactionDetailPage extends StatefulWidget {
  final String monthYear;
  final List<Transaction> transactions;

  const MonthlyTransactionDetailPage({
    super.key,
    required this.monthYear,
    required this.transactions,
  });

  @override
  State<MonthlyTransactionDetailPage> createState() =>
      _MonthlyTransactionDetailPageState();
}

class _MonthlyTransactionDetailPageState
    extends State<MonthlyTransactionDetailPage> {
  String _filterType = 'All'; // All, Income, Expense
  String _sortBy = 'Date'; // Date, Amount, Category
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final filteredTransactions = _getFilteredTransactions();
    final monthlyStats = _calculateMonthlyStats(filteredTransactions);

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF1A1A1A)
          : Theme.of(context).colorScheme.surface,
      appBar: StandardAppBar(
        title: widget.monthYear,
        subtitle: '${filteredTransactions.length} transactions',
        actions: [
          // Sort and filter button
          PopupMenuButton<String>(
            icon: Icon(Icons.tune_rounded, color: AppColors.primaryColor),
            tooltip: 'Filter & Sort',
            onSelected: (value) {
              setState(() {
                if (value.startsWith('filter_')) {
                  _filterType = value.replaceFirst('filter_', '');
                } else if (value.startsWith('sort_')) {
                  final newSort = value.replaceFirst('sort_', '');
                  if (_sortBy == newSort) {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortBy = newSort;
                    _sortAscending = false;
                  }
                }
              });
            },
            itemBuilder: (context) => [
              // Filter options
              const PopupMenuItem(
                value: '',
                enabled: false,
                child: Text(
                  'Filter by Type',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              PopupMenuItem(
                value: 'filter_All',
                child: Row(
                  children: [
                    Icon(
                      _filterType == 'All'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('All Transactions'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'filter_Income',
                child: Row(
                  children: [
                    Icon(
                      _filterType == 'Income'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: AppColors.successColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Income Only'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'filter_Expense',
                child: Row(
                  children: [
                    Icon(
                      _filterType == 'Expense'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: AppColors.errorColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Expenses Only'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              // Sort options
              const PopupMenuItem(
                value: '',
                enabled: false,
                child: Text(
                  'Sort by',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              PopupMenuItem(
                value: 'sort_Date',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'Date'
                          ? (_sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward)
                          : Icons.calendar_today_outlined,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Date'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sort_Amount',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'Amount'
                          ? (_sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward)
                          : Icons.attach_money_outlined,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Amount'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sort_Category',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'Category'
                          ? (_sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward)
                          : Icons.category_outlined,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Category'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final provider = Provider.of<CashcardProvider>(
            context,
            listen: false,
          );
          await provider.refresh();
        },
        color: AppColors.primaryColor,
        child: CustomScrollView(
          slivers: [
            // Monthly Statistics Header
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryDarkColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Monthly Summary',
                      style: AppTypography.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Income',
                            monthlyStats['income']!,
                            Icons.trending_up,
                            AppColors.successLightColor,
                            isDarkMode,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildStatCard(
                            'Total Expense',
                            monthlyStats['expense']!,
                            Icons.trending_down,
                            AppColors.errorLightColor,
                            isDarkMode,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Net Balance',
                            style: AppTypography.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(monthlyStats['balance']!),
                            style: AppTypography.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter and Sort Status
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF2D2D2D)
                      : AppColors.greyLightColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      size: 16,
                      color: AppColors.greyColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Filter: $_filterType',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.greyColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(
                      Icons.sort_rounded,
                      size: 16,
                      color: AppColors.greyColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Sort: $_sortBy ${_sortAscending ? '↑' : '↓'}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.greyColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

            // Transaction List
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final transaction = filteredTransactions[index];
                final isLast = index == filteredTransactions.length - 1;

                return Container(
                  margin: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    isLast ? AppSpacing.md : 0,
                  ),
                  child: _buildDetailedTransactionTile(
                    transaction,
                    isLast,
                    isDarkMode,
                  ),
                );
              }, childCount: filteredTransactions.length),
            ),

            // Empty state
            if (filteredTransactions.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: AppColors.greyColor,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No transactions found',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Try adjusting your filter settings',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.greyColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Transaction> _getFilteredTransactions() {
    var filtered = List<Transaction>.from(widget.transactions);

    // Apply filter
    if (_filterType == 'Income') {
      filtered = filtered
          .where((t) => t.type == TransactionType.income)
          .toList();
    } else if (_filterType == 'Expense') {
      filtered = filtered
          .where((t) => t.type == TransactionType.expense)
          .toList();
    }

    // Apply sort
    filtered.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case 'Date':
          comparison = a.date.compareTo(b.date);
          break;
        case 'Amount':
          comparison = a.amount.compareTo(b.amount);
          break;
        case 'Category':
          final aCategory = a.getCategoryDisplayName();
          final bCategory = b.getCategoryDisplayName();
          comparison = aCategory.compareTo(bCategory);
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  Map<String, double> _calculateMonthlyStats(List<Transaction> transactions) {
    double income = 0.0;
    double expense = 0.0;

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return {'income': income, 'expense': expense, 'balance': income - expense};
  }

  Widget _buildStatCard(
    String title,
    double amount,
    IconData icon,
    Color iconColor,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white70,
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
            NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(amount),
            style: AppTypography.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedTransactionTile(
    Transaction transaction,
    bool isLast,
    bool isDarkMode,
  ) {
    final isIncome = transaction.type == TransactionType.income;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? Colors.grey.withOpacity(0.2)
              : AppColors.greyLightColor.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Transaction icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isIncome
                      ? AppColors.successColor.withOpacity(0.1)
                      : AppColors.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isIncome
                        ? AppColors.successColor.withOpacity(0.3)
                        : AppColors.errorColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  isIncome ? Icons.trending_up : Icons.trending_down,
                  color: isIncome
                      ? AppColors.successColor
                      : AppColors.errorColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Transaction details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: AppTypography.bodyLarge.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.getCategoryDisplayName(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.greyColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'} ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(transaction.amount)}',
                    style: AppTypography.titleMedium.copyWith(
                      color: isIncome
                          ? AppColors.successColor
                          : AppColors.errorColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Transaction metadata
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey.withOpacity(0.1)
                  : AppColors.greyLightColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: AppColors.greyColor,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  DateFormat(
                    'EEEE, dd MMMM yyyy • HH:mm WIB',
                    'id_ID',
                  ).format(transaction.date),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.greyColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isIncome
                        ? AppColors.successColor.withOpacity(0.1)
                        : AppColors.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isIncome ? 'INCOME' : 'EXPENSE',
                    style: AppTypography.labelSmall.copyWith(
                      color: isIncome
                          ? AppColors.successColor
                          : AppColors.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
