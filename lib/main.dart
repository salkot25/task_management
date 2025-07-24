import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer; // Import developer for logging

// Import Theme
import 'package:myapp/utils/app_theme.dart';

// Import Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import FirebaseFirestore

// Import Auth Features
import 'package:myapp/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:myapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:myapp/features/auth/domain/repositories/profile_repository.dart'; // Import ProfileRepository
import 'package:myapp/features/auth/domain/usecases/create_profile.dart'; // Import CreateProfile use case
import 'package:myapp/features/auth/domain/usecases/get_profile.dart'; // Import GetProfile use case
import 'package:myapp/features/auth/domain/usecases/update_profile.dart'; // Import UpdateProfile use case
import 'package:myapp/features/auth/data/datasources/profile_firestore_data_source.dart'; // Import ProfileFirestoreDataSource
import 'package:myapp/features/auth/data/repositories/profile_repository_impl.dart'; // Import ProfileRepositoryImpl
import 'package:myapp/features/auth/presentation/provider/auth_provider.dart';
import 'package:myapp/features/auth/presentation/pages/login_page.dart';
import 'package:myapp/features/auth/presentation/pages/register_page.dart';
import 'package:myapp/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:myapp/features/auth/presentation/pages/profile_page.dart';

// Import Account Features
import 'package:myapp/features/account_management/data/datasources/account_firestore_data_source.dart';
import 'package:myapp/features/account_management/data/repositories/account_repository_impl.dart';
import 'package:myapp/features/account_management/presentation/provider/account_provider.dart';
import 'package:myapp/features/account_management/presentation/pages/account_list_page.dart';

// Import Task Planner Features
import 'package:myapp/features/task_planner/data/datasources/task_firestore_data_source.dart';
import 'package:myapp/features/task_planner/domain/repositories/task_repository.dart';
import 'package:myapp/features/task_planner/presentation/provider/task_provider.dart';
import 'package:myapp/features/task_planner/presentation/pages/task_planner_page.dart';

// Import Cashcard Features
import 'package:myapp/features/cashcard/data/datasources/transaction_firestore_data_source.dart';
import 'package:myapp/features/cashcard/data/repositories/transaction_repository_impl.dart';
import 'package:myapp/features/cashcard/presentation/provider/cashcard_provider.dart';
import 'package:myapp/features/cashcard/presentation/pages/cashcard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Dependency Injection Setup for Account Management (using Firestore)
  final accountFirestoreDataSource = AccountFirestoreDataSourceImpl();
  final accountRepository = AccountRepositoryImpl(
    firestoreDataSource: accountFirestoreDataSource,
  );

  // Dependency Injection Setup for Auth
  final authRemoteDataSource = AuthRemoteDataSourceImpl();
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
  );

  // Dependency Injection Setup for Profile (using Firestore)
  final profileFirestoreDataSource = ProfileFirestoreDataSourceImpl(
    firestore: FirebaseFirestore.instance,
  );
  final profileRepository = ProfileRepositoryImpl(
    firestoreDataSource: profileFirestoreDataSource,
  );
  final createProfileUseCase = CreateProfile(profileRepository);
  final getProfileUseCase = GetProfile(profileRepository);
  final updateProfileUseCase = UpdateProfile(profileRepository);

  // Dependency Injection Setup for Task Planner (using Firestore)
  final taskFirestoreDataSource = TaskFirestoreDataSourceImpl();
  final taskRepository = TaskRepositoryImpl(
    firestoreDataSource: taskFirestoreDataSource,
  );

  // Dependency Injection Setup for Cashcard (using Firestore)
  final transactionFirestoreDataSource = TransactionFirestoreDataSourceImpl();
  final transactionRepository = TransactionRepositoryImpl(
    transactionFirestoreDataSource,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (context) =>
                  AccountProvider(accountRepository: accountRepository),
        ),
        ChangeNotifierProvider(
          create:
              (context) => TaskProvider(
                taskRepository: taskRepository,
              ), // Provide taskRepository
        ),
        ChangeNotifierProvider(
          create:
              (context) => CashcardProvider(
                transactionRepository,
              ), // Provide transactionRepository
        ),
        ChangeNotifierProvider(
          create:
              (context) => AuthProvider(
                authRepository: authRepository,
                profileRepository:
                    profileRepository, // Provide profileRepository
                createProfileUseCase:
                    createProfileUseCase, // Provide createProfileUseCase
                getProfileUseCase:
                    getProfileUseCase, // Provide getProfileUseCase
                updateProfileUseCase:
                    updateProfileUseCase, // Provide updateProfileUseCase
              ),
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
        // Redirect root path to /tasks
        GoRoute(path: '/', redirect: (context, state) => '/tasks'),
        // Authentication Routes
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
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
              body:
                  navigationShell, // Display the currently selected branch's content
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
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/tasks',
                  builder: (context, state) => const TaskPlannerPage(),
                ),
              ],
            ),
            // Branch for Accounts (Vault)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/accounts',
                  builder: (context, state) => const AccountListPage(),
                ),
              ],
            ),
            // Branch for Cashcard
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/cashcard',
                  builder: (context, state) => const CashcardPage(),
                ),
              ],
            ),
            // Branch for Profile
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfilePage(),
                ),
              ],
            ),
          ],
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final bool isAuthenticated = authProvider.user != null;
        final bool isAuthenticating =
            state.uri.path == '/login' ||
            state.uri.path == '/register' ||
            state.uri.path == '/forgot-password';

        developer.log(
          'Redirect triggered:',
          name: 'Router',
        ); // Replaced print with logging
        developer.log(
          '  isAuthenticated: $isAuthenticated',
          name: 'Router',
        ); // Replaced print with logging
        developer.log(
          '  current path: ${state.uri.path}',
          name: 'Router',
        ); // Replaced print with logging

        // If the user is not authenticated and is trying to access a protected route, redirect to login
        if (!isAuthenticated && !isAuthenticating) {
          developer.log(
            '  Redirecting to /login (unauthenticated)',
            name: 'Router',
          ); // Replaced print with logging
          return '/login';
        }
        // If the user is authenticated and is trying to access an authentication route, redirect to home (or the default tab)
        if (isAuthenticated && isAuthenticating) {
          developer.log(
            '  Redirecting to / (authenticated)',
            name: 'Router',
          ); // Replaced print with logging
          return '/'; // Redirect to the default route within the StatefulShellRoute
        }

        // No redirect needed
        developer.log(
          '  No redirect needed',
          name: 'Router',
        ); // Replaced print with logging
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
