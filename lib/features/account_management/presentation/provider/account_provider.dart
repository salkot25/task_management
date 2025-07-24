import 'package:flutter/foundation.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/account_management/domain/entities/account.dart';
import 'package:myapp/features/account_management/domain/repositories/account_repository.dart';

class AccountProvider with ChangeNotifier {
  final AccountRepository accountRepository;

  List<Account> _accounts = [];
  String _message = '';
  bool _isLoading = false;
  String _filterWebsite = ''; // New state for website filter

  AccountProvider({required this.accountRepository});

  // Filtered list of accounts
  List<Account> get accounts {
    if (_filterWebsite.isEmpty) {
      return _accounts;
    } else {
      return _accounts
          .where(
            (account) => account.website.toLowerCase().contains(
              _filterWebsite.toLowerCase(),
            ),
          )
          .toList();
    }
  }

  String get message => _message;
  bool get isLoading => _isLoading;
  String get filterWebsite => _filterWebsite; // Getter for filter website

  // Method to set the website filter
  void setFilterWebsite(String filter) {
    _filterWebsite = filter;
    notifyListeners(); // Notify listeners to rebuild UI with filtered data
  }

  Future<void> loadAccounts() async {
    _isLoading = true;
    notifyListeners();

    final result = await accountRepository.getAllAccounts();
    result.fold(
      (failure) {
        _message = _mapFailureToMessage(failure);
        _accounts = []; // Clear accounts on failure
      },
      (accounts) {
        _accounts = accounts;
        _message = '';
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addAccount(Account account) async {
    _isLoading = true;
    notifyListeners();

    final result = await accountRepository.createAccount(account);
    result.fold(
      (failure) {
        _message = _mapFailureToMessage(failure);
      },
      (_) {
        _message = 'Account added successfully';
        loadAccounts(); // Reload accounts after adding
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> editAccount(Account account) async {
    _isLoading = true;
    notifyListeners();

    final result = await accountRepository.updateAccount(account);
    result.fold(
      (failure) {
        _message = _mapFailureToMessage(failure);
      },
      (_) {
        _message = 'Account updated successfully';
        loadAccounts(); // Reload accounts after updating
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeAccount(String id) async {
    _isLoading = true;
    notifyListeners();

    final result = await accountRepository.deleteAccount(id);
    result.fold(
      (failure) {
        _message = _mapFailureToMessage(failure);
      },
      (_) {
        _message = 'Account deleted successfully';
        loadAccounts(); // Reload accounts after deleting
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _: // Change to ServerFailure
        return 'Server Failure: Unable to process request';
      case CacheFailure
      _: // Keep CacheFailure case if still possible in other parts
        return 'Cache Failure: Unable to load or save data';
      default:
        return 'Unexpected Error';
    }
  }
}
