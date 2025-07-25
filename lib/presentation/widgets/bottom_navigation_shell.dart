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
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
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
        onTap: (index) => _onItemTapped(index),
        items: _buildNavigationItems(context),
      ),
    );
  }

  /// Handles navigation bar item taps
  void _onItemTapped(int index) {
    navigationShell.goBranch(index);
  }

  /// Builds the list of navigation bar items
  List<BottomNavigationBarItem> _buildNavigationItems(BuildContext context) {
    return [
      BottomNavigationBarItem(
        icon: _buildNavItemIcon(Icons.checklist_outlined, 0, context),
        activeIcon: _buildNavItemIcon(Icons.checklist, 0, context),
        label: 'Tasks',
        tooltip: 'Task Planner',
      ),
      BottomNavigationBarItem(
        icon: _buildNavItemIcon(Icons.lock_outline, 1, context),
        activeIcon: _buildNavItemIcon(Icons.lock, 1, context),
        label: 'Vault',
        tooltip: 'Password Vault',
      ),
      BottomNavigationBarItem(
        icon: _buildNavItemIcon(
          Icons.account_balance_wallet_outlined,
          2,
          context,
        ),
        activeIcon: _buildNavItemIcon(Icons.account_balance_wallet, 2, context),
        label: 'Cashcard',
        tooltip: 'Cashcard Management',
      ),
      BottomNavigationBarItem(
        icon: _buildNavItemIcon(Icons.person_outline, 3, context),
        activeIcon: _buildNavItemIcon(Icons.person, 3, context),
        label: 'Profile',
        tooltip: 'User Profile',
      ),
    ];
  }

  /// Builds custom styled navigation item icons
  Widget _buildNavItemIcon(
    IconData iconData,
    int itemIndex,
    BuildContext context,
  ) {
    final bool isSelected = navigationShell.currentIndex == itemIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: isSelected
          ? BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16.0),
            )
          : null,
      child: Icon(
        iconData,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        size: 24.0,
      ),
    );
  }
}
