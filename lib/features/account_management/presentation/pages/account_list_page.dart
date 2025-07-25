import 'package:flutter/material.dart';
import 'package:myapp/features/account_management/presentation/provider/account_provider.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/account_management/domain/entities/account.dart';
import 'package:flutter/services.dart';
// Import the new dialog content widget
import 'package:myapp/features/account_management/presentation/widgets/account_detail_dialog_content.dart';

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
    // Consume the provider here to get the filterWebsite value
    final accountProvider = Provider.of<AccountProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search website...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withOpacity(0.7),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 18.0,
                ),
                onChanged: (value) {
                  // Update the filter in the provider
                  accountProvider.setFilterWebsite(value);
                },
              )
            : const Text('Password Manager'),
        centerTitle: !_isSearching, // Center title only when not searching
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  // Clear search when closing search bar
                  accountProvider.setFilterWebsite('');
                  _searchController.clear();
                }
              });
            },
          ),
        ],
        // Apply AppBar theme from AppTheme
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        titleTextStyle: _isSearching
            ? null
            : Theme.of(context)
                  .appBarTheme
                  .titleTextStyle, // Use themed title style when not searching
      ),
      body: Consumer<AccountProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.accounts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  provider.message.isNotEmpty
                      ? provider.message
                      : accountProvider
                            .filterWebsite
                            .isNotEmpty // Check filter website as well
                      ? 'No accounts found for "${accountProvider.filterWebsite}".'
                      : 'No accounts found. Tap the + button to add one.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: provider.accounts.length,
              itemBuilder: (context, index) {
                final account = provider.accounts[index];
                return AccountListItem(
                  account: account,
                  // Call the dialog method for editing
                  onEdit: () => _showAccountDetailDialog(account: account),
                  onDelete: () {
                    if (!mounted) return;
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: Text(
                          'Are you sure you want to delete account for ${account.website}?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              if (mounted) {
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.removeAccount(account.id);
                              if (mounted) {
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Call the dialog method for adding
        onPressed: () => _showAccountDetailDialog(),
        tooltip: 'Add Account',
        child: const Icon(Icons.add),
      ),
    );
  }
}

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

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withAlpha(
              (255 * 0.05).round(),
            ), // Softer shadow
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 4), // More spread out shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Website
          Row(
            children: [
              Icon(
                Icons.language_outlined,
                size: 20.0,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ), // Subtle icon
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  widget.account.website,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ), // Emphasize website
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0), // Increased space
          // Username
          TextFormField(
            initialValue: widget.account.username,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Username',
              prefixIcon: const Icon(
                Icons.person_outline,
                size: 20.0,
              ), // Adjusted icon size
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.copy_outlined,
                  size: 20.0,
                ), // Adjusted icon size
                tooltip: 'Copy Username',
                onPressed: () => _copyToClipboard(
                  context,
                  widget.account.username,
                  'Username',
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                borderSide: BorderSide.none, // Remove the border line
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ), // Adjust padding
              isDense: true, // Reduce vertical space
              labelStyle: Theme.of(
                context,
              ).textTheme.bodySmall, // Smaller label
              filled: true, // Fill background
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest
                  .withOpacity(0.5), // Use a subtle fill color
            ),
            style: Theme.of(context).textTheme.bodyMedium, // Apply text style
          ),
          const SizedBox(height: 12.0), // Adjusted space
          // Password
          TextFormField(
            initialValue: widget.account.password,
            readOnly: true,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(
                Icons.lock_outline,
                size: 20.0,
              ), // Adjusted icon size
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20.0, // Adjusted icon size
                    ),
                    tooltip: _isPasswordVisible
                        ? 'Hide Password'
                        : 'Show Password',
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.copy_outlined,
                      size: 20.0,
                    ), // Adjusted icon size
                    tooltip: 'Copy Password',
                    onPressed: () => _copyToClipboard(
                      context,
                      widget.account.password,
                      'Password',
                    ),
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                borderSide: BorderSide.none, // Remove the border line
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ), // Adjust padding
              isDense: true, // Reduce vertical space
              labelStyle: Theme.of(
                context,
              ).textTheme.bodySmall, // Smaller label
              filled: true, // Fill background
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest
                  .withOpacity(0.5), // Use a subtle fill color
            ),
            style: Theme.of(context).textTheme.bodyMedium, // Apply text style
          ),

          const Divider(height: 24.0), // Keep divider and space
          // Actions (Edit, Delete)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20.0),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 16.0),
              TextButton.icon(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_outline, size: 20.0),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
