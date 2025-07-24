import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/cashcard/presentation/provider/cashcard_provider.dart';
import 'package:myapp/features/cashcard/domain/entities/transaction.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:myapp/utils/app_colors.dart'; // Import AppColors

class CashcardPage extends StatefulWidget {
  const CashcardPage({super.key});

  @override
  State<CashcardPage> createState() => _CashcardPageState();
}

class _CashcardPageState extends State<CashcardPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  // Removed _selectedType, will use provider instead
  DateTime _selectedDate = DateTime.now();

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

  Future<void> _selectDate(BuildContext context) async {
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
  }

  void _addTransaction(BuildContext context) {
    // Pass context to access provider
    if (_descriptionController.text.isNotEmpty &&
        _amountController.text.isNotEmpty) {
      final description = _descriptionController.text;
      final amount = double.tryParse(_amountController.text);

      if (amount != null) {
        // Get selected type from provider
        final selectedType =
            Provider.of<CashcardProvider>(
              context,
              listen: false,
            ).selectedTransactionType;

        final newTransaction = Transaction(
          id: DateTime.now().toString(), // Simple ID generation
          description: description,
          amount: amount,
          type: selectedType, // Use selectedType from provider
          date: _selectedDate,
        );

        Provider.of<CashcardProvider>(
          context,
          listen: false,
        ).addTransaction(newTransaction);

        // Clear the form and reset selected type in provider
        _descriptionController.clear();
        _amountController.clear();
        // Reset selected type in provider
        Provider.of<CashcardProvider>(
          context,
          listen: false,
        ).setSelectedTransactionType(TransactionType.expense);

        // Close the modal after adding the transaction
        Navigator.pop(context);
      }
    }
  }

  // Method to generate a list of years for the dropdown (e.g., current year +/- 5)
  List<int> _getYearsList() {
    final currentYear = DateTime.now().year;
    return List.generate(11, (index) => currentYear - 5 + index);
  }

  // Method to show the add transaction bottom modal
  void _showAddTransactionModal(BuildContext context) {
    // Get provider here to access selectedTransactionType for initial value
    Provider.of<CashcardProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the modal to take up almost full height
      builder: (BuildContext context) {
        // Use Consumer to rebuild just the radio buttons when selectedTransactionType changes
        return Consumer<CashcardProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // Make the column take minimum space
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Add New Transaction',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _amountController,
                        decoration: const InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: const Text('Expense'),
                              leading: Radio<TransactionType>(
                                value: TransactionType.expense,
                                groupValue:
                                    provider
                                        .selectedTransactionType, // Use provider state
                                onChanged: (TransactionType? value) {
                                  if (value != null) {
                                    provider.setSelectedTransactionType(
                                      value,
                                    ); // Update provider state
                                  }
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: const Text('Income'),
                              leading: Radio<TransactionType>(
                                value: TransactionType.income,
                                groupValue:
                                    provider
                                        .selectedTransactionType, // Use provider state
                                onChanged: (TransactionType? value) {
                                  if (value != null) {
                                    provider.setSelectedTransactionType(
                                      value,
                                    ); // Update provider state
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                            ),
                          ),
                          TextButton(
                            onPressed: () => _selectDate(context),
                            child: const Text('Select Date'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed:
                            () => _addTransaction(context), // Pass context
                        child: const Text('Add Transaction'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // New widget for the credit card summary design
  Widget _buildCreditCardSummary(
    BuildContext context,
    double balance,
    double income,
    double expense,
  ) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent], // Example gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              (255 * 0.2).round(),
            ), // Using withAlpha
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 5),
          Text(
            balance.toStringAsFixed(2),
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Income',
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall!.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    income.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expense',
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall!.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    expense.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cashcardProvider = Provider.of<CashcardProvider>(context);
    final transactions = cashcardProvider.transactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashcard'),
        actions: [
          // Month filter dropdown
          DropdownButton<String>(
            value: _selectedMonth,
            items:
                _months.map((String month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedMonth = newValue;
                  if (newValue == 'All Time') {
                    cashcardProvider.setShowAllTime(true);
                  } else {
                    // Find the 1-based month index
                    // Adjust index for 0-based _months list (excluding 'All Time')
                    final monthIndex = _months.indexOf(newValue);
                    cashcardProvider.setFilter(monthIndex, _selectedYear);
                  }
                });
              }
            },
          ),
          // Year filter dropdown (only visible when not showing All Time)
          if (!cashcardProvider
              .showAllTime) // Only show year dropdown if not showing All Time
            DropdownButton<int>(
              value: _selectedYear,
              items:
                  _years.map((int year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedYear = newValue;
                    // Adjust index for 0-based _months list (excluding 'All Time')
                    final monthIndex = _months.indexOf(_selectedMonth);
                    cashcardProvider.setFilter(monthIndex, _selectedYear);
                  });
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Displaying Income, Expense, and Balance in a single credit card like widget
            _buildCreditCardSummary(
              context,
              cashcardProvider.balance,
              cashcardProvider.totalIncome,
              cashcardProvider.totalExpense,
            ),
            const SizedBox(height: 20),
            Text(
              'Transactions (${cashcardProvider.showAllTime ? 'All Time' : '$_selectedMonth $_selectedYear'})',
              style: Theme.of(context).textTheme.titleLarge,
            ), // Display selected period
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final isIncome = transaction.type == TransactionType.income;
                  final amountColor =
                      isIncome ? AppColors.successColor : AppColors.errorColor;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).cardColor, // Use theme's card color
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(
                            0.1,
                          ), // Use theme's shadow color
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icon based on transaction type
                        Icon(
                          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: amountColor,
                          size: 28.0,
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Transaction description
                              Text(
                                transaction.description,
                                style: Theme.of(context).textTheme.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4.0),
                              // Transaction date
                              Text(
                                DateFormat(
                                  'yyyy-MM-dd',
                                ).format(transaction.date),
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall!.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        // Transaction amount
                        Text(
                          '${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(2)}',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium!.copyWith(
                            color: amountColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionModal(context),
        tooltip: 'Add New Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Removed the old _buildSummaryCard method
  // Widget _buildSummaryCard(String title, double amount, Color color) {
  //   ...
  // }
}
