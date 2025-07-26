import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clarity/features/auth/presentation/provider/auth_provider.dart';
import 'package:clarity/features/auth/presentation/pages/login_page.dart';
import 'package:clarity/presentation/pages/home_page.dart'; // Assuming your main authenticated page is HomePage

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // If the user is loading, show a loading spinner
    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If the user is logged in, show the home page
    if (authProvider.user != null) {
      return const HomePage();
    } else {
      // Otherwise, show the login page
      return const LoginPage();
    }
  }
}
