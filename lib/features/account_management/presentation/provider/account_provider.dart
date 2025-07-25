import 'package:flutter/foundation.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/account_management/domain/entities/account.dart';
import 'package:myapp/features/account_management/domain/repositories/account_repository.dart';
import 'dart:async';
import 'dart:developer' as developer;

class AccountProvider with ChangeNotifier {
  final AccountRepository accountRepository;

  List<Account> _accounts = [];
  String _message = '';
  bool _isLoading = false;
  String _filterWebsite = '';
  StreamSubscription<List<Account>>? _accountsSubscription;

  AccountProvider({required this.accountRepository});

  // Filtered list of accounts
  List<Account> get accounts {
    if (_filterWebsite.isEmpty) {
      return _accounts;
    } else {
      return _accounts
          .where(
            (account) =>
                account.website.toLowerCase().contains(
                  _filterWebsite.toLowerCase(),
                ) ||
                account.username.toLowerCase().contains(
                  _filterWebsite.toLowerCase(),
                ),
          )
          .toList();
    }
  }

  String get message => _message;
  bool get isLoading => _isLoading;
  String get filterWebsite => _filterWebsite;

  // Method to set the website filter
  void setFilterWebsite(String filter) {
    _filterWebsite = filter;
    notifyListeners();
  }

  // Start listening to real-time updates
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
    super.dispose();
  }
}
