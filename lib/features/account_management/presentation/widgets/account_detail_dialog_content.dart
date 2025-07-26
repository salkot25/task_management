import 'package:flutter/material.dart';
import 'package:myapp/features/account_management/domain/entities/account.dart';
import 'package:myapp/features/account_management/presentation/provider/account_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:myapp/utils/design_system/design_system.dart';
// import 'package:flutter/services.dart'; // Import for Clipboard (removed) 'package:flutter/material.dart';
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
  String? _selectedCategory;

  // Predefined categories
  final List<String> _predefinedCategories = [
    'AP2T',
    'ACMT',
    'Email',
    'Google',
    'Banking',
    'Social',
    'Work',
    'Shopping',
    'Entertainment',
    'Education',
    'Health',
    'Travel',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _isEditing = true;
      websiteController.text = widget.account!.website;
      usernameController.text = widget.account!.username;
      passwordController.text = widget.account!.password;
      _selectedCategory = widget.account!.category;
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
        category: _selectedCategory,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDarkMode
          ? const Color(0xFF2D2D2D)
          : Theme.of(context).colorScheme.surface,
      surfaceTintColor: isDarkMode
          ? Colors.transparent
          : Theme.of(context).colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: isDarkMode ? 8 : 4,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isEditing ? Icons.edit_outlined : Icons.add_circle_outline,
              color: AppColors.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Account' : 'Add New Account',
                  style: AppTypography.headlineSmall.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _isEditing
                      ? 'Update account credentials'
                      : 'Save your login credentials securely',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // Enhanced Website Field
              TextFormField(
                controller: websiteController,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: _buildEnhancedInputDecoration(
                  context: context,
                  labelText: 'Website/Service',
                  hintText: 'e.g., Google, Facebook, GitHub',
                  prefixIcon: Icons.language_outlined,
                  isDarkMode: isDarkMode,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter website or service name';
                  }
                  return null;
                },
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: AppSpacing.md),

              // Enhanced Username Field
              TextFormField(
                controller: usernameController,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: _buildEnhancedInputDecoration(
                  context: context,
                  labelText: 'Username/Email',
                  hintText: 'Enter your username or email',
                  prefixIcon: Icons.person_outline,
                  isDarkMode: isDarkMode,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username or email';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.md),

              // Enhanced Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: _buildEnhancedInputDecoration(
                  context: context,
                  labelText: 'Category (Optional)',
                  hintText: 'Select account category',
                  prefixIcon: Icons.category_outlined,
                  isDarkMode: isDarkMode,
                ),
                hint: Text(
                  'Select category',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
                dropdownColor: isDarkMode
                    ? const Color(0xFF2D2D2D)
                    : Colors.white,
                items: _predefinedCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Enhanced Password Field
              TextFormField(
                controller: passwordController,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: _buildEnhancedInputDecoration(
                  context: context,
                  labelText: 'Password',
                  hintText: 'Enter secure password',
                  prefixIcon: Icons.lock_outline,
                  isDarkMode: isDarkMode,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
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
        // Enhanced Cancel Button
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            foregroundColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Cancel',
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Enhanced Save Button
        ElevatedButton(
          onPressed: _saveAccount,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isEditing ? Icons.update_rounded : Icons.add_rounded,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                _isEditing ? 'Update Account' : 'Save Account',
                style: AppTypography.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Enhanced Input Decoration matching Task Planner style
  InputDecoration _buildEnhancedInputDecoration({
    required BuildContext context,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    required bool isDarkMode,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(
        prefixIcon,
        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDarkMode
          ? Colors.grey.withOpacity(0.1)
          : Colors.grey.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDarkMode
              ? Colors.grey.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDarkMode
              ? Colors.grey.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      labelStyle: TextStyle(
        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
      ),
      hintStyle: TextStyle(
        color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
      ),
    );
  }
}
