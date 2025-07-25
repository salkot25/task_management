import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:myapp/features/cashcard/domain/entities/transaction.dart';
import 'package:myapp/utils/design_system/app_colors.dart';
import 'package:myapp/utils/design_system/app_spacing.dart';
import 'package:myapp/utils/design_system/app_typography.dart';
import 'package:myapp/utils/design_system/app_components.dart';

class ExportFunctions extends StatelessWidget {
  final List<Transaction> transactions;
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const ExportFunctions({
    super.key,
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
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
                Icons.file_download,
                color: AppColors.primaryColor,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Export Financial Data',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            'Generate detailed reports of your financial activities',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.greyColor,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Export Options
          _buildExportOption(
            context,
            'Monthly Statement',
            'Complete monthly financial summary with charts',
            Icons.description,
            AppColors.primaryColor,
            () => _exportMonthlyStatement(context),
          ),

          const SizedBox(height: AppSpacing.sm),

          _buildExportOption(
            context,
            'Transaction History',
            'Detailed list of all transactions',
            Icons.list_alt,
            AppColors.successColor,
            () => _exportTransactionHistory(context),
          ),

          const SizedBox(height: AppSpacing.sm),

          _buildExportOption(
            context,
            'Budget Report',
            'Budget analysis and spending insights',
            Icons.bar_chart,
            AppColors.warningColor,
            () => _exportBudgetReport(context),
          ),

          const SizedBox(height: AppSpacing.sm),

          _buildExportOption(
            context,
            'Tax Summary',
            'Income and expense summary for tax purposes',
            Icons.receipt_long,
            AppColors.infoColor,
            () => _exportTaxSummary(context),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Export Format Options
          _buildExportFormats(context),
        ],
      ),
    );
  }

  Widget _buildExportOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppComponents.smallRadius),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppComponents.smallRadius),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppComponents.smallRadius),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.greyColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.greyColor),
          ],
        ),
      ),
    );
  }

  Widget _buildExportFormats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Formats',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildFormatButton(
                context,
                'PDF',
                Icons.picture_as_pdf,
                AppColors.errorColor,
                () => _showExportDialog(context, 'PDF'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildFormatButton(
                context,
                'Excel',
                Icons.table_chart,
                AppColors.successColor,
                () => _showExportDialog(context, 'Excel'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildFormatButton(
                context,
                'CSV',
                Icons.insert_drive_file,
                AppColors.warningColor,
                () => _showExportDialog(context, 'CSV'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatButton(
    BuildContext context,
    String format,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppComponents.smallRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppComponents.smallRadius),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.xs),
            Text(
              format,
              style: AppTypography.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportMonthlyStatement(BuildContext context) {
    _generatePDF(context, 'Monthly Statement', _buildMonthlyStatementPDF);
  }

  void _exportTransactionHistory(BuildContext context) {
    _generatePDF(context, 'Transaction History', _buildTransactionHistoryPDF);
  }

  void _exportBudgetReport(BuildContext context) {
    _generatePDF(context, 'Budget Report', _buildBudgetReportPDF);
  }

  void _exportTaxSummary(BuildContext context) {
    _generatePDF(context, 'Tax Summary', _buildTaxSummaryPDF);
  }

  void _showExportDialog(BuildContext context, String format) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export as $format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select the type of report to export:'),
            const SizedBox(height: AppSpacing.md),
            _buildDialogOption('Monthly Statement', () {
              Navigator.pop(context);
              _exportMonthlyStatement(context);
            }),
            _buildDialogOption('Transaction History', () {
              Navigator.pop(context);
              _exportTransactionHistory(context);
            }),
            _buildDialogOption('Budget Report', () {
              Navigator.pop(context);
              _exportBudgetReport(context);
            }),
            _buildDialogOption('Tax Summary', () {
              Navigator.pop(context);
              _exportTaxSummary(context);
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogOption(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.sm),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.greyExtraLightColor,
          borderRadius: BorderRadius.circular(AppComponents.smallRadius),
        ),
        child: Text(title, style: AppTypography.bodyMedium),
      ),
    );
  }

  Future<void> _generatePDF(
    BuildContext context,
    String title,
    pw.Widget Function() buildContent,
  ) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [buildContent()],
        ),
      );

      // Hide loading
      Navigator.pop(context);

      // Show PDF preview
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: '${title}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      Navigator.pop(context); // Hide loading if still showing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  pw.Widget _buildMonthlyStatementPDF() {
    final currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Monthly Financial Statement',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(currentMonth, style: pw.TextStyle(fontSize: 16)),
              ],
            ),
            pw.Text(
              'Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 10),
            ),
          ],
        ),

        pw.SizedBox(height: 32),

        // Financial Summary
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Financial Summary',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Income:'),
                  pw.Text(
                    NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(totalIncome),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Expense:'),
                  pw.Text(
                    NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(totalExpense),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Net Balance:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(balance),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: balance >= 0 ? PdfColors.green : PdfColors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 24),

        // Recent Transactions
        pw.Text(
          'Recent Transactions',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),

        pw.Table.fromTextArray(
          headers: ['Date', 'Description', 'Type', 'Amount'],
          data: transactions
              .take(20)
              .map(
                (t) => [
                  DateFormat('dd/MM/yyyy').format(t.date),
                  t.description,
                  t.type == TransactionType.income ? 'Income' : 'Expense',
                  NumberFormat.currency(
                    locale: 'id',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(t.amount),
                ],
              )
              .toList(),
          border: pw.TableBorder.all(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
        ),
      ],
    );
  }

  pw.Widget _buildTransactionHistoryPDF() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Text(
          'Transaction History',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          style: pw.TextStyle(fontSize: 12),
        ),

        pw.SizedBox(height: 32),

        // Summary
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            pw.Column(
              children: [
                pw.Text('Total Transactions'),
                pw.Text(
                  '${transactions.length}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.Column(
              children: [
                pw.Text('Income Transactions'),
                pw.Text(
                  '${transactions.where((t) => t.type == TransactionType.income).length}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green,
                  ),
                ),
              ],
            ),
            pw.Column(
              children: [
                pw.Text('Expense Transactions'),
                pw.Text(
                  '${transactions.where((t) => t.type == TransactionType.expense).length}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red,
                  ),
                ),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 32),

        // All Transactions
        pw.Table.fromTextArray(
          headers: ['Date', 'Description', 'Type', 'Amount'],
          data: transactions
              .map(
                (t) => [
                  DateFormat('dd/MM/yyyy').format(t.date),
                  t.description,
                  t.type == TransactionType.income ? 'Income' : 'Expense',
                  NumberFormat.currency(
                    locale: 'id',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(t.amount),
                ],
              )
              .toList(),
          border: pw.TableBorder.all(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
        ),
      ],
    );
  }

  pw.Widget _buildBudgetReportPDF() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Budget Analysis Report',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          style: pw.TextStyle(fontSize: 12),
        ),

        pw.SizedBox(height: 32),

        // Spending Analysis
        pw.Text(
          'Spending Analysis',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),

        pw.Text(
          'This report provides insights into your spending patterns and budget performance.',
        ),
        pw.SizedBox(height: 16),

        // Key Metrics
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Key Metrics',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '• Average daily expense: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalExpense / 30)}',
              ),
              pw.Text(
                '• Savings rate: ${totalIncome > 0 ? ((totalIncome - totalExpense) / totalIncome * 100).toStringAsFixed(1) : 0}%',
              ),
              pw.Text(
                '• Largest expense: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(transactions.where((t) => t.type == TransactionType.expense).isEmpty ? 0 : transactions.where((t) => t.type == TransactionType.expense).map((t) => t.amount).reduce((a, b) => a > b ? a : b))}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTaxSummaryPDF() {
    final incomeTransactions = transactions
        .where((t) => t.type == TransactionType.income)
        .toList();
    final expenseTransactions = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Tax Summary Report',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Tax Year: ${DateTime.now().year}',
          style: pw.TextStyle(fontSize: 16),
        ),
        pw.Text(
          'Generated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          style: pw.TextStyle(fontSize: 12),
        ),

        pw.SizedBox(height: 32),

        // Income Summary
        pw.Text(
          'Income Summary',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),

        pw.Table.fromTextArray(
          headers: ['Month', 'Total Income'],
          data: _getMonthlyIncomeSummary(incomeTransactions),
          border: pw.TableBorder.all(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),

        pw.SizedBox(height: 24),

        // Expense Summary
        pw.Text(
          'Deductible Expenses',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),

        pw.Table.fromTextArray(
          headers: ['Category', 'Total Amount'],
          data: _getCategoryExpenseSummary(expenseTransactions),
          border: pw.TableBorder.all(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),

        pw.SizedBox(height: 24),

        // Total Summary
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Income:'),
                  pw.Text(
                    NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(totalIncome),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Expenses:'),
                  pw.Text(
                    NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(totalExpense),
                  ),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Net Income:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(balance),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<List<String>> _getMonthlyIncomeSummary(
    List<Transaction> incomeTransactions,
  ) {
    final monthlyIncome = <int, double>{};

    for (final transaction in incomeTransactions) {
      final month = transaction.date.month;
      monthlyIncome[month] = (monthlyIncome[month] ?? 0) + transaction.amount;
    }

    return monthlyIncome.entries
        .map(
          (entry) => [
            DateFormat('MMMM').format(DateTime(0, entry.key)),
            NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(entry.value),
          ],
        )
        .toList();
  }

  List<List<String>> _getCategoryExpenseSummary(
    List<Transaction> expenseTransactions,
  ) {
    final categoryExpenses = <String, double>{};

    for (final transaction in expenseTransactions) {
      final category = _getCategoryFromDescription(transaction.description);
      categoryExpenses[category] =
          (categoryExpenses[category] ?? 0) + transaction.amount;
    }

    return categoryExpenses.entries
        .map(
          (entry) => [
            entry.key,
            NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(entry.value),
          ],
        )
        .toList();
  }

  String _getCategoryFromDescription(String description) {
    final lowerDesc = description.toLowerCase();

    if (lowerDesc.contains('food') ||
        lowerDesc.contains('makan') ||
        lowerDesc.contains('lunch') ||
        lowerDesc.contains('dinner')) {
      return 'Food & Dining';
    } else if (lowerDesc.contains('transport') ||
        lowerDesc.contains('gas') ||
        lowerDesc.contains('fuel') ||
        lowerDesc.contains('bensin')) {
      return 'Transportation';
    } else if (lowerDesc.contains('shop') ||
        lowerDesc.contains('buy') ||
        lowerDesc.contains('beli') ||
        lowerDesc.contains('belanja')) {
      return 'Shopping';
    } else if (lowerDesc.contains('health') ||
        lowerDesc.contains('medical') ||
        lowerDesc.contains('hospital') ||
        lowerDesc.contains('dokter')) {
      return 'Healthcare';
    } else if (lowerDesc.contains('entertainment') ||
        lowerDesc.contains('movie') ||
        lowerDesc.contains('game') ||
        lowerDesc.contains('hiburan')) {
      return 'Entertainment';
    } else if (lowerDesc.contains('utility') ||
        lowerDesc.contains('bill') ||
        lowerDesc.contains('listrik') ||
        lowerDesc.contains('air')) {
      return 'Utilities';
    } else {
      return 'Others';
    }
  }
}
