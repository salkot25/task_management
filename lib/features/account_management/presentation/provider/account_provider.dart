import 'package:flutter/foundation.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/account_management/domain/entities/account.dart';
import 'package:myapp/features/account_management/domain/usecases/create_account.dart';
import 'package:myapp/features/account_management/domain/usecases/delete_account.dart';
import 'package:myapp/features/account_management/domain/usecases/get_all_accounts.dart';
import 'package:myapp/features/account_management/domain/usecases/update_account.dart';
import 'package:myapp/core/usecases/usecase.dart';

class AccountProvider with ChangeNotifier {
  final CreateAccount createAccountUseCase;
  final GetAllAccounts getAllAccountsUseCase;
  final UpdateAccount updateAccountUseCase;
  final DeleteAccount deleteAccountUseCase;

  List<Account> _accounts = [];
  String _message = '';
  bool _isLoading = false;

  AccountProvider({
    required this.createAccountUseCase,
    required this.getAllAccountsUseCase,
    required this.updateAccountUseCase,
    required this.deleteAccountUseCase,
  });

  List<Account> get accounts => _accounts;
  String get message => _message;
  bool get isLoading => _isLoading;

  Future<void> loadAccounts() async {
    _isLoading = true;
    notifyListeners();

    final result = await getAllAccountsUseCase(NoParams());
    result.fold(
      (failure) {
        _message = _mapFailureToMessage(failure);
        _accounts = [];
      },
      (accounts) {
        // Hapus karakter 'a' yang salah
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

    final result = await createAccountUseCase(ParamsCreateAccount(account: account));
    result.fold(
      (failure) {
        _message = _mapFailureToMessage(failure);
      },
      (_) {
        // Hapus underscore dari variabel lokal message
        final message = 'Account added successfully';
        _message = message;
        loadAccounts(); // Reload accounts after adding
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> editAccount(Account account) async {
    _isLoading = true;
    notifyListeners();

    final result = await updateAccountUseCase(ParamsUpdateAccount(account: account));
    result.fold(
      (failure) {
        _message = _mapFailureToMessage(failure);
      },
      (_) {
         // Hapus underscore dari variabel lokal message
        final message = 'Account updated successfully';
        _message = message;
        loadAccounts(); // Reload accounts after updating
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeAccount(String id) async {
    _isLoading = true;
    notifyListeners();

    final result = await deleteAccountUseCase(ParamsDeleteAccount(id: id));
    result.fold(
      (failure) {
        _message = _mapFailureToMessage(failure);
      },
      (_) {
         // Hapus underscore dari variabel lokal message
        final message = 'Account deleted successfully';
        _message = message;
        loadAccounts(); // Reload accounts after deleting
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case CacheFailure _: // Diubah
        return 'Cache Failure: Unable to load or save data';
      default:
        return 'Unexpected Error';
    }
  }
}