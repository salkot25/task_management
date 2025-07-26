import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clarity/features/cashcard/presentation/provider/cashcard_provider.dart';
import 'package:clarity/features/cashcard/domain/entities/transaction.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:clarity/utils/design_system/app_colors.dart';
import 'package:clarity/utils/design_system/app_spacing.dart';
import 'package:clarity/utils/design_system/app_typography.dart';
import 'package:clarity/utils/design_system/app_components.dart';
import 'package:clarity/features/cashcard/presentation/widgets/financial_charts.dart';
import 'package:clarity/features/cashcard/presentation/widgets/enhanced_budget_management.dart';
import 'package:clarity/features/cashcard/presentation/widgets/budget_notification_widgets.dart';
import 'package:clarity/features/cashcard/presentation/widgets/export_functions.dart';
import 'package:clarity/presentation/widgets/standard_app_bar.dart';

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

  // Enhanced Add Transaction Dialog (changed from modal to popup)
  void _showAddTransactionModal(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDarkMode
              ? const Color(0xFF2D2D2D)
              : Theme.of(context).colorScheme.surface,
          surfaceTintColor: isDarkMode
              ? Colors.transparent
              : Theme.of(context).colorScheme.surfaceTint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: isDarkMode ? 8 : 4,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_card_rounded,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Transaction',
                      style: AppTypography.headlineSmall.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Record your income or expense',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: _buildEnhancedTransactionForm(),
            ),
          ),
          actions: [
            // Enhanced Cancel Button
            TextButton(
              onPressed: () {
                // Clear the form controllers when canceling
                _descriptionController.clear();
                _amountController.clear();
                // Reset selected date to today
                setState(() {
                  _selectedDate = DateTime.now();
                });
                // Reset provider selections
                final provider = Provider.of<CashcardProvider>(
                  context,
                  listen: false,
                );
                provider.setSelectedTransactionType(TransactionType.expense);
                provider.setSelectedExpenseCategory(ExpenseCategory.others);
                // Close the dialog
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: isDarkMode
                    ? Colors.grey[400]
                    : Colors.grey[600],
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Enhanced Add Button
            ElevatedButton(
              onPressed: () => _addTransaction(dialogContext),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Add Transaction',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Enhanced Transaction Form
  Widget _buildEnhancedTransactionForm() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<CashcardProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),

            // Transaction Type Selection (Enhanced)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.grey.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
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
                      color: isDarkMode ? Colors.white : Colors.black87,
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

            const SizedBox(height: AppSpacing.md),

            // Expense Category Selection (only visible for expense transactions)
            if (provider.selectedTransactionType ==
                TransactionType.expense) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.grey.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3),
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
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<ExpenseCategory>(
                      value: provider.selectedExpenseCategory,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      decoration: _buildEnhancedInputDecoration(
                        context: context,
                        labelText: 'Select Category',
                        prefixIcon: Icons.category_outlined,
                        isDarkMode: isDarkMode,
                      ),
                      dropdownColor: isDarkMode
                          ? const Color(0xFF2D2D2D)
                          : Colors.white,
                      items: Transaction.getCategoryDisplayNames().entries
                          .map(
                            (entry) => DropdownMenuItem<ExpenseCategory>(
                              value: entry.key,
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (ExpenseCategory? newValue) {
                        if (newValue != null) {
                          provider.setSelectedExpenseCategory(newValue);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Description Field (Enhanced)
            TextFormField(
              controller: _descriptionController,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              decoration: _buildEnhancedInputDecoration(
                context: context,
                labelText: 'Transaction Description',
                hintText: 'e.g., Grocery shopping, Salary payment',
                prefixIcon: Icons.description_outlined,
                isDarkMode: isDarkMode,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Amount Field (Enhanced)
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              decoration: _buildEnhancedInputDecoration(
                context: context,
                labelText: 'Amount',
                hintText: 'Enter amount',
                prefixIcon: Icons.attach_money_outlined,
                isDarkMode: isDarkMode,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Date Selection (Enhanced)
            Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.05),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.grey.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Transaction Date',
                  style: AppTypography.labelMedium.copyWith(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Icon(
                  Icons.edit_calendar_outlined,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  size: 20,
                ),
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
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Enhanced Input Decoration Helper
  InputDecoration _buildEnhancedInputDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    required IconData prefixIcon,
    required bool isDarkMode,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: TextStyle(
        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(prefixIcon, color: AppColors.primaryColor, size: 20),
      ),
      filled: true,
      fillColor: isDarkMode
          ? Colors.grey.withOpacity(0.1)
          : Colors.grey.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDarkMode
              ? Colors.grey.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDarkMode
              ? Colors.grey.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
            color: isSelected
                ? color
                : isDarkMode
                ? Colors.grey.withOpacity(0.3)
                : AppColors.greyLightColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppComponents.smallRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? color
                  : isDarkMode
                  ? Colors.white70
                  : AppColors.greyColor,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected
                    ? color
                    : isDarkMode
                    ? Colors.white70
                    : AppColors.greyDarkColor,
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
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (transactions.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
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

    return Column(
      children: [
        // Transaction list without redundant header
        ...transactions.asMap().entries.map((entry) {
          final index = entry.key;
          final transaction = entry.value;
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: _buildMinimalistTransactionTile(transaction),
              ),
              if (index < transactions.length - 1)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Divider(
                    height: 1,
                    color: AppColors.greyLightColor.withOpacity(0.5),
                  ),
                ),
            ],
          );
        }),

        // Show count indicator at bottom if needed
        if (transactions.length > 5)
          Container(
            margin: const EdgeInsets.only(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              right: AppSpacing.sm,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xs,
              horizontal: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.greyExtraLightColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.greyColor),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Showing ${transactions.length} transactions',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.greyColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Helper method to calculate previous month balance for growth rate
  double _calculatePreviousMonthBalance(CashcardProvider provider) {
    // If showing all time, compare with last month's balance
    if (provider.showAllTime) {
      final now = DateTime.now();
      final previousMonth = DateTime(now.year, now.month - 1);

      double previousBalance = 0.0;
      for (final transaction in provider.transactions) {
        if (transaction.date.year < previousMonth.year ||
            (transaction.date.year == previousMonth.year &&
                transaction.date.month <= previousMonth.month)) {
          if (transaction.type == TransactionType.income) {
            previousBalance += transaction.amount;
          } else {
            previousBalance -= transaction.amount;
          }
        }
      }
      return previousBalance;
    } else {
      // If filtering by specific month/year, compare with previous month
      final currentYear = provider.selectedYear;
      final currentMonth = provider.selectedMonth;

      int previousYear = currentYear;
      int previousMonth = currentMonth - 1;

      if (previousMonth <= 0) {
        previousMonth = 12;
        previousYear = currentYear - 1;
      }

      double previousBalance = 0.0;
      for (final transaction in provider.transactions) {
        if (transaction.date.year < previousYear ||
            (transaction.date.year == previousYear &&
                transaction.date.month <= previousMonth)) {
          if (transaction.type == TransactionType.income) {
            previousBalance += transaction.amount;
          } else {
            previousBalance -= transaction.amount;
          }
        }
      }
      return previousBalance;
    }
  }

  // Combined Financial & Budget Insights Widget
  Widget _buildCombinedInsights(CashcardProvider provider) {
    return Consumer<CashcardProvider>(
      builder: (context, cashcardProvider, child) {
        // Financial metrics
        final totalTransactions = provider.transactions.length;
        final avgDailyExpense = provider.totalExpense / 30;

        // Monthly Growth Rate calculation
        final currentBalance = provider.balance;
        final previousMonthBalance = _calculatePreviousMonthBalance(provider);
        final monthlyGrowthRate = previousMonthBalance > 0
            ? ((currentBalance - previousMonthBalance) /
                  previousMonthBalance *
                  100)
            : 0.0;

        final savingsRate = provider.totalIncome > 0
            ? ((provider.totalIncome - provider.totalExpense) /
                  provider.totalIncome *
                  100)
            : 0.0;

        // Budget metrics
        final budgetCategories = cashcardProvider.budgetCategories;
        final totalBudget = budgetCategories.fold(
          0.0,
          (sum, cat) => sum + cat.budgetAmount,
        );
        final totalSpent = budgetCategories.fold(
          0.0,
          (sum, cat) => sum + cat.spentAmount,
        );
        final overBudgetCount = budgetCategories
            .where((c) => c.isOverBudget)
            .length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Minimalist header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Financial & Budget Overview',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // First row - Core metrics (most important overview)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInsightCard(
                      'Monthly Growth',
                      totalTransactions > 0
                          ? '${monthlyGrowthRate >= 0 ? '+' : ''}${monthlyGrowthRate.toStringAsFixed(1)}%'
                          : 'No Data',
                      Icons.trending_up,
                      totalTransactions > 0
                          ? (monthlyGrowthRate >= 0
                                ? AppColors.successColor
                                : AppColors.errorColor)
                          : AppColors.greyColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
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
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Budget section - if budget is set, show budget-specific insights
            if (budgetCategories.isNotEmpty) ...[
              // Second row - Budget Total and Total Spent
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInsightCard(
                        'Budget Total',
                        'Rp ${_formatNumber(totalBudget)}',
                        Icons.account_balance_wallet,
                        AppColors.successColor,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildInsightCard(
                        'Total Spent',
                        'Rp ${_formatNumber(totalSpent)}',
                        Icons.trending_down,
                        totalSpent > totalBudget
                            ? AppColors.errorColor
                            : AppColors.successColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Third row - Budget performance (remaining and alerts)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInsightCard(
                        'Remaining',
                        'Rp ${_formatNumber(totalBudget - totalSpent)}',
                        Icons.account_balance,
                        totalBudget - totalSpent > 0
                            ? AppColors.successColor
                            : AppColors.errorColor,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildInsightCard(
                        'Over Budget',
                        '$overBudgetCount categories',
                        Icons.warning,
                        overBudgetCount > 0
                            ? AppColors.errorColor
                            : AppColors.successColor,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // If no budget set, show enhanced financial insights
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
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
              ),

              const SizedBox(height: AppSpacing.sm),

              // Third row for non-budget scenario
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInsightCard(
                        'Monthly Growth',
                        totalTransactions > 0
                            ? '${monthlyGrowthRate >= 0 ? '+' : ''}${monthlyGrowthRate.toStringAsFixed(1)}%'
                            : 'No Data',
                        Icons.trending_up,
                        totalTransactions > 0
                            ? (monthlyGrowthRate >= 0
                                  ? AppColors.successColor
                                  : AppColors.errorColor)
                            : AppColors.greyColor,
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
              ),
            ],
          ],
        );
      },
    );
  }

  // Helper method for number formatting with proper currency formatting
  String _formatNumber(double number) {
    // Use proper Indonesian currency formatting with thousand separators
    return NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    ).format(number).trim();
  }

  // Professional Insight Card Widget with Enhanced Colors
  Widget _buildInsightCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Professional color treatment for better visual hierarchy
    final bool isPositiveMetric = _isPositiveMetric(title, value);
    final cardColor = _getOptimizedCardColor(color, isPositiveMetric);

    return Container(
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
                ? Colors.black.withOpacity(0.3)
                : AppColors.greyColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced header with premium icon treatment
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: cardColor, size: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.greyDarkColor,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Enhanced value with professional typography
          Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              color: cardColor,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Helper method to determine if metric is positive/neutral/negative
  bool _isPositiveMetric(String title, String value) {
    // Positive indicators
    if (title.contains('Savings Rate') && value.contains('%')) {
      final rate = double.tryParse(value.replaceAll('%', '')) ?? 0;
      return rate >= 20;
    }
    if (title.contains('Monthly Growth') && value.contains('%')) {
      final rate =
          double.tryParse(value.replaceAll('%', '').replaceAll('+', '')) ?? 0;
      return rate >= 0;
    }
    if (title.contains('Remaining') && value.contains('Rp')) {
      return !value.contains('-');
    }
    if (title.contains('Balance Status')) {
      return value.contains('Positive');
    }
    if (title.contains('Over Budget')) {
      return value.contains('0 categories');
    }

    // Neutral indicators
    if (title.contains('Budget Total') || title.contains('Daily Average')) {
      return true; // Neutral, use primary color
    }

    return true; // Default to neutral
  }

  // Optimized color selection based on metric context
  Color _getOptimizedCardColor(Color originalColor, bool isPositive) {
    // If already using semantic colors, keep them
    if (originalColor == AppColors.successColor ||
        originalColor == AppColors.errorColor) {
      return originalColor;
    }

    // Enhanced primary color for neutral metrics
    if (originalColor == AppColors.primaryColor ||
        originalColor == AppColors.infoColor) {
      return AppColors.primaryColor;
    }

    // Enhanced warning color
    if (originalColor == AppColors.warningColor) {
      return AppColors.warningColor;
    }

    return originalColor;
  }

  // Minimalist Transaction Tile Widget
  Widget _buildMinimalistTransactionTile(Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Minimalist transaction icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isIncome
                  ? AppColors.successColor.withOpacity(0.1)
                  : AppColors.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIncome ? Icons.trending_up : Icons.trending_down,
              color: isIncome ? AppColors.successColor : AppColors.errorColor,
              size: 18,
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

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
                      DateFormat('dd MMM').format(transaction.date),
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
                        child: Text(
                          transaction.getCategoryDisplayName(),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primaryColor.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Amount with minimalist design
          Text(
            '${isIncome ? '+' : '-'}${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(transaction.amount)}',
            style: AppTypography.titleSmall.copyWith(
              color: isIncome ? AppColors.successColor : AppColors.errorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cashcardProvider = Provider.of<CashcardProvider>(context);
    final transactions = cashcardProvider.transactions;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF1A1A1A)
          : Theme.of(context).colorScheme.surface,
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
          // Add Transaction Button
          ActionButton(
            icon: Icons.add_rounded,
            onPressed: () => _showAddTransactionModal(context),
            tooltip: 'Tambah Transaksi',
            color: AppColors.successColor,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
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
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Budget Notification - Contextual alert (minimal spacing)
            const BudgetNotificationWidget(),
            const SizedBox(height: AppSpacing.sm),

            // Financial Card - Primary hero element (generous spacing)
            _buildPremiumFinancialCard(
              context,
              cashcardProvider.balance,
              cashcardProvider.totalIncome,
              cashcardProvider.totalExpense,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Combined Insights - Secondary information (moderate spacing)
            _buildCombinedInsights(cashcardProvider),
            const SizedBox(height: AppSpacing.md),

            // Transaction Activity Header - Modern contextual title
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.history, color: AppColors.primaryColor, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Transaction Activity (${cashcardProvider.showAllTime ? 'All Time' : '$_selectedMonth $_selectedYear'})',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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
    return const EnhancedBudgetManagement();
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
