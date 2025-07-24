import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<Either<Failure, User>> signUpWithEmailAndPassword(
    String email,
    String password,
  );
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, void>> signOut();
  Stream<User?> get authStateChanges;
  Future<Either<Failure, User>> signInWithGoogle(); // Added for Google Sign-In
}
