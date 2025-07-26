import 'package:flutter/material.dart';
// Remove unused imports as navigation is handled by go_router
// import 'package:go_router/go_router.dart';
// import '../../features/task_planner/presentation/pages/task_planner_page.dart';
// import '../../features/account_management/presentation/pages/account_list_page.dart';
// import '../../features/cashcard/presentation/pages/cashcard_page.dart';
// import 'package:clarity/features/auth/presentation/pages/profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // This HomePage is now likely the initial screen after authentication
    // if the root route '/' is configured to build it.
    // You can place the main content of your authenticated landing page here.
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Welcome to the Home Page!')),
    );
  }
}
