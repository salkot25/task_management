import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:clarity/features/task_planner/domain/repositories/task_repository.dart'
    as task_repository_impl;
import 'package:provider/provider.dart';

// Import Theme
import 'package:clarity/core/theme/enhanced_app_theme.dart';

// Import Router
import 'package:clarity/core/routing/app_router.dart';

// Import Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import Locale
import 'package:intl/date_symbol_data_local.dart';

// Import Sync Services
import 'package:clarity/core/sync/providers/sync_provider.dart';

// Import Auth Features
import 'package:clarity/features/auth/data/datasources/auth_remote_data_source.dart'
    as auth_remote_data_source;
import 'package:clarity/features/auth/data/repositories/auth_repository_impl.dart'
    as auth_repository_impl;
import 'package:clarity/features/auth/domain/usecases/create_profile.dart';
import 'package:clarity/features/auth/domain/usecases/get_profile.dart';
import 'package:clarity/features/auth/domain/usecases/update_profile.dart';
import 'package:clarity/features/auth/data/datasources/profile_firestore_data_source.dart'
    as profile_firestore_data_source;
import 'package:clarity/features/auth/data/repositories/profile_repository_impl.dart'
    as profile_repository_impl;
import 'package:clarity/features/auth/presentation/provider/auth_provider.dart';

// Import Account Features
import 'package:clarity/features/account_management/data/datasources/account_firestore_data_source.dart'
    as account_firestore_data_source;
import 'package:clarity/features/account_management/data/repositories/account_repository_impl.dart'
    as account_repository_impl;
import 'package:clarity/features/account_management/presentation/provider/account_provider.dart';

// Import Task Planner Features
import 'package:clarity/features/task_planner/data/datasources/task_firestore_data_source.dart'
    as task_firestore_data_source;
import 'package:clarity/features/task_planner/presentation/provider/task_provider.dart';

// Import Notes Features
import 'package:clarity/features/notes/presentation/provider/notes_provider.dart';

// Import Cashcard Features
import 'package:clarity/features/cashcard/data/datasources/transaction_firestore_data_source.dart'
    as transaction_firestore_data_source;
import 'package:clarity/features/cashcard/data/repositories/transaction_repository_impl.dart'
    as transaction_repository_impl;
import 'package:clarity/features/cashcard/presentation/provider/cashcard_provider.dart';

// Import Theme Provider
import 'package:clarity/core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Indonesian locale for date formatting
  await initializeDateFormatting('id_ID', null);

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

  // Initialize ThemeProvider
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  runApp(
    // Wrap dengan SyncServiceProvider untuk menyediakan sync services
    SyncServiceProvider(
      profileRepository: profileRepository,
      transactionRepository: transactionRepository,
      accountRepository: accountRepository,
      child: MultiProvider(
        providers: [
          // Theme Provider - harus di urutan pertama agar bisa diakses provider lain
          ChangeNotifierProvider.value(value: themeProvider),
          ChangeNotifierProvider(
            create: (context) =>
                AccountProvider(accountRepository: accountRepository),
          ),
          ChangeNotifierProvider(
            create: (context) => TaskProvider(
              taskRepository: taskRepository,
            ), // Provide taskRepository
          ),
          ChangeNotifierProvider(create: (context) => NotesProvider()),
          ChangeNotifierProvider(
            create: (context) => CashcardProvider(
              transactionRepository,
            ), // Provide transactionRepository
          ),
          ChangeNotifierProvider(
            create: (context) => AuthProvider(
              authRepository: authRepository,
              profileRepository: profileRepository, // Provide profileRepository
              createProfileUseCase:
                  createProfileUseCase, // Provide createProfileUseCase
              getProfileUseCase: getProfileUseCase, // Provide getProfileUseCase
              updateProfileUseCase:
                  updateProfileUseCase, // Provide updateProfileUseCase
            ),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _appRouter = AppRouter(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'Clarity',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: _appRouter.router,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            FlutterQuillLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('id')],
        );
      },
    );
  }
}
