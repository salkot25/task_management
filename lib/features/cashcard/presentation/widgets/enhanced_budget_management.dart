import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:clarity/utils/design_system/app_colors.dart';
import 'package:clarity/utils/design_system/app_spacing.dart';
import 'package:clarity/utils/design_system/app_typography.dart';
import 'package:clarity/utils/design_system/app_components.dart';
import 'package:clarity/features/cashcard/presentation/provider/cashcard_provider.dart';
import 'package:clarity/features/cashcard/domain/entities/budget_models.dart';
import 'package:clarity/features/cashcard/domain/entities/transaction.dart';

class EnhancedBudgetManagement extends StatefulWidget {
  const EnhancedBudgetManagement({super.key});

  @override
  State<EnhancedBudgetManagement> createState() =>
      _EnhancedBudgetManagementState();
}

class _EnhancedBudgetManagementState extends State<EnhancedBudgetManagement>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  int _hoveredTabIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<CashcardProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Enhanced Custom Tab Bar with Better Hover Effects
            const SizedBox(height: AppSpacing.lg),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF2D2D2D)
                    : Colors.white, // Gunakan putih murni untuk tab bar
                borderRadius: AppComponents.standardBorderRadius,
                border: Border.all(
                  color: isDarkMode
                      ? Colors.grey.withOpacity(0.2)
                      : AppColors.greyLightColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.4)
                        : Colors.black.withOpacity(
                            0.08,
                          ), // Shadow lebih gelap untuk tab bar
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: -1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildCustomTab('Overview', 0),
                  _buildCustomTab('Categories', 1),
                  _buildCustomTab('Alerts', 2),
                  _buildCustomTab('Insights', 3),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(provider),
                  _buildCategoriesTab(provider),
                  _buildAlertsTab(provider),
                  _buildInsightsTab(provider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomTab(String title, int index) {
    final isSelected = _currentTabIndex == index;
    final isHovered = _hoveredTabIndex == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredTabIndex = index),
        onExit: (_) => setState(() => _hoveredTabIndex = -1),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _tabController.animateTo(index);
              setState(() => _currentTabIndex = index);
            },
            borderRadius: AppComponents.standardBorderRadius,
            splashColor: AppColors.primaryColor.withOpacity(0.2),
            highlightColor: AppColors.primaryColor.withOpacity(0.1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm + 2,
                horizontal: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor
                    : isHovered
                    ? AppColors.primaryColor.withOpacity(0.08)
                    : Colors.transparent,
                borderRadius: AppComponents.standardBorderRadius,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ]
                    : isHovered
                    ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
                border: isHovered && !isSelected
                    ? Border.all(
                        color: AppColors.primaryColor.withOpacity(0.4),
                        width: 1.5,
                      )
                    : null,
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: (isSelected
                      ? AppTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        )
                      : isHovered
                      ? AppTypography.bodySmall.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        )
                      : AppTypography.bodySmall.copyWith(
                          color: isDarkMode
                              ? Colors.white70
                              : AppColors.greyColor,
                          fontWeight: FontWeight.w400,
                        )),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: isSelected
                        ? 1.05
                        : isHovered
                        ? 1.02
                        : 1.0,
                    child: Text(title, textAlign: TextAlign.center),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(CashcardProvider provider) {
    final totalBudget = provider.budgetCategories.fold(
      0.0,
      (sum, cat) => sum + cat.budgetAmount,
    );
    final totalSpent = provider.budgetCategories.fold(
      0.0,
      (sum, cat) => sum + cat.spentAmount,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // Overall Budget Card
          _buildOverallBudgetCard(totalBudget, totalSpent),
          const SizedBox(height: AppSpacing.lg),

          // Budget Progress Summary
          _buildBudgetProgressSummary(provider),
          const SizedBox(height: AppSpacing.lg),

          // Quick Actions
          _buildQuickActions(provider),
          const SizedBox(height: AppSpacing.lg),

          // Recent Budget Activities
          _buildRecentActivities(provider),
        ],
      ),
    );
  }

  Widget _buildQuickActions(CashcardProvider provider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2D2D2D)
            : Colors.white, // Gunakan putih murni untuk quick actions
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(
          color: isDarkMode
              ? Colors.grey.withOpacity(0.2)
              : AppColors.greyLightColor,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(
                    0.1,
                  ), // Shadow lebih gelap untuk quick actions
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : null,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Auto Create',
                  Icons.auto_fix_high,
                  AppColors.primaryColor,
                  () => provider.autoCreateBudgetCategories(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildQuickActionButton(
                  'Reset Month',
                  Icons.refresh,
                  AppColors.warningColor,
                  () => _showResetDialog(provider),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppComponents.smallRadius),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallBudgetCard(double totalBudget, double totalSpent) {
    final remaining = totalBudget - totalSpent;
    final progress = totalBudget > 0 ? totalSpent / totalBudget : 0.0;
    final isOverBudget = totalSpent > totalBudget;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: AppComponents.standardBorderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Monthly Budget Overview',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Budget amounts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBudgetMetric(
                'Total Budget',
                NumberFormat.currency(
                  locale: 'id',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(totalBudget),
                Colors.white,
              ),
              _buildBudgetMetric(
                isOverBudget ? 'Over Budget' : 'Remaining',
                NumberFormat.currency(
                  locale: 'id',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(remaining.abs()),
                isOverBudget ? AppColors.warningColor : Colors.white,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Progress visualization
          _buildProgressVisualization(progress, totalSpent, isOverBudget),
        ],
      ),
    );
  }

  Widget _buildBudgetMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressVisualization(
    double progress,
    double totalSpent,
    bool isOverBudget,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Spent: ${(progress * 100).toStringAsFixed(1)}%',
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            Text(
              NumberFormat.currency(
                locale: 'id',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(totalSpent),
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (progress > 1.0 ? 1.0 : progress),
            child: Container(
              decoration: BoxDecoration(
                color: isOverBudget ? AppColors.errorColor : Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetProgressSummary(CashcardProvider provider) {
    final categories = provider.budgetCategories;
    final onTrackCount = categories.where((c) => !c.isOverBudget).length;
    final overBudgetCount = categories.where((c) => c.isOverBudget).length;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2D2D2D)
            : Colors.white, // Gunakan putih murni untuk budget progress summary
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(
          color: isDarkMode
              ? Colors.grey.withOpacity(0.2)
              : AppColors.greyLightColor,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(
                    0.1,
                  ), // Shadow lebih gelap untuk progress summary
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget Status Summary',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : null,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  'On Track',
                  onTrackCount.toString(),
                  AppColors.successColor,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatusCard(
                  'Over Budget',
                  overBudgetCount.toString(),
                  AppColors.errorColor,
                  Icons.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatusCard(
                  'Categories',
                  categories.length.toString(),
                  AppColors.infoColor,
                  Icons.category,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppComponents.smallRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(CashcardProvider provider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2D2D2D)
            : Colors.white, // Gunakan putih murni untuk recent activities
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(
          color: isDarkMode
              ? Colors.grey.withOpacity(0.2)
              : AppColors.greyLightColor,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(
                    0.1,
                  ), // Shadow lebih gelap untuk recent activities
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Budget Activities',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : null,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // This would show recent transactions that affected budgets
          _buildActivityItem(
            'Food & Dining budget updated',
            'Increased from Rp 1,500,000 to Rp 2,000,000',
            Icons.restaurant,
            AppColors.primaryColor,
          ),
          _buildActivityItem(
            'Transportation over budget',
            'Exceeded by Rp 250,000 this month',
            Icons.warning,
            AppColors.errorColor,
          ),
          _buildActivityItem(
            'Shopping budget created',
            'New budget of Rp 800,000 added',
            Icons.shopping_bag,
            AppColors.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : null,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDarkMode ? Colors.white70 : AppColors.greyColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(CashcardProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // Add Category Button
          ElevatedButton.icon(
            onPressed: () => _showAddBudgetDialog(provider),
            icon: const Icon(Icons.add),
            label: const Text('Add Budget Category'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Categories List
          ...provider.budgetCategories.map(
            (category) => _buildEnhancedCategoryCard(category, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCategoryCard(
    BudgetCategory category,
    CashcardProvider provider,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDarkMode
            ? category.color.withOpacity(0.1)
            : category.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppComponents.smallRadius),
        border: Border.all(
          color: isDarkMode
              ? category.color.withOpacity(0.3)
              : category.color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(category.icon, color: category.color, size: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  category.name,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : null,
                  ),
                ),
              ),
              if (category.isOverBudget)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Over Budget',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  size: 16,
                  color: AppColors.greyColor,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          size: 16,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Text('Edit Budget'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          size: 16,
                          color: AppColors.errorColor,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Text('Delete'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditBudgetDialog(category, provider);
                  } else if (value == 'delete') {
                    _showDeleteDialog(category, provider);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Amount info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(category.spentAmount)}',
                style: AppTypography.bodySmall.copyWith(
                  color: isDarkMode ? Colors.white70 : AppColors.greyColor,
                ),
              ),
              Text(
                'Budget: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(category.budgetAmount)}',
                style: AppTypography.bodySmall.copyWith(
                  color: isDarkMode ? Colors.white70 : AppColors.greyColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          // Progress bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey.withOpacity(0.3)
                  : AppColors.greyExtraLightColor,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: category.progressPercentage > 1.0
                  ? 1.0
                  : category.progressPercentage,
              child: Container(
                decoration: BoxDecoration(
                  color: category.isOverBudget
                      ? AppColors.errorColor
                      : category.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Status info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(category.progressPercentage * 100).toStringAsFixed(1)}% used',
                style: AppTypography.bodySmall.copyWith(
                  color: category.isOverBudget
                      ? AppColors.errorColor
                      : isDarkMode
                      ? Colors.white70
                      : AppColors.greyColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                category.isOverBudget
                    ? 'Over by ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(-category.remainingAmount)}'
                    : '${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(category.remainingAmount)} left',
                style: AppTypography.bodySmall.copyWith(
                  color: category.isOverBudget
                      ? AppColors.errorColor
                      : AppColors.successColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsTab(CashcardProvider provider) {
    final alerts = provider.getBudgetAlerts();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          if (alerts.isEmpty)
            _buildEmptyAlerts()
          else
            ...alerts.map((alert) => _buildAlertCard(alert)),
        ],
      ),
    );
  }

  Widget _buildEmptyAlerts() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.notifications_off,
            size: 64,
            color: isDarkMode ? Colors.white30 : AppColors.greyColor,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No Budget Alerts',
            style: AppTypography.titleMedium.copyWith(
              color: isDarkMode ? Colors.white70 : AppColors.greyColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'All your budgets are on track!',
            style: AppTypography.bodyMedium.copyWith(
              color: isDarkMode ? Colors.white70 : AppColors.greyColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BudgetAlert alert) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDarkMode
            ? alert.alertColor.withOpacity(0.1)
            : alert.alertColor.withOpacity(0.05),
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(
          color: isDarkMode
              ? alert.alertColor.withOpacity(0.4)
              : alert.alertColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: alert.alertColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(alert.alertIcon, color: alert.alertColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.categoryName,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: alert.alertColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.message,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDarkMode ? Colors.white70 : AppColors.greyColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(CashcardProvider provider) {
    final recommendations = provider.getBudgetRecommendations();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // Recommendations
          _buildRecommendationsSection(recommendations, provider),
          const SizedBox(height: AppSpacing.lg),

          // Budget Tips
          _buildBudgetTips(),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(
    List<BudgetRecommendation> recommendations,
    CashcardProvider provider,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2D2D2D)
            : Colors.white, // Gunakan putih murni untuk recommendations section
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(
          color: isDarkMode
              ? Colors.grey.withOpacity(0.2)
              : AppColors.greyLightColor,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(
                    0.1,
                  ), // Shadow lebih gelap untuk recommendations
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
              Icon(Icons.lightbulb, color: AppColors.warningColor, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Budget Recommendations',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          if (recommendations.isEmpty)
            Text(
              'No recommendations at the moment. Your budgets look good!',
              style: AppTypography.bodyMedium.copyWith(
                color: isDarkMode ? Colors.white70 : AppColors.greyColor,
              ),
            )
          else
            ...recommendations.map(
              (rec) => _buildRecommendationCard(rec, provider),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    BudgetRecommendation recommendation,
    CashcardProvider provider,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color cardColor;
    IconData cardIcon;

    switch (recommendation.type) {
      case RecommendationType.createBudget:
        cardColor = AppColors.primaryColor;
        cardIcon = Icons.add_circle;
        break;
      case RecommendationType.increaseBudget:
        cardColor = AppColors.warningColor;
        cardIcon = Icons.trending_up;
        break;
      case RecommendationType.decreaseBudget:
        cardColor = AppColors.infoColor;
        cardIcon = Icons.trending_down;
        break;
      case RecommendationType.optimizeBudget:
        cardColor = AppColors.successColor;
        cardIcon = Icons.tune;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDarkMode
            ? cardColor.withOpacity(0.1)
            : cardColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppComponents.smallRadius),
        border: Border.all(
          color: isDarkMode
              ? cardColor.withOpacity(0.3)
              : cardColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(cardIcon, color: cardColor, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  recommendation.categoryName,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cardColor,
                  ),
                ),
              ),
              if (recommendation.type == RecommendationType.createBudget)
                TextButton(
                  onPressed: () =>
                      _autoApplyRecommendation(recommendation, provider),
                  child: Text('Apply', style: TextStyle(color: cardColor)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            recommendation.reason,
            style: AppTypography.bodySmall.copyWith(
              color: isDarkMode ? Colors.white70 : AppColors.greyColor,
            ),
          ),
          if (recommendation.recommendedAmount > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Recommended: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(recommendation.recommendedAmount)}',
              style: AppTypography.bodySmall.copyWith(
                color: cardColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBudgetTips() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.infoColor.withOpacity(0.1),
        borderRadius: AppComponents.standardBorderRadius,
        border: Border.all(color: AppColors.infoColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                color: AppColors.infoColor,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Budget Tips',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.infoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildTipItem(
            'Follow the 50/30/20 rule: 50% needs, 30% wants, 20% savings',
          ),
          _buildTipItem(
            'Review and adjust your budget monthly based on spending patterns',
          ),
          _buildTipItem(
            'Set up automatic budget categories based on your transaction history',
          ),
          _buildTipItem(
            'Use the alerts to stay notified when approaching budget limits',
          ),
          _buildTipItem(
            'Consider seasonal spending when setting annual budgets',
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.infoColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              tip,
              style: AppTypography.bodySmall.copyWith(
                color: isDarkMode ? Colors.white70 : AppColors.greyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog methods
  void _showAddBudgetDialog(CashcardProvider provider) {
    final TextEditingController amountController = TextEditingController();
    ExpenseCategory selectedCategory = ExpenseCategory.food;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Get category display names from Transaction class
    final categoryDisplayNames = Transaction.getCategoryDisplayNames();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDarkMode
                  ? const Color(0xFF2D2D2D)
                  : Colors.white, // Gunakan putih murni untuk dialog
              title: Text(
                'Add Budget Category',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : null,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Selection
                    Text(
                      'Category',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.grey.withOpacity(0.3)
                              : AppColors.greyLightColor,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isDarkMode ? Colors.grey.withOpacity(0.1) : null,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ExpenseCategory>(
                          value: selectedCategory,
                          isExpanded: true,
                          items: ExpenseCategory.values.map((
                            ExpenseCategory category,
                          ) {
                            final displayName = categoryDisplayNames[category]!;
                            return DropdownMenuItem<ExpenseCategory>(
                              value: category,
                              child: Row(
                                children: [
                                  Icon(
                                    provider.getCategoryIconByName(displayName),
                                    color: provider.getCategoryColorByName(
                                      displayName,
                                    ),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    displayName,
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : null,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (ExpenseCategory? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedCategory = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Budget Amount
                    Text(
                      'Budget Amount',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: isDarkMode ? Colors.white : null),
                      decoration: InputDecoration(
                        hintText: 'Enter budget amount',
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.white54 : null,
                        ),
                        prefixText: 'Rp ',
                        prefixStyle: TextStyle(
                          color: isDarkMode ? Colors.white : null,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.primaryColor,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDarkMode
                                ? Colors.grey.withOpacity(0.3)
                                : AppColors.greyLightColor,
                          ),
                        ),
                        fillColor: isDarkMode
                            ? Colors.grey.withOpacity(0.1)
                            : null,
                        filled: isDarkMode,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Preview
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey.withOpacity(0.2)
                            : AppColors.greyExtraLightColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: provider
                                  .getCategoryColorByName(
                                    categoryDisplayNames[selectedCategory]!,
                                  )
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              provider.getCategoryIconByName(
                                categoryDisplayNames[selectedCategory]!,
                              ),
                              color: provider.getCategoryColorByName(
                                categoryDisplayNames[selectedCategory]!,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  categoryDisplayNames[selectedCategory]!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode ? Colors.white : null,
                                  ),
                                ),
                                Text(
                                  amountController.text.isEmpty
                                      ? 'Rp 0'
                                      : 'Rp ${double.tryParse(amountController.text)?.toStringAsFixed(0) ?? '0'}',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : AppColors.greyColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.greyColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text);
                    if (amount != null && amount > 0) {
                      final categoryDisplayName =
                          categoryDisplayNames[selectedCategory]!;

                      // Check if category already exists
                      final existingCategory = provider.budgetCategories
                          .where((cat) => cat.name == categoryDisplayName)
                          .firstOrNull;

                      if (existingCategory != null) {
                        // Update existing category
                        provider.updateBudgetCategory(existingCategory, amount);
                      } else {
                        // Create new category
                        final newCategory = BudgetCategory(
                          name: categoryDisplayName,
                          budgetAmount: amount,
                          spentAmount: 0,
                          color: provider.getCategoryColorByName(
                            categoryDisplayName,
                          ),
                          icon: provider.getCategoryIconByName(
                            categoryDisplayName,
                          ),
                        );
                        provider.addBudgetCategory(newCategory);
                      }

                      Navigator.of(context).pop();

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            existingCategory != null
                                ? 'Budget updated successfully!'
                                : 'Budget category added successfully!',
                          ),
                          backgroundColor: AppColors.successColor,
                        ),
                      );
                    } else {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid amount'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Budget'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditBudgetDialog(
    BudgetCategory category,
    CashcardProvider provider,
  ) {
    final TextEditingController amountController = TextEditingController(
      text: category.budgetAmount.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              Colors.white, // Gunakan putih murni untuk edit dialog
          title: const Text(
            'Edit Budget Category',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Info (Read-only)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.greyExtraLightColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(category.icon, color: category.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Spent: Rp ${category.spentAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: AppColors.greyColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // New Budget Amount
              const Text(
                'New Budget Amount',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter new budget amount',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.greyColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  provider.updateBudgetCategory(category, amount);
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Budget updated successfully!'),
                      backgroundColor: AppColors.successColor,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BudgetCategory category, CashcardProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              Colors.white, // Gunakan putih murni untuk delete dialog
          title: const Text(
            'Delete Budget Category',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              Text(
                'Are you sure you want to delete "${category.name}" budget category?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.greyColor, fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.greyColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                provider.removeBudgetCategory(category.name);
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${category.name} budget category deleted'),
                    backgroundColor: AppColors.errorColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showResetDialog(CashcardProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              Colors.white, // Gunakan putih murni untuk reset dialog
          title: const Text(
            'Reset Budget Month',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh_rounded,
                color: AppColors.primaryColor,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'This will reset all spending amounts to zero for all budget categories.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Budget amounts will remain unchanged.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.greyColor, fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.greyColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                provider.resetBudgetSpending();
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Budget spending reset successfully!'),
                    backgroundColor: AppColors.successColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _autoApplyRecommendation(
    BudgetRecommendation recommendation,
    CashcardProvider provider,
  ) {
    // Auto apply recommendation
    if (recommendation.type == RecommendationType.createBudget) {
      final newCategory = BudgetCategory(
        name: recommendation.categoryName,
        budgetAmount: recommendation.recommendedAmount,
        spentAmount: 0,
        color: provider.getCategoryColorByName(recommendation.categoryName),
        icon: provider.getCategoryIconByName(recommendation.categoryName),
      );
      provider.addBudgetCategory(newCategory);
    }
  }
}
