import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/features/account_management/data/datasources/account_local_data_source.dart';
import 'package:myapp/features/account_management/data/models/account_model.dart';
import 'package:myapp/features/account_management/data/repositories/account_repository_impl.dart';
import 'package:myapp/features/account_management/domain/usecases/create_account.dart';
import 'package:myapp/features/account_management/domain/usecases/delete_account.dart';
import 'package:myapp/features/account_management/domain/usecases/get_all_accounts.dart';
import 'package:myapp/features/account_management/domain/usecases/update_account.dart';
import 'package:myapp/features/account_management/presentation/provider/account_provider.dart';
import 'package:provider/provider.dart';
import 'package:myapp/utils/app_theme.dart'; // Import the app_theme.dart file
// Import TaskPlannerPage
import 'package:myapp/features/task_planner/presentation/provider/task_provider.dart'; // Import TaskProvider
import 'package:myapp/features/cashcard/presentation/provider/cashcard_provider.dart'; // Import CashcardProvider
import 'package:myapp/presentation/pages/home_page.dart'; // Import HomePage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Pastikan AccountModelAdapter sudah digenerate oleh build_runner
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AccountModelAdapter());
  }

  // Dependency Injection Setup (Simple) for Account Management
  final accountLocalDataSource = AccountLocalDataSourceImpl();
  final accountRepository = AccountRepositoryImpl(localDataSource: accountLocalDataSource);
  final createAccount = CreateAccount(accountRepository);
  final getAllAccounts = GetAllAccounts(accountRepository);
  final updateAccount = UpdateAccount(accountRepository);
  final deleteAccount = DeleteAccount(accountRepository);

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
          create: (context) => TaskProvider(), // Add TaskProvider
        ),
        ChangeNotifierProvider(
          create: (context) => CashcardProvider(), // Add CashcardProvider
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      theme: lightTheme, // Use lightTheme from app_theme.dart
      darkTheme: darkTheme, // Use darkTheme from app_theme.dart
      themeMode: ThemeMode.system, // Menggunakan tema sistem (light/dark)
      home: const HomePage(), // Set HomePage as the home screen
      debugShowCheckedModeBanner: false, // Sembunyikan banner debug
    );
  }
}