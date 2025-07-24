import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/auth/presentation/provider/auth_provider.dart';
import 'package:go_router/go_router.dart'; // Import go_router
// Remove unused import
// import 'package:myapp/utils/app_colors.dart'; // Import app_colors
import 'dart:developer' as developer; // Import developer for logging

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController(); // Added confirm password controller

  void _register() async {
    if (_formKey.currentState!.validate()) {
      // Add password confirmation check
      if (_passwordController.text != _confirmPasswordController.text) {
        if (!mounted) return; // Add mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
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
          SnackBar(content: Text(authProvider.errorMessage ?? 'Registration Failed')),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); // Dispose confirm password controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building RegisterPage', name: 'RegisterPage'); // Replaced print with logging
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Register'),
      // ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0), // Increased padding
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch elements horizontally
              children: <Widget>[
                 // Replace FlutterLogo with Image.asset for your logo
                Image.asset(
                  'assets/images/logo.png', // Your logo asset path
                  height: 100, // Adjust height as needed
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Create Account', // Title
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall, // Use headlineSmall for title
                ),
                 const SizedBox(height: 48.0), // Increased space before fields
                TextFormField(
                  controller: _emailController,
                   decoration: InputDecoration(
                    labelText: 'Email',
                     border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      borderSide: BorderSide.none, // No border line
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200, // Changed from withOpacity
                  ),
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
                  decoration: InputDecoration(
                    labelText: 'Password',
                     border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      borderSide: BorderSide.none, // No border line
                    ),
                     filled: true,
                    fillColor: Colors.grey.shade200, // Changed from withOpacity
                  ),
                  obscureText: true,
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
                 const SizedBox(height: 16.0),
                 TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                     border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      borderSide: BorderSide.none, // No border line
                    ),
                     filled: true,
                    fillColor: Colors.grey.shade200, // Changed from withOpacity
                  ),
                  obscureText: true,
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
                const SizedBox(height: 24.0), // Increased space before register button
                if (authProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _register,
                     style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0), // Increased vertical padding
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      ),
                       backgroundColor: Theme.of(context).colorScheme.primary, // Use primary color for button background
                       foregroundColor: Theme.of(context).colorScheme.onPrimary, // Use onPrimary for text color
                    ),
                    child: const Text('Register'),
                  ),
                const SizedBox(height: 24.0), // Increased space after register button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                       style: Theme.of(context).textTheme.bodyMedium, // Use bodyMedium
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/login'); // Use go_router to navigate back to login
                      },
                      child: Text(
                        'Sign In',
                         style: TextStyle(color: Theme.of(context).colorScheme.primary), // Use primary color
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
