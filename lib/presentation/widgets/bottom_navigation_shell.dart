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
    // Direct navigation without add button
    navigationShell.goBranch(index);
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
        icon: _buildNavItemWithLabel(Icons.note_outlined, 1, 'Notes', context),
        activeIcon: _buildNavItemWithLabel(Icons.note, 1, 'Notes', context),
        label: '',
        tooltip: 'Catatan',
      ),
      BottomNavigationBarItem(
        icon: _buildNavItemWithLabel(Icons.lock_outline, 2, 'Vault', context),
        activeIcon: _buildNavItemWithLabel(Icons.lock, 2, 'Vault', context),
        label: '',
        tooltip: 'Password Vault',
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
    final bool isSelected = navigationShell.currentIndex == itemIndex;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: 80.0, // Increased width for wider background size
      height: 60.0, // Increased height to prevent overflow
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            size: 22.0, // Slightly reduced icon size
          ),
          const SizedBox(height: 3), // Reduced spacing
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 11.0, // Slightly reduced font size
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
