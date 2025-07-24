import 'package:flutter/material.dart';
import 'package:myapp/features/account_management/presentation/pages/account_detail_page.dart';
import 'package:myapp/features/account_management/presentation/provider/account_provider.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/account_management/domain/entities/account.dart';
import 'package:flutter/services.dart'; // Tambahkan import ini kembali

class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  @override
  void initState() {
    super.initState();
    // Load accounts when the page is initialized
    // Menggunakan addPostFrameCallback untuk memastikan context tersedia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(context, listen: false).loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Manager'),
        centerTitle: true,
        // Hapus elevation untuk tampilan lebih flat
        // elevation: 0, // Sudah diatur di tema
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
                  style: Theme.of(context).textTheme.titleMedium, // Gunakan gaya dari tema
                ),
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0), // Tambahkan padding vertikal
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
                      // Cek mounted sebelum menggunakan context
                      if (mounted) {
                         provider.loadAccounts(); // Reload after returning from detail page
                      }
                    });
                  },
                  onDelete: () {
                    // Show a confirmation dialog before deleting
                    showDialog( // Menggunakan showDialog dari material
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: Text('Are you sure you want to delete account for ${account.website}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context), // Tutup dialog
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.removeAccount(account.id);
                              Navigator.pop(context); // Tutup dialog
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
             // Cek mounted sebelum menggunakan context
            if (mounted) {
               Provider.of<AccountProvider>(context, listen: false).loadAccounts(); // Reload after adding
            }
          });
        },
        tooltip: 'Add Account',
        child: const Icon(Icons.add), // Icon Material Symbols terbaru
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // Margin, elevasi, shape, padding sudah diatur di CardTheme
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Padding di dalam card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              account.website,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), // Judul tebal
            ),
            const SizedBox(height: 4.0), // Spasi kecil
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Username: ${account.username}',
                    style: Theme.of(context).textTheme.bodyMedium, // Gaya teks body
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_outlined), // Icon copy outlined
                  tooltip: 'Copy Username',
                  onPressed: () => _copyToClipboard(context, account.username, 'Username'),
                  color: Theme.of(context).colorScheme.primary, // Warna sesuai tema
                ),
              ],
            ),
            const SizedBox(height: 4.0), // Spasi kecil
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Password: ${account.password}',
                    style: Theme.of(context).textTheme.bodyMedium, // Gaya teks body
                  ),
                ),
                 IconButton(
                  icon: const Icon(Icons.copy_outlined), // Icon copy outlined
                  tooltip: 'Copy Password',
                  onPressed: () => _copyToClipboard(context, account.password, 'Password'),
                  color: Theme.of(context).colorScheme.primary, // Warna sesuai tema
                ),
              ],
            ),
            const Divider(height: 16.0), // Garis pemisah
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Tombol di kanan
              children: [
                 TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined), // Icon edit outlined
                  label: const Text('Edit'),
                  // style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary), // Sudah diatur di tema jika menggunakan gaya default
                ),
                const SizedBox(width: 8.0), // Spasi antar tombol
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline), // Icon delete outlined
                  label: const Text('Delete'),
                   style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error), // Warna teks error tetap di sini karena spesifik
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
