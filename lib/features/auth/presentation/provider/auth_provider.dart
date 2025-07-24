import 'package:flutter/material.dart';
// Remove unused import: import 'package:provider/provider.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:myapp/features/auth/domain/entities/user.dart';
// Remove unused import: import 'package:myapp/features/auth/domain/usecases/sign_in_usecase.dart';
// Remove unused import: import 'package:myapp/features/auth/domain/usecases/sign_up_usecase.dart';
// Remove unused import: import 'package:myapp/features/auth/domain/usecases/send_password_reset_email_usecase.dart';
import 'package:myapp/features/auth/domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  // Keep use cases for clarity, even if not directly used in the provider logic anymore
  // final SignInUseCase signInUseCase;
  // final SignUpUseCase signUpUseCase;
  // final SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase;
  final AuthRepository authRepository;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider({
    // required this.signInUseCase,
    // required this.signUpUseCase,
    // required this.sendPasswordResetEmailUseCase,
    required this.authRepository,
  }) {
    _initAuthStateListener();
  }

  void _initAuthStateListener() {
    authRepository.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await authRepository.signInWithEmailAndPassword(email, password); // Use repository directly

    _isLoading = false;
    result.fold(
      (failure) => _errorMessage = _mapFailureToMessage(failure),
      (user) => _user = user,
    );
    notifyListeners();
    return _user != null;
  }

  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await authRepository.signUpWithEmailAndPassword(email, password); // Use repository directly

    _isLoading = false;
    result.fold(
      (failure) => _errorMessage = _mapFailureToMessage(failure),
      (user) => _user = user,
    );
    notifyListeners();
    return _user != null;
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await authRepository.sendPasswordResetEmail(email); // Use repository directly

    _isLoading = false;
    result.fold(
      (failure) => _errorMessage = _mapFailureToMessage(failure),
      (_) => _errorMessage = 'Password reset email sent.',
    );
    notifyListeners();
    return _errorMessage == 'Password reset email sent.';
  }

  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await authRepository.signOut();

    _isLoading = false;
    result.fold(
      (failure) => _errorMessage = _mapFailureToMessage(failure),
      (_) => _user = null,
    );
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async { // Added for Google Sign-In
     _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await authRepository.signInWithGoogle();

    _isLoading = false;
    result.fold(
      (failure) => _errorMessage = _mapFailureToMessage(failure),
      (user) => _user = user,
    );
    notifyListeners();
    return _user != null;
  }

  String? _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _: // Applied fix
        return (failure as ServerFailure).message;
      case AuthFailure _: // Applied fix
        return (failure as AuthFailure).message;
      default:
        return 'Unexpected Error';
    }
  }
}
