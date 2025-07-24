import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/auth/data/datasources/auth_remote_data_source.dart';
// import 'package:myapp/features/auth/data/models/user_model.dart'; // Remove this import
import 'package:myapp/features/auth/domain/entities/user.dart';
import 'package:myapp/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userModel = await remoteDataSource.signInWithEmailAndPassword(
        email,
        password,
      );
      return Right(
        User(uid: userModel.uid, email: userModel.email),
      ); // Convert UserModel to User
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors and convert to Failure
      return Left(_handleFirebaseAuthException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userModel = await remoteDataSource.signUpWithEmailAndPassword(
        email,
        password,
      );
      return Right(
        User(uid: userModel.uid, email: userModel.email),
      ); // Convert UserModel to User
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return remoteDataSource.authStateChanges.map(
      (userModel) =>
          userModel != null
              ? User(uid: userModel.uid, email: userModel.email)
              : null,
    ); // Convert UserModel to User
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final userModel =
          await remoteDataSource.signInWithGoogle(); // Use remote data source
      return Right(
        User(uid: userModel.uid, email: userModel.email),
      ); // Convert UserModel to User
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _handleFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthFailure('No user found for that email.');
      case 'wrong-password':
        return AuthFailure('Wrong password provided for that user.');
      case 'email-already-in-use':
        return AuthFailure('The account already exists for that email.');
      case 'weak-password':
        return AuthFailure('The password provided is too weak.');
      default:
        return AuthFailure(
          e.message ?? 'An unknown authentication error occurred.',
        );
    }
  }
}

class AuthFailure extends Failure {
  final String message;
  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
