import 'package:flutter/material.dart';
import '../../features/task_planner/presentation/pages/task_planner_page.dart';
import '../../features/account_management/presentation/pages/account_list_page.dart';
import '../../features/cashcard/presentation/pages/cashcard_page.dart'; // Import CashcardPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    TaskPlannerPage(),
    AccountListPage(),
    CashcardPage(), // Add CashcardPage
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
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
            icon: Icon(Icons.account_balance_wallet_outlined), // Icon for Cashcard
            label: 'Cashcard',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary, // Use primary color from theme
        unselectedItemColor: Colors.grey, // Optional: set unselected item color
        showUnselectedLabels: true, // Show labels for unselected items
        onTap: _onItemTapped,
      ),
    );
  }
}
