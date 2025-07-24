import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import go_router
// Remove unused imports as navigation is handled by go_router
// import '../../features/task_planner/presentation/pages/task_planner_page.dart';
// import '../../features/account_management/presentation/pages/account_list_page.dart';
// import '../../features/cashcard/presentation/pages/cashcard_page.dart';
// import 'package:myapp/features/auth/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Define the routes for each tab
  final List<String> _routes = ['/tasks', '/accounts', '/cashcard', '/profile'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Use go_router to navigate to the selected route
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body will be handled by the GoRouter's Navigator
      // based on the current route.
      body: Container(), 
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_outlined),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock_outline),
            label: 'Vault',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Cashcard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
