import 'package:flutter/material.dart';
import 'package:myapp/utils/design_system/design_system.dart';
import 'package:myapp/features/account_management/domain/entities/account.dart';

enum SecurityStrength { all, weak, medium, strong, excellent }

enum SortOption { name, dateAdded, dateModified, securityStrength }

class SearchFilters {
  final String searchQuery;
  final SecurityStrength securityFilter;
  final SortOption sortBy;
  final bool ascending;
  final List<String> selectedCategories;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const SearchFilters({
    this.searchQuery = '',
    this.securityFilter = SecurityStrength.all,
    this.sortBy = SortOption.name,
    this.ascending = true,
    this.selectedCategories = const [],
    this.dateFrom,
    this.dateTo,
  });

  SearchFilters copyWith({
    String? searchQuery,
    SecurityStrength? securityFilter,
    SortOption? sortBy,
    bool? ascending,
    List<String>? selectedCategories,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return SearchFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      securityFilter: securityFilter ?? this.securityFilter,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }

  bool get hasActiveFilters {
    return searchQuery.isNotEmpty ||
        securityFilter != SecurityStrength.all ||
        selectedCategories.isNotEmpty ||
        dateFrom != null ||
        dateTo != null;
  }
}

class AdvancedSearchBar extends StatefulWidget {
  final SearchFilters filters;
  final Function(SearchFilters) onFiltersChanged;
  final List<String> availableCategories;
  final bool isExpanded;
  final VoidCallback? onToggleExpanded;

  const AdvancedSearchBar({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
    this.availableCategories = const [],
    this.isExpanded = false,
    this.onToggleExpanded,
  });

