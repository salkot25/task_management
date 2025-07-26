import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clarity/features/auth/presentation/provider/auth_provider.dart';
import 'package:clarity/utils/design_system/design_system.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ForgotPasswordPageState createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  void _sendPasswordResetEmail() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.sendPasswordResetEmail(
        _emailController.text.trim(),
      );

      if (!mounted) return; // Add mounted check
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Error sending reset email',
          ),
        ),
      );

      if (success) {
        if (!mounted) return; // Add mounted check
        if (context.canPop()) {
          Navigator.pop(context);
        } else {
          context.go('/login');
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/login');
                          }
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Logo
                    Image.asset('assets/images/logo.png', height: 120),
                    const SizedBox(height: AppSpacing.xl),
                    // Title
                    Text(
                      'Reset Password',
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
                      'Enter your email to receive reset instructions',
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
                    const SizedBox(height: AppSpacing.xxl),
                    // Reset button
                    if (authProvider.isLoading)
                      AppComponents.loadingButton(
                        height: 52.0,
                        colorScheme: Theme.of(context).colorScheme,
                      )
                    else
                      ElevatedButton(
                        onPressed: _sendPasswordResetEmail,
                        style: AppComponents.primaryButtonStyle(),
                        child: Text(
                          'Send Reset Email',
                          style: AppTypography.buttonPrimary,
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xl),
                    // Back to login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Remember your password? ",
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
