import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/auth/presentation/provider/auth_provider.dart';
import 'package:go_router/go_router.dart'; // Import go_router

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      // Redirect to login page if user is not logged in
      // This navigation logic is now handled by go_router's redirect.
      // However, if this page is accessed directly somehow while unauthenticated,
      // we can still use go_router to navigate.
       WidgetsBinding.instance.addPostFrameCallback((_) {
         context.go('/login'); // Use go_router for navigation
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()), // Or a loading/redirect message
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              // Navigation after logout will be handled by go_router's redirect
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'User ID: ${user.uid}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Email: ${user.email ?? 'N/A'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            // Add more user information here if available in your User entity
          ],
        ),
      ),
    );
  }
}
