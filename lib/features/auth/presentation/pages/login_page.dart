import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clarity/features/auth/presentation/provider/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:clarity/utils/design_system/design_system.dart';
import 'dart:developer' as developer;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success) {
        // Navigation after login is handled by go_router's redirect
      } else {
        if (!mounted) return; // Add mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage ?? 'Login Failed')),
        );
      }
    }
  }

  void _signInWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = await authProvider.signInWithGoogle();

    if (!success) {
      if (!mounted) return; // Add mounted check
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Google Sign In Failed'),
        ),
      );
    }
    // Navigation after successful Google Sign-In is handled by go_router's redirect
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                    // Optimized logo size for better visual hierarchy
                    Image.asset(
                      'assets/images/logo.png',
                      height: 120, // Reduced from 180px for better proportion
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'TASKS MANAGEMENT',
                      textAlign: TextAlign.center,
                      style: AppTypography.loginTitle.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Sign in to continue',
                      textAlign: TextAlign.center,
                      style: AppTypography.loginSubtitle.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextFormField(
                      controller: _emailController,
                      decoration: AppComponents.emailInputDecoration(
                        colorScheme: Theme.of(context).colorScheme,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _passwordController,
                      decoration: AppComponents.passwordInputDecoration(
                        colorScheme: Theme.of(context).colorScheme,
                        isPasswordVisible: _isPasswordVisible,
                        onToggleVisibility: _togglePasswordVisibility,
                      ),
                      obscureText: !_isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.go('/forgot-password');
                        },
                        style: AppComponents.textButtonStyle(),
                        child: Text(
                          'Forgot Password?',
                          style: AppTypography.linkText.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (authProvider.isLoading)
                      AppComponents.loadingButton(
                        height: 52.0,
                        colorScheme: Theme.of(context).colorScheme,
                      )
                    else
                      ElevatedButton(
                        onPressed: _login,
                        style: AppComponents.primaryButtonStyle(),
                        child: Text(
                          'Sign In',
                          style: AppTypography.buttonPrimary,
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xl),
                    AppComponents.dividerWithText(
                      text: 'or continue with',
                      colorScheme: Theme.of(context).colorScheme,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    OutlinedButton.icon(
                      onPressed: _signInWithGoogle,
                      icon: Image.asset(
                        'assets/images/google.png',
                        height: 20.0,
                        width: 20.0,
                      ),
                      label: Text(
                        'Continue with Google',
                        style: AppTypography.buttonSecondary.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      style: AppComponents.secondaryButtonStyle(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTypography.bodyText.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            developer.log(
                              'Register now button tapped!',
                              name: 'LoginPage',
                            );
                            context.go('/register');
                          },
                          style: AppComponents.textButtonStyle(),
                          child: Text(
                            'Sign up',
                            style: AppTypography.linkText.copyWith(
                              color: Theme.of(context).colorScheme.primary,
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
