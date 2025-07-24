import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/auth/presentation/provider/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      // Redirect to login page if user is not logged in
      // This navigation logic should ideally be in a wrapper widget 
      // that listens to auth state changes at a higher level.
      // For simplicity in this example, we might navigate here.
      WidgetsBinding.instance.addPostFrameCallback((_) {
         Navigator.of(context).pushReplacementNamed('/login'); // Example navigation
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
              // Navigation after logout will be handled by the auth state listener
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
