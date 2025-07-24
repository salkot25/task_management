import 'package:flutter/material.dart';
import 'package:myapp/features/account_management/domain/entities/account.dart';
import 'package:myapp/features/account_management/presentation/provider/account_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AccountDetailPage extends StatefulWidget {
  final Account? account; // Nullable for adding new account

  const AccountDetailPage({super.key, this.account});

  @override
  State<AccountDetailPage> createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage> {
  final _formKey = GlobalKey<FormState>();
  // Hapus underscore dari variabel controller
  final websiteController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isEditing = false;
  bool _isPasswordVisible = false; // State untuk visibilitas password

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _isEditing = true;
      // Perbaiki kesalahan pengetikan (hapus karakter 'c')
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
        id: _isEditing ? widget.account!.id : const Uuid().v4(), // Use existing ID or generate new
        website: websiteController.text.trim(), // Hapus spasi di awal/akhir
        username: usernameController.text.trim(), // Hapus spasi di awal/akhir
        password: passwordController.text, // Kata sandi tidak di-trim jika spasi penting
      );

      if (_isEditing) {
        provider.editAccount(account);
      } else {
        provider.addAccount(account);
      }

      Navigator.pop(context); // Go back after saving
    } else {
       // Tampilkan snackbar jika form tidak valid
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Account' : 'Add Account'),
        centerTitle: true,
         // elevation: 0, // Sudah diatur di tema
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Tambahkan padding lebih besar
        child: Form(
          key: _formKey,
          child: ListView(
             // Gunakan ListView agar bisa di-scroll jika keyboard muncul
            children: [
              TextFormField(
                controller: websiteController, // Gunakan nama controller yang diperbarui
                decoration: InputDecoration(
                  labelText: 'Website',
                   // border, filled, fillColor, contentPadding diatur di InputDecorationTheme
                  prefixIcon: const Icon(Icons.language_outlined), // Icon website
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter website';
                  }
                  return null;
                },
                 keyboardType: TextInputType.url, // Keyboard type untuk URL
              ),
              const SizedBox(height: 16.0), // Spasi antar field
              TextFormField(
                controller: usernameController, // Gunakan nama controller yang diperbarui
                decoration: InputDecoration(
                  labelText: 'Username',
                   // border, filled, fillColor, contentPadding diatur di InputDecorationTheme
                   prefixIcon: const Icon(Icons.person_outline), // Icon username
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
                 keyboardType: TextInputType.emailAddress, // Keyboard type untuk email/username
              ),
              const SizedBox(height: 16.0), // Spasi antar field
              TextFormField(
                controller: passwordController, // Gunakan nama controller yang diperbarui
                decoration: InputDecoration(
                  labelText: 'Password',
                   // border, filled, fillColor, contentPadding diatur di InputDecorationTheme
                  prefixIcon: const Icon(Icons.lock_outline), // Icon password
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ), // Tombol toggle visibilitas password
                ),
                obscureText: !_isPasswordVisible, // Masking password
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0), // Spasi sebelum tombol
              ElevatedButton(
                onPressed: _saveAccount,
                 // style diatur di ElevatedButtonThemeData
                child: Text(_isEditing ? 'Update Account' : 'Save Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
