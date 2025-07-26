import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom Bottom Navigation Shell Widget
/// Provides a clean, maintainable implementation of the bottom navigation
class BottomNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavigationShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  /// Builds the bottom navigation bar with improved styling
  Widget _buildBottomNavigationBar(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12.0,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12.0,
        ),
        elevation: 0,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onItemTapped(index, context),
        items: _buildNavigationItems(context),
      ),
    );
  }

  /// Handles navigation bar item taps
  void _onItemTapped(int index, BuildContext context) {
    // Handle Add button (index 2)
    if (index == 2) {
      _handleAddButtonPress(context);
    } else {
      // Navigate to other pages, adjusting for Add button at index 2
      final actualIndex = index > 2 ? index - 1 : index;
      navigationShell.goBranch(actualIndex);
    }
  }

  /// Handles add button press based on current page
  void _handleAddButtonPress(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    switch (currentIndex) {
      case 0: // Tasks page
        context.go('/tasks/add');
        break;
      case 1: // Vault page
        context.go('/vault/add');
        break;
      case 2: // Cashcard page
        context.go('/cashcard/add');
        break;
      case 3: // Profile page
        _showLogoutConfirmationDialog(context);
        break;
      default:
        // Fallback to modal bottom sheet
        _showAddOptionsBottomSheet(context);
    }
  }

  /// Shows logout confirmation dialog
  void _showLogoutConfirmationDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: isDarkMode
              ? Theme.of(context).colorScheme.surfaceTint
              : null,
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement logout functionality here
                // You can call your auth provider logout method
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logout functionality will be implemented'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  /// Gets the appropriate icon for the add button based on current page
  IconData _getAddButtonIcon() {
    final currentIndex = navigationShell.currentIndex;

    switch (currentIndex) {
      case 0: // Tasks page
        return Icons.add_task;
      case 1: // Vault page
        return Icons.add_circle_outline;
      case 2: // Cashcard page
        return Icons.add_card;
      case 3: // Profile page
        return Icons.logout;
      default:
        return Icons.add;
    }
  }

  /// Gets the appropriate tooltip for the add button based on current page
  String _getAddButtonTooltip() {
    final currentIndex = navigationShell.currentIndex;

    switch (currentIndex) {
      case 0: // Tasks page
        return 'Add Task';
      case 1: // Vault page
        return 'Add Account';
      case 2: // Cashcard page
        return 'Add Transaction';
      case 3: // Profile page
        return 'Logout';
      default:
        return 'Quick Add';
    }
  }

  /// Builds the list of navigation bar items
  List<BottomNavigationBarItem> _buildNavigationItems(BuildContext context) {
    return [
      BottomNavigationBarItem(
        icon: _buildNavItemWithLabel(
          Icons.checklist_outlined,
          0,
          'Tasks',
          context,
        ),
        activeIcon: _buildNavItemWithLabel(
          Icons.checklist,
          0,
          'Tasks',
          context,
        ),
        label: '',
        tooltip: 'Task Planner',
      ),
      BottomNavigationBarItem(
        icon: _buildNavItemWithLabel(Icons.lock_outline, 1, 'Vault', context),
        activeIcon: _buildNavItemWithLabel(Icons.lock, 1, 'Vault', context),
        label: '',
        tooltip: 'Password Vault',
      ),
      BottomNavigationBarItem(
        icon: Transform.translate(
          offset: const Offset(0, 2),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getAddButtonIcon(),
              color: Theme.of(context).colorScheme.onPrimary,
              size: 28,
            ),
          ),
        ),
        activeIcon: Transform.translate(
          offset: const Offset(0, 4),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              _getAddButtonIcon(),
              color: Theme.of(context).colorScheme.onPrimary,
              size: 28,
            ),
          ),
        ),
        label: '',
        tooltip: _getAddButtonTooltip(),
      ),
      BottomNavigationBarItem(
        icon: _buildNavItemWithLabel(
          Icons.account_balance_wallet_outlined,
          3,
          'Cashcard',
          context,
        ),
        activeIcon: _buildNavItemWithLabel(
          Icons.account_balance_wallet,
          3,
          'Cashcard',
          context,
        ),
        label: '',
        tooltip: 'Cashcard Management',
      ),
      BottomNavigationBarItem(
        icon: _buildNavItemWithLabel(
          Icons.person_outline,
          4,
          'Profile',
          context,
        ),
        activeIcon: _buildNavItemWithLabel(Icons.person, 4, 'Profile', context),
        label: '',
        tooltip: 'User Profile',
      ),
    ];
  }

  /// Builds custom styled navigation item with label and icon
  Widget _buildNavItemWithLabel(
    IconData iconData,
    int itemIndex,
    String label,
    BuildContext context,
  ) {
    final int actualIndex = itemIndex > 2 ? itemIndex - 1 : itemIndex;
    final bool isSelected = navigationShell.currentIndex == actualIndex;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: isSelected
          ? BoxDecoration(
              color: isDarkMode
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                  : Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.0),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            size: 24.0,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 12.0,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Shows bottom sheet with add options
  void _showAddOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddOptionsBottomSheet(context),
    );
  }

  /// Builds the add options bottom sheet
  Widget _buildAddOptionsBottomSheet(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: isDarkMode
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Quick Add',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),

          // Add options
          _buildAddOption(
            context,
            icon: Icons.assignment_outlined,
            title: 'Add Task',
            subtitle: 'Create a new task or reminder',
            onTap: () {
              Navigator.pop(context);
              context.go('/tasks/add');
            },
          ),
          const SizedBox(height: 12),

          _buildAddOption(
            context,
            icon: Icons.security_outlined,
            title: 'Add Account',
            subtitle: 'Save account credentials securely',
            onTap: () {
              Navigator.pop(context);
              context.go('/vault/add');
            },
          ),
          const SizedBox(height: 12),

          _buildAddOption(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Add Transaction',
            subtitle: 'Record income or expense',
            onTap: () {
              Navigator.pop(context);
              context.go('/cashcard/add');
            },
          ),

          const SizedBox(height: 24),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: isDarkMode
                      ? Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.5)
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  /// Builds an add option item
  Widget _buildAddOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDarkMode
                ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2)
                    : Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
