import 'package:flutter/material.dart';
import 'package:myapp/features/account_management/presentation/pages/account_detail_page.dart';
import 'package:myapp/features/account_management/presentation/provider/account_provider.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/account_management/domain/entities/account.dart';
import 'package:flutter/services.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  @override
  void initState() {
    super.initState();
    // It's generally safe to use context in initState or addPostFrameCallback
    // if you check mounted before using context in asynchronous callbacks.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the widget is still mounted before using context
      if (mounted) {
        Provider.of<AccountProvider>(context, listen: false).loadAccounts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Manager'),
        centerTitle: true,
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
                  provider.message.isNotEmpty ? provider.message : 'No accounts found. Tap the + button to add one.',
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
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountDetailPage(account: account),
                      ),
                    ).then((_) {
                      // Check if the widget is still mounted after navigation returns
                      if (mounted) {
                         Provider.of<AccountProvider>(context, listen: false).loadAccounts();
                      }
                    });
                  },
                  onDelete: () {
                     // Check if the widget is still mounted before showing the dialog
                    if (!mounted) return; 
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: Text('Are you sure you want to delete account for ${account.website}?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                               // Check if the widget is still mounted before navigating
                              if (mounted) {
                                Navigator.pop(context); // It's safe to use context here
                              }
                            }, 
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.removeAccount(account.id);
                               // Check if the widget is still mounted before navigating
                              if (mounted) {
                                Navigator.pop(context); // It's safe to use context here
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AccountDetailPage(),
            ),
          ).then((_) {
            // Check if the widget is still mounted after navigation returns
            if (mounted) {
               Provider.of<AccountProvider>(context, listen: false).loadAccounts();
            }
          });
        },
        tooltip: 'Add Account',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AccountListItem extends StatelessWidget {
  final Account account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AccountListItem({
    super.key,
    required this.account,
    required this.onEdit,
    required this.onDelete,
  });

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    // Access ScaffoldMessengerState using rootNavigator: true
    // It's generally safe to use context for showing Snackbars if the widget is part of the tree.
    // Check mounted before showing the snackbar is also a good practice, though often not strictly necessary here.
     if (!context.mounted) return; // Added mounted check for consistency
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              account.website,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Username: ${account.username}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_outlined),
                  tooltip: 'Copy Username',
                  onPressed: () => _copyToClipboard(context, account.username, 'Username'),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Password: ${account.password}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                 IconButton(
                  icon: const Icon(Icons.copy_outlined),
                  tooltip: 'Copy Password',
                  onPressed: () => _copyToClipboard(context, account.password, 'Password'),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const Divider(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                 TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8.0),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                   style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
