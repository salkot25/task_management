import 'package:flutter/foundation.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/account_management/domain/entities/account.dart';
// Remove unused UseCase imports as we will directly use the repository methods
// import 'package:myapp/features/account_management/domain/usecases/create_account.dart';
// import 'package:myapp/features/account_management/domain/usecases/delete_account.dart';
// import 'package:myapp/features/account_management/domain/usecases/get_all_accounts.dart';
// import 'package:myapp/features/account_management/domain/usecases/update_account.dart';
// import 'package:myapp/core/usecases/usecase.dart'; // Remove unused import

import 'package:myapp/features/account_management/domain/repositories/account_repository.dart'; // Import the repository

class AccountProvider with ChangeNotifier {
  // Replace UseCases with the repository
  final AccountRepository accountRepository;

  List<Account> _accounts = [];
  String _message = '';
  bool _isLoading = false;

  AccountProvider({required this.accountRepository});

  List<Account> get accounts => _accounts;
  String get message => _message;
  bool get isLoading => _isLoading;

  // Use a Stream for real-time updates if the repository provides one
  // Or fetch once if the repository returns a Future
  Future<void> loadAccounts() async {
    _isLoading = true;
    notifyListeners();

    // If using a Stream from the repository:
    // accountRepository.getAccounts().listen((accountList) {
    //   _accounts = accountList;
    //   _isLoading = false; // Move isLoading update here if using Stream
    //   notifyListeners();
    // }, onError: (error) { // Handle stream errors
    //    _message = 'Error fetching accounts: $error';
    //    _accounts = [];
    //    _isLoading = false;
    //    notifyListeners();
    // });

    // If using Future from the repository (current implementation):
    final result = await accountRepository.getAllAccounts();
    result.fold(
      (failure) {
        _message = _mapFailureToMessage(failure);
        _accounts = [];
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
