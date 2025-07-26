import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clarity/features/auth/presentation/provider/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:clarity/utils/design_system/design_system.dart';
import 'dart:developer' as developer;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      // Add password confirmation check
      if (_passwordController.text != _confirmPasswordController.text) {
        if (!mounted) return; // Add mounted check
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success) {
        if (!mounted) return; // Add mounted check
        // Navigation after successful registration is handled by go_router's redirect
      } else {
        if (!mounted) return; // Add mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Registration Failed'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building RegisterPage', name: 'RegisterPage');
    final authProvider = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? Theme.of(context).colorScheme.surface
          : Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.getHorizontalPadding(screenWidth),
              vertical: AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: AppSpacing.getContainerWidth(screenWidth),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Logo
                    Image.asset('assets/images/logo.png', height: 120),
                    const SizedBox(height: AppSpacing.xl),
                    // Title
                    Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: AppTypography.loginTitle.copyWith(
                        color: isDarkMode
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Subtitle
                    Text(
                      'Sign up to get started',
                      textAlign: TextAlign.center,
                      style: AppTypography.loginSubtitle.copyWith(
                        color: isDarkMode
                            ? Colors.grey[400]
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      decoration:
                          AppComponents.emailInputDecoration(
                            colorScheme: Theme.of(context).colorScheme,
                          ).copyWith(
                            filled: true,
                            fillColor: isDarkMode
                                ? Colors.grey.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.05),
                            labelStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            hintStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[500]
                                  : Colors.grey[500],
                            ),
                          ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      decoration:
                          AppComponents.passwordInputDecoration(
                            colorScheme: Theme.of(context).colorScheme,
                            isPasswordVisible: _isPasswordVisible,
                            onToggleVisibility: _togglePasswordVisibility,
                          ).copyWith(
                            filled: true,
                            fillColor: isDarkMode
                                ? Colors.grey.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.05),
                            labelStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            hintStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[500]
                                  : Colors.grey[500],
                            ),
                          ),
                      obscureText: !_isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Confirm Password field
                    TextFormField(
                      controller: _confirmPasswordController,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      decoration:
                          AppComponents.passwordInputDecoration(
                            colorScheme: Theme.of(context).colorScheme,
                            isPasswordVisible: _isConfirmPasswordVisible,
                            onToggleVisibility:
                                _toggleConfirmPasswordVisibility,
                          ).copyWith(
                            labelText: 'Confirm Password',
                            hintText: 'Re-enter your password',
                            filled: true,
                            fillColor: isDarkMode
                                ? Colors.grey.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.05),
                            labelStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            hintStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[500]
                                  : Colors.grey[500],
                            ),
                          ),
                      obscureText: !_isConfirmPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    // Register button
                    if (authProvider.isLoading)
                      AppComponents.loadingButton(
                        height: 52.0,
                        colorScheme: Theme.of(context).colorScheme,
                      )
                    else
                      ElevatedButton(
                        onPressed: _register,
                        style: AppComponents.primaryButtonStyle(),
                        child: Text(
                          'Create Account',
                          style: AppTypography.buttonPrimary,
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xl),
                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: AppTypography.bodyText.copyWith(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          style: AppComponents.textButtonStyle(),
                          child: Text(
                            'Sign In',
                            style: AppTypography.linkText.copyWith(
                              color: isDarkMode
                                  ? AppColors.primaryColor.withOpacity(0.9)
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
