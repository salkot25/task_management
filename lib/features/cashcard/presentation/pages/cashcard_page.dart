import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/cashcard/presentation/provider/cashcard_provider.dart';
import 'package:myapp/features/cashcard/domain/entities/transaction.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:myapp/utils/design_system/app_colors.dart';
import 'package:myapp/utils/design_system/app_spacing.dart';
import 'package:myapp/utils/design_system/app_typography.dart';
import 'package:myapp/utils/design_system/app_components.dart';
import 'package:myapp/features/cashcard/presentation/widgets/financial_charts.dart';
import 'package:myapp/utils/navigation_helper_v2.dart' as nav;
import 'package:myapp/features/cashcard/presentation/widgets/budget_management.dart';
import 'package:myapp/features/cashcard/presentation/widgets/export_functions.dart';
import 'package:myapp/presentation/widgets/standard_app_bar.dart';

class CashcardPage extends StatefulWidget {
  const CashcardPage({super.key});

  @override
  State<CashcardPage> createState() => _CashcardPageState();
}

class _CashcardPageState extends State<CashcardPage>
    with TickerProviderStateMixin {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  // Removed _selectedType, will use provider instead
  DateTime _selectedDate = DateTime.now();

  // Tab Controller for advanced features
  late TabController _tabController;

  // Added for the month filter dropdown
  final List<String> _months =
      ['All Time'] +
      List.generate(
        12,
        (index) => DateFormat('MMMM').format(DateTime(0, index + 1)),
      );
  late String _selectedMonth;
  late int _selectedYear;
  late List<int> _years; // Define _years here

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _years = _getYearsList(); // Initialize _years in initState
    // Initialize selected month and year from the provider
    final cashcardProvider = Provider.of<CashcardProvider>(
      context,
      listen: false,
    );
    if (cashcardProvider.showAllTime) {
      _selectedMonth = 'All Time';
      // We still need a selected year for the dropdown, even if showing all time.
      // Let's default to the current year or the provider's selected year.
      _selectedYear = cashcardProvider.selectedYear; // Or DateTime.now().year
    } else {
      // Adjust index for 0-based _months list (excluding 'All Time')
      _selectedMonth =
          _months[cashcardProvider
              .selectedMonth]; // Use the provider's month (1-based index + 1 for 'All Time')
      _selectedYear = cashcardProvider.selectedYear;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _addTransaction(BuildContext context) {
    // Pass context to access provider
    if (_descriptionController.text.isNotEmpty &&
        _amountController.text.isNotEmpty) {
      final description = _descriptionController.text;
      final amount = double.tryParse(_amountController.text);

      if (amount != null) {
        // Get selected type and category from provider
        final provider = Provider.of<CashcardProvider>(context, listen: false);

        final selectedType = provider.selectedTransactionType;
        ExpenseCategory? selectedCategory;

        if (selectedType == TransactionType.expense) {
          // Use selected category, or auto-detect from description
          selectedCategory = provider.selectedExpenseCategory;

          // If category is 'others', try to auto-categorize from description
          if (selectedCategory == ExpenseCategory.others) {
            selectedCategory = provider.getExpenseCategoryFromDescription(
              description,
            );
          }
        }

        final newTransaction = Transaction(
          id: DateTime.now().toString(), // Simple ID generation
          description: description,
          amount: amount,
          type: selectedType, // Use selectedType from provider
          date: _selectedDate,
          category: selectedCategory, // Add category for expenses
        );

        provider.addTransaction(newTransaction);

        // Clear the form and reset selected type in provider
        _descriptionController.clear();
        _amountController.clear();
        // Reset selected type and category in provider
        provider.setSelectedTransactionType(TransactionType.expense);
        provider.setSelectedExpenseCategory(ExpenseCategory.others);

        // Close the modal after adding the transaction
        Navigator.of(context).pop();
      }
    }
  }

  // Method to generate a list of years for the dropdown (e.g., current year +/- 5)
  List<int> _getYearsList() {
    final currentYear = DateTime.now().year;
    return List.generate(11, (index) => currentYear - 5 + index);
  }

  // Enhanced Add Transaction Modal
  void _showAddTransactionModal(BuildContext context) {
    nav.NavigationHelper.safeShowModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        height: MediaQuery.of(modalContext).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(modalContext).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppComponents.extraLargeRadius),
            topRight: Radius.circular(AppComponents.extraLargeRadius),
          ),
        ),
        child: Column(
          children: [
            // Modal handle
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Modal header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Transaction',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(modalContext).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Enhanced form content
            Expanded(child: _buildEnhancedTransactionForm()),
          ],
        ),
      ),
    );
  }

  // Enhanced Transaction Form
  Widget _buildEnhancedTransactionForm() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Consumer<CashcardProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Transaction Type Selection (Enhanced)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.greyExtraLightColor,
                        borderRadius: AppComponents.standardBorderRadius,
                        border: Border.all(
                          color: AppColors.greyLightColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transaction Type',
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTransactionTypeButton(
                                  'Income',
                                  Icons.trending_up,
                                  TransactionType.income,
                                  provider.selectedTransactionType ==
                                      TransactionType.income,
                                  AppColors.successColor,
                                  provider,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _buildTransactionTypeButton(
                                  'Expense',
                                  Icons.trending_down,
                                  TransactionType.expense,
                                  provider.selectedTransactionType ==
                                      TransactionType.expense,
                                  AppColors.errorColor,
                                  provider,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Expense Category Selection (only visible for expense transactions)
                    if (provider.selectedTransactionType ==
                        TransactionType.expense)
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.greyExtraLightColor,
                              borderRadius: AppComponents.standardBorderRadius,
                              border: Border.all(
                                color: AppColors.greyLightColor,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expense Category',
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                DropdownButtonFormField<ExpenseCategory>(
                                  value: provider.selectedExpenseCategory,
                                  decoration: AppComponents.inputDecoration(
                                    labelText: 'Select Category',
                                    prefixIcon: const Icon(
                                      Icons.category_outlined,
                                    ),
                                  ),
                                  items: Transaction.getCategoryDisplayNames()
                                      .entries
                                      .map(
                                        (entry) =>
                                            DropdownMenuItem<ExpenseCategory>(
                                              value: entry.key,
                                              child: Text(entry.value),
                                            ),
                                      )
                                      .toList(),
                                  onChanged: (ExpenseCategory? newValue) {
                                    if (newValue != null) {
                                      provider.setSelectedExpenseCategory(
                                        newValue,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),

                    // Description Field (Enhanced)
                    TextFormField(
                      controller: _descriptionController,
                      decoration: AppComponents.inputDecoration(
                        labelText: 'Transaction Description',
                        hintText: 'e.g., Grocery shopping, Salary payment',
                        prefixIcon: const Icon(Icons.description_outlined),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Amount Field (Enhanced)
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: AppComponents.inputDecoration(
                        labelText: 'Amount',
                        hintText: '0',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Rp',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Date Selection (Enhanced)
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != _selectedDate) {
                          setState(() {
                            _selectedDate = picked;
                          });
                          setModalState(() {}); // Trigger modal rebuild
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.greyLightColor),
                          borderRadius: AppComponents.standardBorderRadius,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Transaction Date',
                                  style: AppTypography.titleSmall.copyWith(
                                    color: AppColors.greyDarkColor,
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    'EEEE, MMM dd, yyyy',
                                  ).format(_selectedDate),
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.greyColor,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Enhanced Add Button
                    ElevatedButton(
                      onPressed: () => _addTransaction(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppComponents.standardBorderRadius,
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Add Transaction',
                            style: AppTypography.buttonPrimary.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Transaction Type Button Widget
  Widget _buildTransactionTypeButton(
    String label,
    IconData icon,
    TransactionType type,
    bool isSelected,
    Color color,
    CashcardProvider provider,
  ) {
    return GestureDetector(
      onTap: () => provider.setSelectedTransactionType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : AppColors.greyLightColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppComponents.smallRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.greyColor,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected ? color : AppColors.greyDarkColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced Professional Financial Card
  Widget _buildPremiumFinancialCard(
    BuildContext context,
    double balance,
    double income,
    double expense,
  ) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Stack(
        children: [
          // Background with sophisticated gradient
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryDarkColor,
                  AppColors.primaryColor,
                  AppColors.primaryLightColor.withOpacity(0.8),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
              borderRadius: AppComponents.largeBorderRadius,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Header with logo/brand
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Balance',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Balance amount with sophisticated typography
                Text(
                  NumberFormat.currency(
                    locale: 'id',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(balance),
                  style: AppTypography.displayMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Income & Expense with improved layout
                Row(
                  children: [
                    Expanded(
                      child: _buildFinancialMetric(
                        'Income',
                        income,
                        Icons.trending_up,
                        AppColors.successLightColor,
                        CrossAxisAlignment.start, // Income aligned to left
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.white30),
                    Expanded(
                      child: _buildFinancialMetric(
                        'Expense',
                        expense,
                        Icons.trending_down,
                        AppColors.errorLightColor,
                        CrossAxisAlignment.end, // Expense aligned to right
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Decorative elements
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for financial metrics
  Widget _buildFinancialMetric(
    String title,
    double amount,
    IconData icon,
    Color iconColor,
    CrossAxisAlignment alignment,
  ) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Row(
          mainAxisAlignment: alignment == CrossAxisAlignment.end
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: AppSpacing.xs),
            Text(
              title,
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(amount),
          style: AppTypography.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Professional Transaction List Widget
  Widget _buildProfessionalTransactionList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppComponents.standardBorderRadius,
          border: Border.all(color: AppColors.greyLightColor, width: 1),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.greyColor,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Transactions Yet',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.greyColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start tracking your income and expenses',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.greyColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(color: AppColors.greyLightColor, width: 1),
      ),
      child: Column(
        children: [
          // Transaction header
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.greyExtraLightColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppComponents.standardRadius),
                topRight: Radius.circular(AppComponents.standardRadius),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppComponents.smallRadius,
                    ),
                  ),
                  child: Text(
                    '${transactions.length} items',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Transaction list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppColors.greyLightColor,
              indent: AppSpacing.xl,
            ),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildProfessionalTransactionTile(transaction);
            },
          ),
        ],
      ),
    );
  }

  // Financial Insights Widget
  Widget _buildFinancialInsights(CashcardProvider provider) {
    final totalTransactions = provider.transactions.length;
    final avgDailyExpense = provider.totalExpense / 30;
    final savingsRate = provider.totalIncome > 0
        ? ((provider.totalIncome - provider.totalExpense) /
              provider.totalIncome *
              100)
        : 0.0;

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
                'Financial Insights',
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
                child: _buildInsightCard(
                  'Total Transactions',
                  totalTransactions.toString(),
                  Icons.receipt_long,
                  AppColors.infoColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildInsightCard(
                  'Daily Average',
                  NumberFormat.currency(
                    locale: 'id',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(avgDailyExpense),
                  Icons.calendar_today,
                  AppColors.warningColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  'Savings Rate',
                  '${savingsRate.toStringAsFixed(1)}%',
                  Icons.savings,
                  savingsRate >= 20
                      ? AppColors.successColor
                      : AppColors.errorColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildInsightCard(
                  'Balance Status',
                  provider.balance >= 0 ? 'Positive' : 'Negative',
                  provider.balance >= 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                  provider.balance >= 0
                      ? AppColors.successColor
                      : AppColors.errorColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Insight Card Widget
  Widget _buildInsightCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppComponents.smallRadius),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
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
                  title,
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

  // Professional Transaction Tile Widget
  Widget _buildProfessionalTransactionTile(Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Transaction icon with background
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isIncome
                  ? AppColors.successLightColor
                  : AppColors.errorLightColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Icons.south_west : Icons.north_east,
              color: isIncome ? AppColors.successColor : AppColors.errorColor,
              size: 20,
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
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      DateFormat('dd-MM-yy').format(transaction.date),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.greyColor,
                      ),
                    ),
                    // Show category for expense transactions
                    if (!isIncome && transaction.category != null) ...[
                      Text(
                        ' • ',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.greyColor,
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            transaction.getCategoryDisplayName(),
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Amount with proper formatting
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(transaction.amount)}',
                style: AppTypography.titleSmall.copyWith(
                  color: isIncome
                      ? AppColors.successColor
                      : AppColors.errorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isIncome
                      ? AppColors.successColor.withOpacity(0.1)
                      : AppColors.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isIncome ? 'Income' : 'Expense',
                  style: AppTypography.labelSmall.copyWith(
                    color: isIncome
                        ? AppColors.successColor
                        : AppColors.errorColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cashcardProvider = Provider.of<CashcardProvider>(context);
    final transactions = cashcardProvider.transactions;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: StandardAppBar(
        title: 'Cashcard',
        subtitle: 'Manage your finances',
        actions: [
          // Filter container with enhanced design
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            child: Row(
              children: [
                // Month filter
                AppBarFilterChip(
                  value: _selectedMonth,
                  items: _months,
                  color: AppColors.primaryColor,
                  label: 'Month',
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedMonth = newValue;
                        if (newValue == 'All Time') {
                          cashcardProvider.setShowAllTime(true);
                        } else {
                          final monthIndex = _months.indexOf(newValue);
                          cashcardProvider.setFilter(monthIndex, _selectedYear);
                        }
                      });
                    }
                  },
                ),
                // Year filter (only visible when not showing All Time)
                if (!cashcardProvider.showAllTime) ...[
                  const SizedBox(width: AppSpacing.sm),
                  AppBarFilterChip(
                    value: _selectedYear.toString(),
                    items: _years.map((year) => year.toString()).toList(),
                    color: AppColors.secondaryColor,
                    label: 'Year',
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedYear = int.parse(newValue);
                          final monthIndex = _months.indexOf(_selectedMonth);
                          cashcardProvider.setFilter(monthIndex, _selectedYear);
                        });
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: AppColors.greyColor,
              indicatorColor: AppColors.primaryColor,
              indicatorWeight: 3,
              labelStyle: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTypography.bodyMedium,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
                Tab(icon: Icon(Icons.bar_chart), text: 'Analytics'),
                Tab(icon: Icon(Icons.account_balance_wallet), text: 'Budget'),
                Tab(icon: Icon(Icons.file_download), text: 'Export'),
              ],
            ),
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Overview Tab
                _buildOverviewTab(cashcardProvider, transactions),

                // Analytics Tab
                _buildAnalyticsTab(cashcardProvider),

                // Budget Tab
                _buildBudgetTab(cashcardProvider),

                // Export Tab
                _buildExportTab(cashcardProvider),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddTransactionModal(context),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add, size: 24),
          label: Text(
            'Add Transaction',
            style: AppTypography.labelLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Tab Content Methods
  Widget _buildOverviewTab(
    CashcardProvider cashcardProvider,
    List<Transaction> transactions,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Displaying Income, Expense, and Balance in a single credit card like widget
            _buildPremiumFinancialCard(
              context,
              cashcardProvider.balance,
              cashcardProvider.totalIncome,
              cashcardProvider.totalExpense,
            ),
            const SizedBox(height: AppSpacing.md),

            // Financial Insights Section
            _buildFinancialInsights(cashcardProvider),
            const SizedBox(height: AppSpacing.md),

            // Transaction Period Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'Transactions (${cashcardProvider.showAllTime ? 'All Time' : '$_selectedMonth $_selectedYear'})',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Professional Transaction List
            _buildProfessionalTransactionList(transactions),

            // Bottom spacing for FAB
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab(CashcardProvider cashcardProvider) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: FinancialCharts(transactions: cashcardProvider.transactions),
    );
  }

  Widget _buildBudgetTab(CashcardProvider cashcardProvider) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: BudgetManagement(
          categories: cashcardProvider.budgetCategories,
          onAddCategory: (category) =>
              cashcardProvider.addBudgetCategory(category),
          onUpdateBudget: (category, amount) =>
              cashcardProvider.updateBudgetCategory(category, amount),
        ),
      ),
    );
  }

  Widget _buildExportTab(CashcardProvider cashcardProvider) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: ExportFunctions(
          transactions: cashcardProvider.transactions,
          totalIncome: cashcardProvider.totalIncome,
          totalExpense: cashcardProvider.totalExpense,
          balance: cashcardProvider.balance,
        ),
      ),
    );
  }

  // Removed the old _buildSummaryCard method
  // Widget _buildSummaryCard(String title, double amount, Color color) {
  //   ...
  // }
}
