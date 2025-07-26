import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:clarity/features/cashcard/domain/entities/transaction.dart'
    as entity;
import 'package:clarity/utils/design_system/app_colors.dart';
import 'package:clarity/utils/design_system/app_spacing.dart';
import 'package:clarity/utils/design_system/app_typography.dart';
import 'package:clarity/utils/design_system/app_components.dart';
import 'package:clarity/utils/navigation_helper_v2.dart' as nav;

class ExportFunctions extends StatelessWidget {
  final List<entity.Transaction> transactions;
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2D2D2D)
            : Colors.white, // Gunakan putih murni untuk export functions
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(
          color: isDarkMode
              ? Colors.grey.withOpacity(0.3)
              : AppColors.greyLightColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(
                    0.1,
                  ), // Shadow lebih gelap untuk export functions
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
                  color: isDarkMode ? Colors.white : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            'Generate detailed reports of your financial activities',
            style: AppTypography.bodyMedium.copyWith(
              color: isDarkMode ? Colors.white70 : AppColors.greyColor,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppComponents.smallRadius),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDarkMode ? color.withOpacity(0.1) : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppComponents.smallRadius),
          border: Border.all(
            color: isDarkMode ? color.withOpacity(0.4) : color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? color.withOpacity(0.2)
                    : color.withOpacity(0.1),
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
                      color: isDarkMode ? Colors.white : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDarkMode ? Colors.white70 : AppColors.greyColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDarkMode ? Colors.white70 : AppColors.greyColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportFormats(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Formats',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : null,
          ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppComponents.smallRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? color.withOpacity(0.15) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppComponents.smallRadius),
          border: Border.all(
            color: isDarkMode ? color.withOpacity(0.5) : color.withOpacity(0.3),
            width: 1,
          ),
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
    _generatePDFAsync(context, 'Monthly Statement', _buildMonthlyStatementPDF);
  }

  void _exportTransactionHistory(BuildContext context) {
    _generatePDFAsync(
      context,
      'Transaction History',
      _buildTransactionHistoryPDF,
    );
  }

  void _exportBudgetReport(BuildContext context) {
    _generatePDFAsync(context, 'Budget Report', _buildBudgetReportPDF);
  }

  void _exportTaxSummary(BuildContext context) {
    _generatePDFAsync(context, 'Tax Summary', _buildTaxSummaryPDF);
  }

  void _showExportDialog(BuildContext context, String format) {
    nav.NavigationHelper.safeShowDialog(
      context: context,
      dialogId: 'export_dialog_$format',
      builder: (dialogContext) {
        final isDarkMode =
            Theme.of(dialogContext).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDarkMode
              ? const Color(0xFF2D2D2D)
              : Colors.white, // Gunakan putih murni untuk export dialog
          title: Text(
            'Export as $format',
            style: TextStyle(color: isDarkMode ? Colors.white : null),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select the type of report to export:',
                style: TextStyle(color: isDarkMode ? Colors.white70 : null),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildDialogOption('Monthly Statement', () {
                Navigator.of(dialogContext).pop();
                _exportMonthlyStatement(context);
              }),
              _buildDialogOption('Transaction History', () {
                Navigator.of(dialogContext).pop();
                _exportTransactionHistory(context);
              }),
              _buildDialogOption('Budget Report', () {
                Navigator.of(dialogContext).pop();
                _exportBudgetReport(context);
              }),
              _buildDialogOption('Tax Summary', () {
                Navigator.of(dialogContext).pop();
                _exportTaxSummary(context);
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: isDarkMode ? Colors.white70 : null),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogOption(String title, VoidCallback onTap) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey.withOpacity(0.2)
                  : Colors.grey.withOpacity(
                      0.05,
                    ), // Background lebih subtle untuk dialog option
              borderRadius: BorderRadius.circular(AppComponents.smallRadius),
            ),
            child: Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                color: isDarkMode ? Colors.white : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _generatePDFAsync(
    BuildContext context,
    String title,
    pw.Widget Function() buildContent,
  ) async {
    if (!context.mounted) return;

    // Show a simple snackbar for loading feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Text('Generating $title PDF...'),
          ],
        ),
        duration: const Duration(seconds: 30), // Will be dismissed manually
        backgroundColor: AppColors.primaryColor,
      ),
    );

    try {
      // Generate PDF in background with timeout
      final pdf = await _generatePDFDocument(buildContent).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('PDF generation timed out. Please try again.');
        },
      );

      // Dismiss loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (!context.mounted) return;

      // Show PDF preview
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name:
            '${title.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
      );

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title PDF generated successfully!'),
            backgroundColor: AppColors.successColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Dismiss loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<pw.Document> _generatePDFDocument(
    pw.Widget Function() buildContent,
  ) async {
    // Use compute or Future to ensure this doesn't block the UI
    return await Future.microtask(() {
      try {
        final pdf = pw.Document();

        // Generate content with error handling
        final content = buildContent();

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            build: (context) => [content],
          ),
        );

        return pdf;
      } catch (e) {
        // If content generation fails, create a simple error PDF
        final errorPdf = pw.Document();
        errorPdf.addPage(
          pw.Page(
            build: (context) => pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Error Generating Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'An error occurred while generating the PDF content.',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Error: ${e.toString()}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        );
        return errorPdf;
      }
    });
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

        // Recent Transactions (Limited to prevent performance issues)
        pw.Text(
          'Recent Transactions (Last 50)',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),

        _buildTransactionTable(transactions.take(50).toList()),
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
                  '${transactions.where((t) => t.type == entity.TransactionType.income).length}',
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
                  '${transactions.where((t) => t.type == entity.TransactionType.expense).length}',
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

        // All Transactions (Limited to prevent performance issues)
        pw.Text(
          'Transaction History (Last 100 transactions)',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),

        _buildTransactionTable(transactions.take(100).toList()),
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
                '• Largest expense: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(transactions.where((t) => t.type == entity.TransactionType.expense).isEmpty ? 0 : transactions.where((t) => t.type == entity.TransactionType.expense).map((t) => t.amount).reduce((a, b) => a > b ? a : b))}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTaxSummaryPDF() {
    final incomeTransactions = transactions
        .where((t) => t.type == entity.TransactionType.income)
        .toList();
    final expenseTransactions = transactions
        .where((t) => t.type == entity.TransactionType.expense)
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

        _buildMonthlyIncomeTable(incomeTransactions),

        pw.SizedBox(height: 24),

        // Expense Summary
        pw.Text(
          'Deductible Expenses',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),

        _buildCategoryExpenseTable(expenseTransactions),

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

  // Helper method to build monthly income table
  pw.Widget _buildMonthlyIncomeTable(
    List<entity.Transaction> incomeTransactions,
  ) {
    final data = _getMonthlyIncomeSummary(incomeTransactions);
    return pw.Table.fromTextArray(
      headers: ['Month', 'Total Income'],
      data: data,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellPadding: const pw.EdgeInsets.all(6),
    );
  }

  // Helper method to build category expense table
  pw.Widget _buildCategoryExpenseTable(
    List<entity.Transaction> expenseTransactions,
  ) {
    final data = _getCategoryExpenseSummary(expenseTransactions);
    return pw.Table.fromTextArray(
      headers: ['Category', 'Total Amount'],
      data: data,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellPadding: const pw.EdgeInsets.all(6),
    );
  }

  List<List<String>> _getMonthlyIncomeSummary(
    List<entity.Transaction> incomeTransactions,
  ) {
    if (incomeTransactions.isEmpty) {
      return [
        ['No Data', 'Rp 0'],
      ];
    }

    final monthlyIncome = <int, double>{};

    // Optimize: Use a more efficient iteration
    for (final transaction in incomeTransactions) {
      final month = transaction.date.month;
      monthlyIncome[month] = (monthlyIncome[month] ?? 0) + transaction.amount;
    }

    // Sort by month and limit results if too many
    final sortedEntries = monthlyIncome.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sortedEntries
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
    List<entity.Transaction> expenseTransactions,
  ) {
    if (expenseTransactions.isEmpty) {
      return [
        ['No Data', 'Rp 0'],
      ];
    }

    final categoryExpenses = <String, double>{};

    // Optimize: Use a more efficient iteration and caching
    final categoryCache = <String, String>{};

    for (final transaction in expenseTransactions) {
      final description = transaction.description;
      final category = categoryCache[description] ??=
          _getCategoryFromDescription(description);
      categoryExpenses[category] =
          (categoryExpenses[category] ?? 0) + transaction.amount;
    }

    // Sort by amount (descending) and limit if necessary
    final sortedEntries = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries
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

    // Use a more efficient approach with early returns
    if (_containsAny(lowerDesc, [
      'food',
      'makan',
      'lunch',
      'dinner',
      'restaurant',
      'cafe',
    ])) {
      return 'Food & Dining';
    }

    if (_containsAny(lowerDesc, [
      'transport',
      'gas',
      'fuel',
      'bensin',
      'ojek',
      'grab',
      'gojek',
    ])) {
      return 'Transportation';
    }

    if (_containsAny(lowerDesc, [
      'shop',
      'buy',
      'beli',
      'belanja',
      'store',
      'mall',
    ])) {
      return 'Shopping';
    }

    if (_containsAny(lowerDesc, [
      'health',
      'medical',
      'hospital',
      'dokter',
      'obat',
      'pharmacy',
    ])) {
      return 'Healthcare';
    }

    if (_containsAny(lowerDesc, [
      'entertainment',
      'movie',
      'game',
      'hiburan',
      'cinema',
      'netflix',
    ])) {
      return 'Entertainment';
    }

    if (_containsAny(lowerDesc, [
      'utility',
      'bill',
      'listrik',
      'air',
      'internet',
      'phone',
      'telpon',
    ])) {
      return 'Utilities';
    }

    if (_containsAny(lowerDesc, [
      'education',
      'school',
      'course',
      'book',
      'sekolah',
      'kursus',
    ])) {
      return 'Education';
    }

    return 'Others';
  }

  // Helper method for efficient string contains checking
  bool _containsAny(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  // Helper method to build transaction table efficiently
  pw.Widget _buildTransactionTable(List<entity.Transaction> transactionList) {
    // Chunk the data to prevent memory issues
    const int maxRowsPerPage = 30;

    if (transactionList.length <= maxRowsPerPage) {
      return pw.Table.fromTextArray(
        headers: ['Date', 'Description', 'Type', 'Amount'],
        data: transactionList.map(_transactionToTableRow).toList(),
        border: pw.TableBorder.all(),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        cellAlignment: pw.Alignment.centerLeft,
        cellPadding: const pw.EdgeInsets.all(4),
      );
    }

    // For larger datasets, create multiple tables
    return pw.Column(
      children: [
        for (int i = 0; i < transactionList.length; i += maxRowsPerPage)
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            child: pw.Table.fromTextArray(
              headers: i == 0
                  ? ['Date', 'Description', 'Type', 'Amount']
                  : null,
              data: transactionList
                  .skip(i)
                  .take(maxRowsPerPage)
                  .map(_transactionToTableRow)
                  .toList(),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(4),
            ),
          ),
      ],
    );
  }

  // Helper method to convert transaction to table row
  List<String> _transactionToTableRow(entity.Transaction transaction) {
    return [
      DateFormat('dd/MM/yyyy').format(transaction.date),
      transaction.description.length > 30
          ? '${transaction.description.substring(0, 30)}...'
          : transaction.description,
      transaction.type == entity.TransactionType.income ? 'Income' : 'Expense',
      NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(transaction.amount),
    ];
  }
}