  @override
  State<AdvancedSearchBar> createState() => _AdvancedSearchBarState();
}

class _AdvancedSearchBarState extends State<AdvancedSearchBar>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.filters.searchQuery);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    if (widget.isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AdvancedSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updateSearchQuery(String query) {
    widget.onFiltersChanged(widget.filters.copyWith(searchQuery: query));
  }

  void _updateSecurityFilter(SecurityStrength? strength) {
    if (strength != null) {
      widget.onFiltersChanged(
        widget.filters.copyWith(securityFilter: strength),
      );
    }
  }

  void _updateSortOption(SortOption? option) {
    if (option != null) {
      widget.onFiltersChanged(widget.filters.copyWith(sortBy: option));
    }
  }

  void _toggleSortOrder() {
    widget.onFiltersChanged(
      widget.filters.copyWith(ascending: !widget.filters.ascending),
    );
  }

  void _updateCategories(List<String> categories) {
    widget.onFiltersChanged(
      widget.filters.copyWith(selectedCategories: categories),
    );
  }

  void _clearAllFilters() {
    _searchController.clear();
    widget.onFiltersChanged(const SearchFilters());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildMainSearchBar(),
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _expandAnimation,
                child: _buildAdvancedFilters(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Search Icon
          Icon(
            Icons.search_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.sm),

          // Search Input Field
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search websites, usernames, emails...',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),

          // Active Filters Indicator
          if (widget.filters.hasActiveFilters) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: Text(
                _getActiveFiltersCount().toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],

          // Clear Filters Button
          if (widget.filters.hasActiveFilters)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              onPressed: _clearAllFilters,
              tooltip: 'Clear all filters',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),

          // Filter Toggle Button
          IconButton(
            icon: AnimatedRotation(
              turns: widget.isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.tune,
                color: widget.filters.hasActiveFilters
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            onPressed: widget.onToggleExpanded,
            tooltip: 'Advanced filters',
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Security Strength Filter
          _buildSecurityStrengthFilter(),
          const SizedBox(height: AppSpacing.md),

          // Sort Options
          _buildSortOptions(),
          const SizedBox(height: AppSpacing.md),

          // Category Filter
          if (widget.availableCategories.isNotEmpty) ...[
            _buildCategoryFilter(),
            const SizedBox(height: AppSpacing.md),
          ],

          // Quick Action Buttons
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildSecurityStrengthFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Strength',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: SecurityStrength.values.map((strength) {
            final isSelected = widget.filters.securityFilter == strength;
            return FilterChip(
              label: Text(_getSecurityStrengthLabel(strength)),
              selected: isSelected,
              onSelected: (_) => _updateSecurityFilter(strength),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              selectedColor: _getSecurityStrengthColor(
                strength,
              ).withOpacity(0.2),
              checkmarkColor: _getSecurityStrengthColor(strength),
              labelStyle: TextStyle(
                color: isSelected
                    ? _getSecurityStrengthColor(strength)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<SortOption>(
                value: widget.filters.sortBy,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                items: SortOption.values.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(_getSortOptionLabel(option)),
                  );
                }).toList(),
                onChanged: _updateSortOption,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: AnimatedRotation(
                turns: widget.filters.ascending ? 0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.filters.ascending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                ),
              ),
              onPressed: _toggleSortOrder,
              tooltip: widget.filters.ascending ? 'Ascending' : 'Descending',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: widget.availableCategories.map((category) {
            final isSelected = widget.filters.selectedCategories.contains(
              category,
            );
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                final newCategories = List<String>.from(
                  widget.filters.selectedCategories,
                );
                if (selected) {
                  newCategories.add(category);
                } else {
                  newCategories.remove(category);
                }
                _updateCategories(newCategories);
              },
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              selectedColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: _clearAllFilters,
          icon: const Icon(Icons.clear_all, size: 18),
          label: const Text('Clear All'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
        const Spacer(),
        Text(
          '${_getActiveFiltersCount()} filters active',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (widget.filters.searchQuery.isNotEmpty) count++;
    if (widget.filters.securityFilter != SecurityStrength.all) count++;
    if (widget.filters.selectedCategories.isNotEmpty) count++;
    if (widget.filters.dateFrom != null || widget.filters.dateTo != null) {
      count++;
    }
    return count;
  }

  String _getSecurityStrengthLabel(SecurityStrength strength) {
    switch (strength) {
      case SecurityStrength.all:
        return 'All';
      case SecurityStrength.weak:
        return 'Weak';
      case SecurityStrength.medium:
        return 'Medium';
      case SecurityStrength.strong:
        return 'Strong';
      case SecurityStrength.excellent:
        return 'Excellent';
    }
  }

  Color _getSecurityStrengthColor(SecurityStrength strength) {
    switch (strength) {
      case SecurityStrength.all:
        return Theme.of(context).colorScheme.primary;
      case SecurityStrength.weak:
        return AppColors.errorColor;
      case SecurityStrength.medium:
        return const Color(0xFFED8936);
      case SecurityStrength.strong:
        return AppColors.successColor;
      case SecurityStrength.excellent:
        return const Color(0xFF3182CE);
    }
  }

  String _getSortOptionLabel(SortOption option) {
    switch (option) {
      case SortOption.name:
        return 'Name';
      case SortOption.dateAdded:
        return 'Date Added';
      case SortOption.dateModified:
        return 'Last Modified';
      case SortOption.securityStrength:
        return 'Security Strength';
    }
  }
}

// Extension untuk filtering accounts
extension AccountFiltering on List<Account> {
  List<Account> applyFilters(SearchFilters filters) {
    List<Account> filteredAccounts = this;

    // Search query filter
    if (filters.searchQuery.isNotEmpty) {
      final query = filters.searchQuery.toLowerCase();
      filteredAccounts = filteredAccounts.where((account) {
        return account.website.toLowerCase().contains(query) ||
            account.username.toLowerCase().contains(query);
      }).toList();
    }

    // Security strength filter
    if (filters.securityFilter != SecurityStrength.all) {
      filteredAccounts = filteredAccounts.where((account) {
        final strength = _getAccountSecurityStrength(account);
        return strength == filters.securityFilter;
      }).toList();
    }

    // Category filter
    if (filters.selectedCategories.isNotEmpty) {
      filteredAccounts = filteredAccounts.where((account) {
        final category = _getAccountCategory(account);
        return filters.selectedCategories.contains(category);
      }).toList();
    }

    // Sort accounts
    filteredAccounts.sort((a, b) {
      int comparison = 0;

      switch (filters.sortBy) {
        case SortOption.name:
          comparison = a.website.compareTo(b.website);
          break;
        case SortOption.dateAdded:
          comparison = (a.createdAt ?? DateTime.now()).compareTo(
            b.createdAt ?? DateTime.now(),
          );
          break;
        case SortOption.dateModified:
          comparison = (a.updatedAt ?? DateTime.now()).compareTo(
            b.updatedAt ?? DateTime.now(),
          );
          break;
        case SortOption.securityStrength:
          final strengthA = _getAccountSecurityStrength(a);
          final strengthB = _getAccountSecurityStrength(b);
          comparison = strengthA.index.compareTo(strengthB.index);
          break;
      }

      return filters.ascending ? comparison : -comparison;
    });

    return filteredAccounts;
  }

  SecurityStrength _getAccountSecurityStrength(Account account) {
    final password = account.password;
    if (password.length < 8) return SecurityStrength.weak;
    if (password.length < 12) return SecurityStrength.medium;
    if (password.length < 16) return SecurityStrength.strong;
    return SecurityStrength.excellent;
  }

  String _getAccountCategory(Account account) {
    // Return the actual category if available, otherwise auto-categorize
    if (account.category != null && account.category!.isNotEmpty) {
      return account.category!;
    }

    // Auto-categorize based on website name for backward compatibility
    final website = account.website.toLowerCase();
    if (website.contains('bank') || website.contains('finance')) {
      return 'Banking';
    }
    if (website.contains('social') ||
        website.contains('facebook') ||
        website.contains('twitter')) {
      return 'Social';
    }
    if (website.contains('email') || website.contains('mail')) return 'Email';
    if (website.contains('work') || website.contains('office')) return 'Work';
    return 'Other';
  }
}
