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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AccountProvider>(context, listen: false).loadAccounts();
      }
    });
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
      Provider.of<AccountProvider>(context, listen: false).loadAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password Manager'), centerTitle: true),
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
                      builder:
                          (context) => AlertDialog(
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
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Website
          Text(
            widget.account.website,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12.0),

          // Username
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 20.0,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  widget.account.username,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 20.0),
                tooltip: 'Copy Username',
                onPressed:
                    () => _copyToClipboard(
                      context,
                      widget.account.username,
                      'Username',
                    ),
                color: Theme.of(context).colorScheme.primary,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8.0),

          // Password
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 20.0,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  _isPasswordVisible
                      ? widget.account.password
                      : '•' *
                          widget
                              .account
                              .password
                              .length, // Toggle mask password
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    letterSpacing: _isPasswordVisible ? 1.0 : 2.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  size: 20.0,
                ),
                tooltip: _isPasswordVisible ? 'Hide Password' : 'Show Password',
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                color: Theme.of(context).colorScheme.primary,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 20.0),
                tooltip: 'Copy Password',
                onPressed:
                    () => _copyToClipboard(
                      context,
                      widget.account.password,
                      'Password',
                    ),
                color: Theme.of(context).colorScheme.primary,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          const Divider(height: 24.0),

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
