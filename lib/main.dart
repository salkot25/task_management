import 'package:flutter/material.dart';
import 'package:myapp/features/task_planner/domain/repositories/task_repository.dart' as task_repository_impl;
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
import 'package:myapp/features/auth/data/datasources/auth_remote_data_source.dart'
    as auth_remote_data_source;
import 'package:myapp/features/auth/data/repositories/auth_repository_impl.dart'
    as auth_repository_impl;
import 'package:myapp/features/auth/domain/repositories/profile_repository.dart';
import 'package:myapp/features/auth/domain/usecases/create_profile.dart';
import 'package:myapp/features/auth/domain/usecases/get_profile.dart';
import 'package:myapp/features/auth/domain/usecases/update_profile.dart';
import 'package:myapp/features/auth/data/datasources/profile_firestore_data_source.dart'
    as profile_firestore_data_source;
import 'package:myapp/features/auth/data/repositories/profile_repository_impl.dart'
    as profile_repository_impl;
import 'package:myapp/features/auth/presentation/provider/auth_provider.dart';
import 'package:myapp/features/auth/presentation/pages/login_page.dart';
import 'package:myapp/features/auth/presentation/pages/register_page.dart';
import 'package:myapp/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:myapp/features/auth/presentation/pages/profile_page.dart';

// Import Account Features
import 'package:myapp/features/account_management/data/datasources/account_firestore_data_source.dart'
    as account_firestore_data_source;
import 'package:myapp/features/account_management/data/repositories/account_repository_impl.dart'
    as account_repository_impl;
import 'package:myapp/features/account_management/presentation/provider/account_provider.dart';
import 'package:myapp/features/account_management/presentation/pages/account_list_page.dart';

// Import Task Planner Features
import 'package:myapp/features/task_planner/data/datasources/task_firestore_data_source.dart'
    as task_firestore_data_source;
import 'package:myapp/features/task_planner/domain/repositories/task_repository.dart';
import 'package:myapp/features/task_planner/presentation/provider/task_provider.dart';
import 'package:myapp/features/task_planner/presentation/pages/task_planner_page.dart';

// Import Cashcard Features
import 'package:myapp/features/cashcard/data/datasources/transaction_firestore_data_source.dart'
    as transaction_firestore_data_source;
import 'package:myapp/features/cashcard/data/repositories/transaction_repository_impl.dart'
    as transaction_repository_impl;
import 'package:myapp/features/cashcard/presentation/provider/cashcard_provider.dart';
import 'package:myapp/features/cashcard/presentation/pages/cashcard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Dependency Injection Setup for Account Management (using Firestore)
  final accountFirestoreDataSource =
      account_firestore_data_source.AccountFirestoreDataSourceImpl();
  final accountRepository = account_repository_impl.AccountRepositoryImpl(
    firestoreDataSource: accountFirestoreDataSource,
  );

  // Dependency Injection Setup for Auth
  final authRemoteDataSource =
      auth_remote_data_source.AuthRemoteDataSourceImpl();
  final authRepository = auth_repository_impl.AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
  );

  // Dependency Injection Setup for Profile (using Firestore)
  final profileFirestoreDataSource =
      profile_firestore_data_source.ProfileFirestoreDataSourceImpl(
        firestore: FirebaseFirestore.instance,
      );
  final profileRepository = profile_repository_impl.ProfileRepositoryImpl(
    firestoreDataSource: profileFirestoreDataSource,
  );
  final createProfileUseCase = CreateProfile(profileRepository);
  final getProfileUseCase = GetProfile(profileRepository);
  final updateProfileUseCase = UpdateProfile(profileRepository);

  // Dependency Injection Setup for Task Planner (using Firestore)
  final taskFirestoreDataSource =
      task_firestore_data_source.TaskFirestoreDataSourceImpl();
  final taskRepository = task_repository_impl.TaskRepositoryImpl(
    firestoreDataSource: taskFirestoreDataSource,
  );

  // Dependency Injection Setup for Cashcard (using Firestore)
  final transactionFirestoreDataSource =
      transaction_firestore_data_source.TransactionFirestoreDataSourceImpl();
  final transactionRepository =
      transaction_repository_impl.TransactionRepositoryImpl(
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
                type:
                    BottomNavigationBarType
                        .fixed, // Ensure items are fixed width
                backgroundColor:
                    Theme.of(context).colorScheme.surface, // Light background
                selectedItemColor:
                    Theme.of(
                      context,
                    ).colorScheme.primary, // Accent color for selected
                unselectedItemColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(
                  0.6,
                ), // Darker color with opacity for unselected
                showUnselectedLabels: true,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ), // Optional: make selected label bold
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                ), // Optional: make unselected label normal
                currentIndex: navigationShell.currentIndex,
                onTap: (index) {
                  // Use the navigationShell to navigate to the selected branch
                  navigationShell.goBranch(index);
                },
                items: [
                  BottomNavigationBarItem(
                    icon: _buildNavItemIcon(
                      Icons.checklist_outlined,
                      navigationShell.currentIndex == 0,
                      context,
                    ), // Custom icon builder
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildNavItemIcon(
                      Icons.lock_outline,
                      navigationShell.currentIndex == 1,
                      context,
                    ), // Custom icon builder
                    label: 'Vault',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildNavItemIcon(
                      Icons.account_balance_wallet_outlined,
                      navigationShell.currentIndex == 2,
                      context,
                    ), // Custom icon builder
                    label: 'Cashcard',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildNavItemIcon(
                      Icons.person_outline,
                      navigationShell.currentIndex == 3,
                      context,
                    ), // Custom icon builder
                    label: 'Profile',
                  ),
                ],
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

  // Helper method to build custom nav bar item icon
  Widget _buildNavItemIcon(
    IconData iconData,
    bool isSelected,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 6.0,
      ), // Adjust padding for the background
      decoration:
          isSelected
              ? BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(
                  0.15,
                ), // Light accent color background
                borderRadius: BorderRadius.circular(20.0), // Rounded corners
              )
              : null, // No decoration when not selected
      child: Icon(
        iconData,
        color:
            isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ), // Apply colors here
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
