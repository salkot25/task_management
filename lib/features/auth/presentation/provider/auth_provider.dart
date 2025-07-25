import 'package:flutter/material.dart';
import 'package:clarity/core/error/failures.dart';
import 'package:clarity/features/auth/domain/entities/user.dart';
import 'package:clarity/features/auth/domain/entities/profile.dart'; // Import Profile entity
import 'package:clarity/features/auth/domain/repositories/auth_repository.dart';
import 'package:clarity/features/auth/domain/repositories/profile_repository.dart'; // Import ProfileRepository
import 'package:clarity/features/auth/domain/usecases/create_profile.dart'; // Import CreateProfile use case
import 'package:clarity/features/auth/domain/usecases/get_profile.dart'; // Import GetProfile use case
import 'package:clarity/features/auth/domain/usecases/update_profile.dart'; // Import UpdateProfile use case
import 'package:clarity/features/auth/data/repositories/auth_repository_impl.dart'; // Import AuthRepositoryImpl
// Import ProfileRepositoryImpl

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  final ProfileRepository profileRepository; // Add ProfileRepository
  final CreateProfile createProfileUseCase; // Add CreateProfile use case
  final GetProfile getProfileUseCase; // Add GetProfile use case
  final UpdateProfile updateProfileUseCase; // Add UpdateProfile use case

  User? _user;
  Profile? _profile; // Add Profile object
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  Profile? get profile => _profile; // Getter for profile
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider({
    required this.authRepository,
    required this.profileRepository, // Inject ProfileRepository
    required this.createProfileUseCase, // Inject CreateProfile use case
    required this.getProfileUseCase, // Inject GetProfile use case
    required this.updateProfileUseCase, // Inject UpdateProfile use case
  }) {
    _initAuthStateListener();
  }

  void _initAuthStateListener() {
    authRepository.authStateChanges.listen((user) async {
      _user = user;
      if (user != null) {
        // If user is logged in, try to fetch profile
        await _getProfile(user.uid);
      } else {
        _profile = null; // Clear profile if user logs out
      }
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await authRepository.signInWithEmailAndPassword(
      email,
      password,
    );

    _isLoading = false;
    result.fold(
      (failure) => _errorMessage = _mapFailureToMessage(failure),
      (user) => _user = user,
    );
    if (_user != null) {
      await _getProfile(_user!.uid); // Fetch profile after successful sign in

      // Update last sign in time and email verification status
      if (_profile != null) {
        final updatedProfile = _profile!.copyWith(
          lastSignInAt: DateTime.now(),
          isEmailVerified:
              _user!.email != null, // Get from Firebase Auth if available
        );
        await updateProfile(updatedProfile);
      }
    }
    notifyListeners();
    return _user != null;
  }

  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await authRepository.signUpWithEmailAndPassword(
      email,
      password,
    );

    _isLoading = false;
    result.fold(
      (failure) => _errorMessage = _mapFailureToMessage(failure),
      (user) => _user = user,
    );
    if (_user != null) {
      await _createProfile(
        Profile(
          uid: _user!.uid,
          name: _user!.email?.split('@').first ?? 'User',
          email: _user!.email,
          createdAt: DateTime.now(),
          lastSignInAt: DateTime.now(),
          isEmailVerified:
              false, // Default to false, will be updated when verified
        ),
      ); // Create profile after sign up
      await _getProfile(_user!.uid); // Fetch newly created profile
    }
    notifyListeners();
    return _user != null;
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await authRepository.sendPasswordResetEmail(email);

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
    result.fold((failure) => _errorMessage = _mapFailureToMessage(failure), (
      _,
    ) {
      _user = null;
      _profile = null; // Clear profile on sign out
    });
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await authRepository.signInWithGoogle();

    _isLoading = false;
    result.fold(
      (failure) => _errorMessage = _mapFailureToMessage(failure),
      (user) => _user = user,
    );
    if (_user != null) {
      await _getProfile(_user!.uid); // Fetch profile after Google sign in

      // Update last sign in time and email verification status
      if (_profile != null) {
        final updatedProfile = _profile!.copyWith(
          lastSignInAt: DateTime.now(),
          isEmailVerified:
              _user!.email != null, // Google accounts are typically verified
        );
        await updateProfile(updatedProfile);
      }
    }
    notifyListeners();
    return _user != null;
  }

  // Profile management methods
  Future<void> _createProfile(Profile profile) async {
    final result = await createProfileUseCase(profile);
    result.fold(
      (failure) => _errorMessage = _mapFailureToMessage(failure),
      (_) => null,
    );
    notifyListeners();
  }

  /// Public method to create a new profile
  Future<void> createProfile(Profile profile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await createProfileUseCase(profile);
    result.fold(
      (failure) => _errorMessage = _mapFailureToMessage(failure),
      (_) => _profile = profile, // Set profile in state on success
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _getProfile(String uid) async {
    final result = await getProfileUseCase(uid);
    result.fold(
      (failure) => _errorMessage = _mapFailureToMessage(failure),
      (profile) => _profile = profile,
    );
    // Note: notifyListeners is called by the caller method
  }

  Future<void> updateProfile(Profile profile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await updateProfileUseCase(profile);
    result.fold(
      (failure) => _errorMessage = _mapFailureToMessage(failure),
      (_) => _profile = profile, // Update profile in state on success
    );
    _isLoading = false;
    notifyListeners();
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

  // Helper method to get the current user's profile
  Future<Profile?> getCurrentUserProfile() async {
    if (_user != null) {
      // Set loading state
      if (_isLoading != true || _errorMessage != null) {
        _isLoading = true;
        _errorMessage = null;
        notifyListeners();
      }

      await _getProfile(_user!.uid);

      // Always update loading state at the end
      if (_isLoading != false) {
        _isLoading = false;
        notifyListeners();
      }
    }
    return _profile;
  }
}
