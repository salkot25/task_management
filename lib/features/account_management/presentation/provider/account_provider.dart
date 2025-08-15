import 'package:flutter/foundation.dart';
import 'package:clarity/core/error/failures.dart';
import 'package:clarity/features/account_management/domain/entities/account.dart';
import 'package:clarity/features/account_management/domain/repositories/account_repository.dart';
import 'package:clarity/features/account_management/presentation/widgets/advanced_search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:developer' as developer;

class AccountProvider with ChangeNotifier {
  final AccountRepository accountRepository;

  List<Account> _accounts = [];
  String _message = '';
  bool _isLoading = false;
  SearchFilters _filters = const SearchFilters();
  StreamSubscription<List<Account>>? _accountsSubscription;
  StreamSubscription<User?>? _authSubscription;

  AccountProvider({required this.accountRepository}) {
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    // Listen to authentication state changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      if (user != null) {
        // User is authenticated, start listening to accounts
        startListening();
      } else {
        // User signed out, clean up and stop listening
        _accountsSubscription?.cancel();
        _accounts = [];
        _isLoading = false;
        _message = '';
        notifyListeners();
      }
    });
  }

  // Filtered list of accounts using SearchFilters
  List<Account> get accounts {
    return _accounts.applyFilters(_filters);
  }

  String get message => _message;
  bool get isLoading => _isLoading;
  SearchFilters get filters => _filters;

  // Method to update search filters
  void updateFilters(SearchFilters newFilters) {
    _filters = newFilters;
    notifyListeners();
  }

  // Convenience method for simple website filter (backward compatibility)
  void setFilterWebsite(String filter) {
    _filters = _filters.copyWith(searchQuery: filter);
    notifyListeners();
  }

  // Get available categories from current accounts
  List<String> get availableCategories {
    final categories = <String>{};
    for (final account in _accounts) {
      if (account.category != null && account.category!.isNotEmpty) {
        categories.add(account.category!);
      }
    }
    return categories.toList()..sort();
  } // Start listening to real-time updates

  void startListening() {
    developer.log(
      'Starting to listen to account changes',
      name: 'AccountProvider',
    );
    _isLoading = true;
    notifyListeners();

    _accountsSubscription?.cancel(); // Cancel any existing subscription

    // Listen to the accounts stream from repository
    _accountsSubscription = _listenToAccounts();
  }

  StreamSubscription<List<Account>> _listenToAccounts() {
    return accountRepository.getAllAccountsStream().listen(
      (accounts) {
        developer.log(
          'Received ${accounts.length} accounts from stream',
          name: 'AccountProvider',
        );
        _accounts = accounts;
        _isLoading = false;
        _message = '';
        notifyListeners();
      },
      onError: (error) {
        developer.log(
          'Error in accounts stream: $error',
          name: 'AccountProvider',
        );
        _message = 'Error loading accounts';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> loadAccounts() async {
    developer.log('Loading accounts manually', name: 'AccountProvider');
    _isLoading = true;
    notifyListeners();

    final result = await accountRepository.getAllAccounts();
    result.fold(
      (failure) {
        _message = _mapFailureToMessage(failure);
        _accounts = [];
        developer.log(
          'Failed to load accounts: $_message',
          name: 'AccountProvider',
        );
      },
      (accounts) {
        _accounts = accounts;
        _message = '';
        developer.log(
          'Loaded ${accounts.length} accounts manually',
          name: 'AccountProvider',
        );
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addAccount(Account account) async {
    developer.log(
      'Adding account: ${account.website}',
      name: 'AccountProvider',
    );
    _isLoading = true;
    notifyListeners();

    final result = await accountRepository.createAccount(account);
    result.fold(
      (failure) {
        _message = _mapFailureToMessage(failure);
        developer.log(
          'Failed to add account: $_message',
          name: 'AccountProvider',
        );
      },
      (_) {
        _message = 'Account added successfully';
        developer.log(
          'Account added successfully: ${account.website}',
          name: 'AccountProvider',
        );
        // No need to manually reload - real-time listener will handle it
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> editAccount(Account account) async {
    developer.log(
      'Editing account: ${account.website}',
      name: 'AccountProvider',
    );
    _isLoading = true;
    notifyListeners();

    final result = await accountRepository.updateAccount(account);
    result.fold(
      (failure) {
        _message = _mapFailureToMessage(failure);
        developer.log(
          'Failed to edit account: $_message',
          name: 'AccountProvider',
        );
      },
      (_) {
        _message = 'Account updated successfully';
        developer.log(
          'Account updated successfully: ${account.website}',
          name: 'AccountProvider',
        );
        // No need to manually reload - real-time listener will handle it
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeAccount(String id) async {
    developer.log('Removing account: $id', name: 'AccountProvider');
    _isLoading = true;
    notifyListeners();

    final result = await accountRepository.deleteAccount(id);
    result.fold(
      (failure) {
        _message = _mapFailureToMessage(failure);
        developer.log(
          'Failed to remove account: $_message',
          name: 'AccountProvider',
        );
      },
      (_) {
        _message = 'Account deleted successfully';
        developer.log(
          'Account deleted successfully: $id',
          name: 'AccountProvider',
        );
        // No need to manually reload - real-time listener will handle it
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server Failure: Unable to process request';
      case CacheFailure _:
        return 'Cache Failure: Unable to load or save data';
      default:
        return 'Unexpected Error';
    }
  }

  @override
  void dispose() {
    developer.log('Disposing AccountProvider', name: 'AccountProvider');
    _accountsSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
