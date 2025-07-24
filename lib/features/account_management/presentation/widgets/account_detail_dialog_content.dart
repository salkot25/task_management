import 'package:flutter/material.dart';
import 'package:myapp/features/account_management/domain/entities/account.dart';
import 'package:myapp/features/account_management/presentation/provider/account_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
// import 'package:flutter/services.dart'; // Import for Clipboard (removed)

// This widget will be used as the content of the dialog
class AccountDetailDialogContent extends StatefulWidget {
  final Account? account;

  const AccountDetailDialogContent({super.key, this.account});

  @override
  State<AccountDetailDialogContent> createState() =>
      _AccountDetailDialogContentState();
}

class _AccountDetailDialogContentState
    extends State<AccountDetailDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final websiteController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isEditing = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _isEditing = true;
      websiteController.text = widget.account!.website;
      usernameController.text = widget.account!.username;
      passwordController.text = widget.account!.password;
    }
  }

  @override
  void dispose() {
    websiteController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _saveAccount() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AccountProvider>(context, listen: false);
      final account = Account(
        id: _isEditing ? widget.account!.id : const Uuid().v4(),
        website: websiteController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text,
      );

      if (_isEditing) {
        provider.editAccount(account);
      } else {
        provider.addAccount(account);
      }

      // Close the dialog after saving
      Navigator.pop(context);
    } else {
      // Show snackbar if form is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // AlertDialog provides title, content, and actions structure
      title: Text(_isEditing ? 'Edit Account' : 'Add Account'),
      content: SingleChildScrollView(
        // Wrap content in SingleChildScrollView for keyboard handling
        child: Form(
          key: _formKey,
          child: ListBody(
            // Use ListBody to arrange children in a column
            children: [
              TextFormField(
                controller: websiteController,
                decoration: InputDecoration(
                  labelText: 'Website',
                  prefixIcon: const Icon(Icons.language_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter website';
                  }
                  return null;
                },
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                  ),
                ),
                obscureText: !_isPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Action buttons for the dialog
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveAccount,
          child: Text(_isEditing ? 'Update' : 'Save'),
        ),
      ],
    );
  }
}
