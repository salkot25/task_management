import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/auth/presentation/provider/auth_provider.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:myapp/utils/app_colors.dart'; // Import app_colors

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
      // appBar: AppBar(
      //   title: const Text('Login'),
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
                  'FRACTALZ', // App Name/Tagline
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall, // Use headlineSmall for tagline
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
                    fillColor: greyLightColor.withOpacity(0.4), // Light grey background
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
                    fillColor: greyLightColor.withOpacity(0.4), // Light grey background
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.go('/forgot-password');
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary), // Use primary color for text button
                      ),
                  ),
                ),
                const SizedBox(height: 24.0), // Increased space before login button
                 if (authProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0), // Increased vertical padding
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      ),
                       backgroundColor: Theme.of(context).colorScheme.primary, // Use primary color for button background
                       foregroundColor: Theme.of(context).colorScheme.onPrimary, // Use onPrimary for text color
                    ),
                    child: const Text('Login'),
                  ),
                const SizedBox(height: 24.0), // Increased space after login button
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: Divider(thickness: 1.0), // Divider line
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Or sign in with',
                        style: Theme.of(context).textTheme.bodyMedium, // Use bodyMedium for this text
                      ),
                    ),
                    const Expanded(
                      child: Divider(thickness: 1.0), // Divider line
                    ),
                  ],
                ),
                const SizedBox(height: 24.0), // Space after separator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Placeholder for Apple Sign-In button (if needed later)
                    // Container(
                    //   width: 60, // Adjust size as needed
                    //   height: 60,
                    //   decoration: BoxDecoration(
                    //     border: Border.all(color: Colors.grey.shade400), // Border around button
                    //     borderRadius: BorderRadius.circular(8.0),
                    //   ),
                    //   child: IconButton(
                    //     icon: Image.asset('assets/images/apple_logo.png'), // Replace with Apple logo asset
                    //     onPressed: () {},
                    //   ),
                    // ),
                    // const SizedBox(width: 16.0), // Space between buttons
                    Container(
                      width: 60, // Adjust size as needed
                      height: 60,
                       decoration: BoxDecoration(
                        border: Border.all(color: greyColor.withOpacity(0.5)), // Border around button
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      ),
                      child: IconButton(
                        icon: Image.asset(
                           'assets/images/google.png', // Google logo asset
                            width: 30, // Adjust logo size
                        ),
                        onPressed: _signInWithGoogle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0), // Space before Register text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium, // Use bodyMedium
                    ),
                    TextButton(
                      onPressed: () {
                         print('Register now button tapped!'); // Added logging
                        context.go('/register');
                      },
                      child: Text(
                        'Register now',
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
