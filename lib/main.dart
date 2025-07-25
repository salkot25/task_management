import 'package:flutter/material.dart';
import 'package:myapp/features/task_planner/domain/repositories/task_repository.dart'
    as task_repository_impl;
import 'package:provider/provider.dart';

// Import Theme
import 'package:myapp/utils/design_system/design_system.dart';

// Import Router
import 'package:myapp/core/routing/app_router.dart';

// Import Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import Locale
import 'package:intl/date_symbol_data_local.dart';

// Import Auth Features
import 'package:myapp/features/auth/data/datasources/auth_remote_data_source.dart'
    as auth_remote_data_source;
import 'package:myapp/features/auth/data/repositories/auth_repository_impl.dart'
    as auth_repository_impl;
import 'package:myapp/features/auth/domain/usecases/create_profile.dart';
import 'package:myapp/features/auth/domain/usecases/get_profile.dart';
import 'package:myapp/features/auth/domain/usecases/update_profile.dart';
import 'package:myapp/features/auth/data/datasources/profile_firestore_data_source.dart'
    as profile_firestore_data_source;
import 'package:myapp/features/auth/data/repositories/profile_repository_impl.dart'
    as profile_repository_impl;
import 'package:myapp/features/auth/presentation/provider/auth_provider.dart';

// Import Account Features
import 'package:myapp/features/account_management/data/datasources/account_firestore_data_source.dart'
    as account_firestore_data_source;
import 'package:myapp/features/account_management/data/repositories/account_repository_impl.dart'
    as account_repository_impl;
import 'package:myapp/features/account_management/presentation/provider/account_provider.dart';

// Import Task Planner Features
import 'package:myapp/features/task_planner/data/datasources/task_firestore_data_source.dart'
    as task_firestore_data_source;
import 'package:myapp/features/task_planner/presentation/provider/task_provider.dart';

// Import Cashcard Features
import 'package:myapp/features/cashcard/data/datasources/transaction_firestore_data_source.dart'
    as transaction_firestore_data_source;
import 'package:myapp/features/cashcard/data/repositories/transaction_repository_impl.dart'
    as transaction_repository_impl;
import 'package:myapp/features/cashcard/presentation/provider/cashcard_provider.dart';

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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) =>
              AccountProvider(accountRepository: accountRepository),
        ),
        ChangeNotifierProvider(
          create: (context) => TaskProvider(
            taskRepository: taskRepository,
          ), // Provide taskRepository
        ),
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
    return MaterialApp.router(
      title: 'Task Management',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _appRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
