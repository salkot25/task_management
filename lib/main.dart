import 'package:flutter/material.dart';
// Remove all Hive related imports
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:myapp/features/account_management/data/datasources/account_local_data_source.dart';
// import 'package:myapp/features/account_management/data/models/account_model.dart'; // Import AccountModel
import 'package:myapp/features/account_management/data/repositories/account_repository_impl.dart';
// Remove UseCase imports
// import 'package:myapp/features/account_management/domain/usecases/create_account.dart';
// import 'package:myapp/features/account_management/domain/usecases/delete_account.dart';
// import 'package:myapp/features/account_management/domain/usecases/get_all_accounts.dart';
// import 'package:myapp/features/account_management/domain/usecases/update_account.dart';
import 'package:myapp/features/account_management/presentation/provider/account_provider.dart';
import 'package:provider/provider.dart';
import 'package:myapp/utils/app_theme.dart'; // Import the app_theme.dart file
import 'package:myapp/features/task_planner/presentation/provider/task_provider.dart'; // Import TaskProvider
import 'package:myapp/features/cashcard/presentation/provider/cashcard_provider.dart'; // Import CashcardProvider
// Remove unused import as HomePage will be part of StatefulShellRoute
// import 'package:myapp/presentation/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart'; // Import firebase_core
import 'firebase_options.dart'; // Import firebase_options.dart
import 'package:myapp/features/auth/presentation/provider/auth_provider.dart'; // Import AuthProvider
import 'package:myapp/features/auth/data/repositories/auth_repository_impl.dart'; // Import AuthRepositoryImpl
import 'package:myapp/features/auth/data/datasources/auth_remote_data_source.dart'; // Import AuthRemoteDataSource
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:myapp/features/auth/presentation/pages/login_page.dart'; // Import LoginPage
import 'package:myapp/features/auth/presentation/pages/register_page.dart'; // Import RegisterPage
import 'package:myapp/features/auth/presentation/pages/forgot_password_page.dart'; // Import ForgotPasswordPage

// Import the pages for the bottom navigation bar
import 'package:myapp/features/task_planner/presentation/pages/task_planner_page.dart';
import 'package:myapp/features/account_management/presentation/pages/account_list_page.dart';
import 'package:myapp/features/cashcard/presentation/pages/cashcard_page.dart';
import 'package:myapp/features/auth/presentation/pages/profile_page.dart';

// Import TaskPlanner dependencies
import 'package:myapp/features/task_planner/data/datasources/task_firestore_data_source.dart';
import 'package:myapp/features/task_planner/domain/repositories/task_repository.dart';

// Import Account Management Firestore dependencies
import 'package:myapp/features/account_management/data/datasources/account_firestore_data_source.dart';
import 'dart:developer' as developer; // Import developer for logging

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Remove all Hive initialization related to Account Management
  // await Hive.initFlutter();
  // // Pastikan AccountModelAdapter sudah digenerasi oleh build_runner
  // if (!Hive.isAdapterRegistered(0)) {
  //   Hive.registerAdapter(AccountModelAdapter());
  // }

  // Dependency Injection Setup for Account Management (using Firestore)
  final accountFirestoreDataSource = AccountFirestoreDataSourceImpl();
  final accountRepository = AccountRepositoryImpl(firestoreDataSource: accountFirestoreDataSource);
  // Remove UseCase instances
  // final createAccount = CreateAccount(accountRepository);
  // final getAllAccounts = GetAllAccounts(accountRepository);
  // final updateAccount = UpdateAccount(accountRepository);
  // final deleteAccount = DeleteAccount(accountRepository);

  // Dependency Injection Setup for Auth
  final authRemoteDataSource = AuthRemoteDataSourceImpl();
  final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);

  // Dependency Injection Setup for Task Planner (using Firestore)
  final taskFirestoreDataSource = TaskFirestoreDataSourceImpl();
  final taskRepository = TaskRepositoryImpl(firestoreDataSource: taskFirestoreDataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AccountProvider(
            accountRepository: accountRepository, // Provide the Firestore-based repository
            // Remove UseCase arguments
            // createAccountUseCase: createAccount,
            // getAllAccountsUseCase: getAllAccounts,
            // updateAccountUseCase: updateAccount,
            // deleteAccountUseCase: deleteAccount,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => TaskProvider(taskRepository: taskRepository), // Provide taskRepository
        ),
        ChangeNotifierProvider(
          create: (context) => CashcardProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(authRepository: authRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();

    _router = GoRouter(
      routes: [
        // Authentication Routes
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
         GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
         GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),

        // Stateful shell route for bottom navigation bar
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            // the UI shell
            return Scaffold(
              body: navigationShell, // Display the currently selected branch's content
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
                currentIndex: navigationShell.currentIndex,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: Colors.grey,
                showUnselectedLabels: true,
                 onTap: (index) {
                  // Use the navigationShell to navigate to the selected branch
                  navigationShell.goBranch(index);
                },
              ),
            );
          },
          branches: [
            // Branch for Tasks
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const TaskPlannerPage(),
              ),
            ]),
            // Branch for Accounts (Vault)
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/accounts',
                builder: (context, state) => const AccountListPage(),
              ),
            ]),
            // Branch for Cashcard
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/cashcard',
                builder: (context, state) => const CashcardPage(),
              ),
            ]),
            // Branch for Profile
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ]),
          ],
        ),
      ],
      redirect:
          (BuildContext context, GoRouterState state) {
        final bool isAuthenticated = authProvider.user != null;
        final bool isAuthenticating = state.uri.path == '/login' || state.uri.path == '/register' || state.uri.path == '/forgot-password';

        developer.log('Redirect triggered:', name: 'Router'); // Replaced print with logging
        developer.log('  isAuthenticated: $isAuthenticated', name: 'Router'); // Replaced print with logging
        developer.log('  current path: ${state.uri.path}', name: 'Router'); // Replaced print with logging

        // If the user is not authenticated and is trying to access a protected route, redirect to login
        if (!isAuthenticated && !isAuthenticating) {
           developer.log('  Redirecting to /login (unauthenticated)', name: 'Router'); // Replaced print with logging
          return '/login';
        }
        // If the user is authenticated and is trying to access an authentication route, redirect to home (or the default tab)
        if (isAuthenticated && isAuthenticating) {
           developer.log('  Redirecting to / (authenticated)', name: 'Router'); // Replaced print with logging
          return '/'; // Redirect to the default route within the StatefulShellRoute
        }

        // No redirect needed
         developer.log('  No redirect needed', name: 'Router'); // Replaced print with logging
        return null;
      },
       refreshListenable: authProvider, // Listen to auth state changes
      initialLocation: '/tasks', // Set the initial location to the first tab
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Password Manager',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}