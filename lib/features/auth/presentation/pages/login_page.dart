import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/auth/presentation/provider/auth_provider.dart';
import 'package:go_router/go_router.dart'; // Import go_router
// Remove unused imports as navigation is handled by go_router
// import 'package:myapp/features/auth/presentation/pages/register_page.dart';
// import 'package:myapp/features/auth/presentation/pages/forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
          SnackBar(content: Text(authProvider.errorMessage ?? 'Google Sign In Failed')),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                if (authProvider.isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
                const SizedBox(height: 16.0),
                 TextButton(
                  onPressed: _signInWithGoogle, // Added Google Sign-In button
                  child: const Text('Sign in with Google'),
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    context.go('/register'); // Use go_router
                  },
                  child: const Text("Don't have an account? Sign Up"),
                ),
                TextButton(
                  onPressed: () {
                    context.go('/forgot-password'); // Use go_router
                  },
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
