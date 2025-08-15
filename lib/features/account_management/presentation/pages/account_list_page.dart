import 'package:flutter/material.dart';
import 'package:clarity/features/account_management/presentation/provider/account_provider.dart';
import 'package:provider/provider.dart';
import 'package:clarity/features/account_management/domain/entities/account.dart';
import 'package:flutter/services.dart';
import 'package:clarity/utils/design_system/design_system.dart';
// Import the new dialog content widget
import 'package:clarity/features/account_management/presentation/widgets/account_detail_dialog_content.dart';
// Import the standardized AppBar component
import 'package:clarity/presentation/widgets/standard_app_bar.dart';
// Import Advanced Search Bar
import 'package:clarity/features/account_management/presentation/widgets/advanced_search_bar.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  bool _isAdvancedSearchExpanded = false; // For advanced search toggle

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final accountProvider = Provider.of<AccountProvider>(
          context,
          listen: false,
        );
        // Start real-time listening instead of one-time load
        accountProvider.startListening();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Method to show the account detail dialog
  void _showAccountDetailDialog({Account? account}) async {
    // Pass the context to the showDialog function
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AccountDetailDialogContent(
          account: account,
        ); // Use the new dialog content widget
      },
    );

    // After the dialog is closed, refresh the account list
    // Check if the widget is still mounted before using context
    if (mounted) {
      // Clear the search filter when dialog is closed
      Provider.of<AccountProvider>(
        context,
        listen: false,
      ).updateFilters(const SearchFilters());
      // No need to manually reload - real-time listener handles updates
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF1A1A1A)
          : const Color(0xFFF5F5F5), // Gunakan background gelap yang konsisten
      appBar: StandardAppBar(
        title: 'Secure Vault',
        subtitle: 'Your encrypted password manager',
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey.withValues(alpha: 0.2)
                  : Colors.white.withValues(
                      alpha: 0.8,
                    ), // Background putih untuk action button
              borderRadius: BorderRadius.circular(12),
            ),
            child: ActionButton(
              icon: Icons.shield_outlined,
              onPressed: () => _showSecurityTips(context),
              tooltip: 'Security tips',
            ),
          ),
          // Add Account Button
          ActionButton(
            icon: Icons.add_rounded,
            onPressed: () => _showAccountDetailDialog(),
            tooltip: 'Tambah Akun',
            color: AppColors.successColor,
          ),
        ],
      ),
      body: Consumer<AccountProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          } else {
            return Column(
              children: [
                // Advanced Search Bar
                AdvancedSearchBar(
                  filters: provider.filters,
                  onFiltersChanged: provider.updateFilters,
                  availableCategories: provider.availableCategories,
                  isExpanded: _isAdvancedSearchExpanded,
                  onToggleExpanded: () {
                    setState(() {
                      _isAdvancedSearchExpanded = !_isAdvancedSearchExpanded;
                    });
                  },
                ),

                // Content based on filtered results
                if (provider.accounts.isEmpty)
                  Expanded(
                    child: _buildEmptyState(context, provider, accountProvider),
                  )
                else
                  Expanded(
                    child: Column(
                      children: [
                        // Security Overview Section - TEMPORARILY HIDDEN
                        // _buildSecurityOverview(context, provider),
                        // Enhanced Accounts List
                        Expanded(
                          child: _buildAccountsList(
                            context,
                            provider,
                            screenWidth,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }

  /// Loading State with Security Theme
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Securing your vault...',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.greyColor),
          ),
        ],
      ),
    );
  }

  /// Professional Empty State
  Widget _buildEmptyState(
    BuildContext context,
    AccountProvider provider,
    AccountProvider accountProvider,
  ) {
    final bool hasFilter = accountProvider.filters.hasActiveFilters;

    return Center(
      child: Padding(
        padding: AppSpacing.getPagePadding(MediaQuery.of(context).size.width),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: hasFilter
                    ? AppColors.warningColor.withValues(alpha: 0.1)
                    : AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilter ? Icons.search_off_outlined : Icons.security_outlined,
                size: 64,
                color: hasFilter
                    ? AppColors.warningColor
                    : AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              hasFilter ? 'No accounts found' : 'Your vault is empty',
              style: AppTypography.headlineSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hasFilter
                  ? 'No accounts match your search criteria.\nTry adjusting your filters.'
                  : 'Start building your secure password vault.\nAdd your first account to get started.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (!hasFilter)
              ElevatedButton.icon(
                onPressed: () => _showAccountDetailDialog(),
                icon: const Icon(Icons.add_outlined),
                label: Text(
                  'Add First Account',
                  style: AppTypography.buttonPrimary,
                ),
                style: AppComponents.primaryButtonStyle(),
              ),
          ],
        ),
      ),
    );
  }

  /// Security Overview Dashboard
  // ignore: unused_element
  Widget _buildSecurityOverview(
    BuildContext context,
    AccountProvider provider,
  ) {
    final accounts = provider.accounts;
    final totalAccounts = accounts.length;

    // Calculate security metrics
    int weakPasswords = 0;
    int strongPasswords = 0;

    for (final account in accounts) {
      final strength = _calculatePasswordStrength(account.password);
      if (strength <= 2) {
        weakPasswords++;
      } else if (strength >= 4) {
        strongPasswords++;
      }
    }

    return Container(
      margin: AppSpacing.getPagePadding(
        MediaQuery.of(context).size.width,
      ).copyWith(top: AppSpacing.sm, bottom: AppSpacing.xs),
      child: Row(
        children: [
          // Total Accounts Card
          Expanded(
            child: _buildOverviewCard(
              context: context,
              title: 'Total',
              value: totalAccounts.toString(),
              subtitle: 'Accounts',
              icon: Icons.account_circle_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Strong Passwords Card
          Expanded(
            child: _buildOverviewCard(
              context: context,
              title: 'Strong',
              value: strongPasswords.toString(),
              subtitle: 'Passwords',
              icon: Icons.security_outlined,
              color: AppColors.successColor,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Weak Passwords Card
          Expanded(
            child: _buildOverviewCard(
              context: context,
              title: 'Weak',
              value: weakPasswords.toString(),
              subtitle: 'Need Update',
              icon: Icons.warning_outlined,
              color: AppColors.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Overview Card Component
  Widget _buildOverviewCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: AppTypography.labelSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Calculate Password Strength (same logic as in AccountListItem)
  int _calculatePasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    return strength;
  }

  /// Professional Accounts List
  Widget _buildAccountsList(
    BuildContext context,
    AccountProvider provider,
    double screenWidth,
  ) {
    return ListView.builder(
      padding: AppSpacing.getPagePadding(screenWidth).copyWith(
        top: AppSpacing.md,
        bottom: AppSpacing.lg, // Standard bottom padding
      ),
      itemCount: provider.accounts.length,
      itemBuilder: (context, index) {
        final account = provider.accounts[index];
        return AccountListItem(
          account: account,
          onEdit: () => _showAccountDetailDialog(account: account),
          onDelete: () => _showDeleteConfirmation(context, account, provider),
        );
      },
    );
  }

  /// Professional Delete Confirmation
  void _showDeleteConfirmation(
    BuildContext context,
    Account account,
    AccountProvider provider,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode
            ? const Color(0xFF2D2D2D)
            : Colors.white, // Gunakan putih murni untuk delete dialog
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
        icon: Icon(
          Icons.warning_outlined,
          color: AppColors.warningColor,
          size: 32,
        ),
        title: Text(
          'Delete Account?',
          style: AppTypography.headlineSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'This will permanently delete the account for ${account.website}. This action cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) Navigator.pop(context);
            },
            style: AppComponents.textButtonStyle(),
            child: Text(
              'Cancel',
              style: AppTypography.linkText.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              provider.removeAccount(account.id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Account deleted successfully',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.whiteColor,
                      ),
                    ),
                    backgroundColor: AppColors.successColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: AppColors.whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
            ),
            child: Text('Delete', style: AppTypography.buttonPrimary),
          ),
        ],
      ),
    );
  }

  /// Security Tips Dialog
  void _showSecurityTips(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode
            ? const Color(0xFF2D2D2D)
            : Colors.white, // Gunakan putih murni untuk security tips dialog
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
        ),
        icon: Icon(
          Icons.tips_and_updates_outlined,
          color: AppColors.primaryColor,
          size: 32,
        ),
        title: Text(
          'Security Tips',
          style: AppTypography.headlineSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSecurityTip(
              context,
              Icons.password_outlined,
              'Use unique passwords for each account',
            ),
            _buildSecurityTip(
              context,
              Icons.security_outlined,
              'Enable two-factor authentication when available',
            ),
            _buildSecurityTip(
              context,
              Icons.update_outlined,
              'Update passwords regularly',
            ),
            _buildSecurityTip(
              context,
              Icons.visibility_off_outlined,
              'Never share your passwords',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: AppComponents.textButtonStyle(),
            child: Text(
              'Got it',
              style: AppTypography.linkText.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTip(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Professional Account Card with Security-First Design
class AccountListItem extends StatefulWidget {
  final Account account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AccountListItem({
    super.key,
    required this.account,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<AccountListItem> createState() => _AccountListItemState();
}

class _AccountListItemState extends State<AccountListItem> {
  bool _isPasswordVisible = false;

  /// Enhanced Copy to Clipboard with Security Feedback
  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.security_outlined,
              color: AppColors.whiteColor,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$label copied securely',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.whiteColor,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Calculate Password Strength
  int _getPasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    return strength;
  }

  /// Get Password Strength Color
  Color _getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return AppColors.errorColor;
      case 2:
        return AppColors.warningColor;
      case 3:
        return AppColors.infoColor;
      case 4:
      case 5:
        return AppColors.successColor;
      default:
        return AppColors.greyColor;
    }
  }

  /// Get Password Strength Label
  String _getPasswordStrengthLabel(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
      case 5:
        return 'Strong';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final passwordStrength = _getPasswordStrength(widget.account.password);
    final strengthColor = _getPasswordStrengthColor(passwordStrength);
    final strengthLabel = _getPasswordStrengthLabel(passwordStrength);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2D2D2D)
            : Colors.white, // Gunakan putih murni untuk account card
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: isDarkMode
              ? Colors.grey.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(
                    alpha: 0.1,
                  ), // Shadow lebih gelap untuk account card
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simplified Header Row
            Row(
              children: [
                // Simple Website Icon
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: strengthColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Icon(
                    Icons.language_outlined,
                    color: strengthColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Website Name and Badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.account.website,
                        style: AppTypography.titleMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // Simplified Badges Row
                      Row(
                        children: [
                          // Security Badge (compact)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: strengthColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              strengthLabel,
                              style: AppTypography.labelSmall.copyWith(
                                color: strengthColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),

                          // Category Badge (if available)
                          if (widget.account.category != null &&
                              widget.account.category!.isNotEmpty) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.account.category!,
                                style: AppTypography.labelSmall.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Action Buttons (minimal)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 16),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: AppColors.errorColor,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Delete',
                            style: TextStyle(color: AppColors.errorColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      widget.onEdit();
                    } else if (value == 'delete') {
                      widget.onDelete();
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Simplified Credentials Section
            Row(
              children: [
                // Username
                Expanded(
                  child: _buildMinimalCredentialField(
                    context: context,
                    label: 'Username',
                    value: widget.account.username,
                    icon: Icons.person_outlined,
                    onCopy: () => _copyToClipboard(
                      context,
                      widget.account.username,
                      'Username',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Password
                Expanded(
                  child: _buildMinimalCredentialField(
                    context: context,
                    label: 'Password',
                    value: widget.account.password,
                    icon: Icons.lock_outlined,
                    isPassword: true,
                    isVisible: _isPasswordVisible,
                    onToggleVisibility: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    onCopy: () => _copyToClipboard(
                      context,
                      widget.account.password,
                      'Password',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Minimal Credential Field for Simplified Design
  Widget _buildMinimalCredentialField({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = true,
    VoidCallback? onToggleVisibility,
    required VoidCallback onCopy,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with icon
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Value with actions
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey.withValues(alpha: 0.1)
                : Colors.grey.withValues(
                    alpha: 0.05,
                  ), // Background lebih subtle untuk credential field
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            border: Border.all(
              color: isDarkMode
                  ? Colors.grey.withValues(alpha: 0.2)
                  : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isPassword && !isVisible ? '•' * 8 : value,
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: isPassword ? 'monospace' : null,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPassword && onToggleVisibility != null) ...[
                    GestureDetector(
                      onTap: onToggleVisibility,
                      child: Icon(
                        isVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  GestureDetector(
                    onTap: onCopy,
                    child: Icon(
                      Icons.copy_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
