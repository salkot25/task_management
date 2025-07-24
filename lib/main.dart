import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/features/account_management/data/datasources/account_local_data_source.dart';
import 'package:myapp/features/account_management/data/models/account_model.dart'; // Import AccountModel
import 'package:myapp/features/account_management/data/repositories/account_repository_impl.dart';
import 'package:myapp/features/account_management/domain/usecases/create_account.dart';
import 'package:myapp/features/account_management/domain/usecases/delete_account.dart';
import 'package:myapp/features/account_management/domain/usecases/get_all_accounts.dart';
import 'package:myapp/features/account_management/domain/usecases/update_account.dart';
import 'package:myapp/features/account_management/presentation/provider/account_provider.dart';
import 'package:provider/provider.dart';
import 'package:myapp/utils/app_theme.dart'; // Import the app_theme.dart file
import 'package:myapp/features/task_planner/presentation/provider/task_provider.dart'; // Import TaskProvider
import 'package:myapp/features/cashcard/presentation/provider/cashcard_provider.dart'; // Import CashcardProvider
import 'package:myapp/presentation/pages/home_page.dart'; // Import HomePage
import 'package:firebase_core/firebase_core.dart'; // Import firebase_core
import 'firebase_options.dart'; // Import firebase_options.dart
import 'package:myapp/features/auth/presentation/provider/auth_provider.dart'; // Import AuthProvider
import 'package:myapp/features/auth/data/repositories/auth_repository_impl.dart'; // Import AuthRepositoryImpl
import 'package:myapp/features/auth/data/datasources/auth_remote_data_source.dart'; // Import AuthRemoteDataSource
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:myapp/features/auth/presentation/pages/login_page.dart'; // Import LoginPage
import 'package:myapp/features/auth/presentation/pages/register_page.dart'; // Import RegisterPage
import 'package:myapp/features/auth/presentation/pages/forgot_password_page.dart'; // Import ForgotPasswordPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  // Pastikan AccountModelAdapter sudah digenerate oleh build_runner
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AccountModelAdapter());
  }

  // Dependency Injection Setup (Simple) for Account Management
  final accountLocalDataSource = AccountLocalDataSourceImpl();
  final accountRepository =
      AccountRepositoryImpl(localDataSource: accountLocalDataSource);
  final createAccount = CreateAccount(accountRepository);
  final getAllAccounts = GetAllAccounts(accountRepository);
  final updateAccount = UpdateAccount(accountRepository);
  final deleteAccount = DeleteAccount(accountRepository);

  // Dependency Injection Setup for Auth
  final authRemoteDataSource = AuthRemoteDataSourceImpl();
  final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AccountProvider(
            createAccountUseCase: createAccount,
            getAllAccountsUseCase: getAllAccounts,
            updateAccountUseCase: updateAccount,
            deleteAccountUseCase: deleteAccount,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => TaskProvider(),
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
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
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
        // Add routes for other main pages if needed (e.g., /tasks, /accounts, /cashcard, /profile)
        // GoRoute(
        //   path: '/tasks',
        //   builder: (context, state) => const TaskPlannerPage(),
        // ),
        // GoRoute(
        //   path: '/accounts',
        //   builder: (context, state) => const AccountListPage(),
        // ),
         //GoRoute(
        //   path: '/cashcard',
        //   builder: (context, state) => const CashcardPage(),
        // ),
        // GoRoute(
        //   path: '/profile',
        //   builder: (context, state) => const ProfilePage(),
        // ),
      ],
      redirect:
          (BuildContext context, GoRouterState state) {
        final bool isAuthenticated = authProvider.user != null;
        final bool isLoggingIn = state.uri.path == '/login';

        // If the user is not authenticated and is not on the login page, redirect to login
        if (!isAuthenticated && !isLoggingIn) {
          return '/login';
        }
        // If the user is authenticated and is on the login page, redirect to home
        if (isAuthenticated && isLoggingIn) {
          return '/';
        }

        // No redirect needed
        return null;
      },
       refreshListenable: authProvider, // Listen to auth state changes
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Password Manager',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router, // Use routerConfig instead of home
      debugShowCheckedModeBanner: false,
    );
  }
}