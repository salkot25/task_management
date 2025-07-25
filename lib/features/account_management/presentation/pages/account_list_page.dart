import 'package:flutter/material.dart';
import 'package:myapp/features/account_management/presentation/provider/account_provider.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/account_management/domain/entities/account.dart';
import 'package:flutter/services.dart';
import 'package:myapp/utils/design_system/design_system.dart';
// Import the new dialog content widget
import 'package:myapp/features/account_management/presentation/widgets/account_detail_dialog_content.dart';
// Import the standardized AppBar component
import 'package:myapp/presentation/widgets/standard_app_bar.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  bool _isSearching = false; // State to manage search bar visibility
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AccountProvider>(context, listen: false).loadAccounts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      Provider.of<AccountProvider>(context, listen: false).setFilterWebsite('');
      _searchController.clear(); // Clear search text field as well
      Provider.of<AccountProvider>(context, listen: false).loadAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _isSearching
          ? _buildSearchAppBar(context, accountProvider)
          : StandardAppBar(
              title: 'Secure Vault',
              subtitle: 'Your encrypted password manager',
              actions: [
                ActionButton(
                  icon: Icons.search_outlined,
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                  tooltip: 'Search accounts',
                ),
                ActionButton(
                  icon: Icons.shield_outlined,
                  onPressed: () => _showSecurityTips(context),
                  tooltip: 'Security tips',
                  color: AppColors.primaryColor,
                ),
              ],
            ),
      body: Consumer<AccountProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          } else if (provider.accounts.isEmpty) {
            return _buildEmptyState(context, provider, accountProvider);
          } else {
            return _buildAccountsList(context, provider, screenWidth);
          }
        },
      ),
      floatingActionButton: _buildSecureFloatingActionButton(context),
    );
  }

  /// Search-focused AppBar when in search mode
  PreferredSizeWidget _buildSearchAppBar(
    BuildContext context,
    AccountProvider accountProvider,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            _isSearching = false;
            accountProvider.setFilterWebsite('');
            _searchController.clear();
          });
        },
      ),
      title: _buildSearchField(context, accountProvider),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            color: AppColors.greyLightColor.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  /// Professional Search Field
  Widget _buildSearchField(
    BuildContext context,
    AccountProvider accountProvider,
  ) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration:
            AppComponents.inputDecoration(
              labelText: '',
              hintText: 'Search websites...',
              prefixIcon: Icon(
                Icons.search_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ).copyWith(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
            ),
        style: AppTypography.bodyMedium.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onChanged: (value) {
          accountProvider.setFilterWebsite(value);
        },
        autofocus: true,
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
              color: AppColors.primaryColor.withOpacity(0.1),
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
    final bool hasFilter = accountProvider.filterWebsite.isNotEmpty;

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
                    ? AppColors.warningColor.withOpacity(0.1)
                    : AppColors.primaryColor.withOpacity(0.1),
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
                  ? 'No accounts match "${accountProvider.filterWebsite}".\nTry a different search term.'
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

  /// Professional Accounts List
  Widget _buildAccountsList(
    BuildContext context,
    AccountProvider provider,
    double screenWidth,
  ) {
    return ListView.builder(
      padding: AppSpacing.getPagePadding(screenWidth).copyWith(
        top: AppSpacing.md,
        bottom: 80, // Space for FAB
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

  /// Secure Floating Action Button
  Widget _buildSecureFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAccountDetailDialog(),
      icon: Icon(
        Icons.add_outlined,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      label: Text(
        'Add Account',
        style: AppTypography.buttonPrimary.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 4,
      extendedPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
    );
  }

  /// Professional Delete Confirmation
  void _showDeleteConfirmation(
    BuildContext context,
    Account account,
    AccountProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
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

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: AppComponents.cardDecoration().copyWith(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Website and Security Badge
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.sm),
                topRight: Radius.circular(AppSpacing.sm),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Icon(
                    Icons.language_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.account.website,
                        style: AppTypography.titleMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: strengthColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.xs,
                              ),
                              border: Border.all(
                                color: strengthColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.security_outlined,
                                  size: 12,
                                  color: strengthColor,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  strengthLabel,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: strengthColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Quick Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      onPressed: widget.onEdit,
                      tooltip: 'Edit account',
                      style: AppComponents.textButtonStyle(),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppColors.errorColor,
                        size: 20,
                      ),
                      onPressed: widget.onDelete,
                      tooltip: 'Delete account',
                      style: AppComponents.textButtonStyle(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content Section
          Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              children: [
                // Compact Credentials Row
                Row(
                  children: [
                    // Username Field
                    Expanded(
                      child: _buildCompactCredentialField(
                        context: context,
                        label: 'Username',
                        value: widget.account.username,
                        icon: Icons.person_outlined,
                        isPassword: false,
                        onCopy: () => _copyToClipboard(
                          context,
                          widget.account.username,
                          'Username',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Password Field
                    Expanded(
                      child: _buildCompactCredentialField(
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

                // Password Strength Indicator
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Text(
                      'Password strength: ',
                      style: AppTypography.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.greyExtraLightColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: passwordStrength / 5,
                          child: Container(
                            decoration: BoxDecoration(
                              color: strengthColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Compact Credential Field with Modern Design
  Widget _buildCompactCredentialField({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required bool isPassword,
    bool isVisible = true,
    VoidCallback? onToggleVisibility,
    required VoidCallback onCopy,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact Label Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    icon,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // Value Row with Actions
            Row(
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

                // Compact Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isPassword && onToggleVisibility != null)
                      GestureDetector(
                        onTap: onToggleVisibility,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            isVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onCopy,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.copy_outlined,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
