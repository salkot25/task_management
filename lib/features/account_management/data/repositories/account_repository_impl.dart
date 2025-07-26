import 'package:dartz/dartz.dart';
import 'package:clarity/core/error/failures.dart';
import 'package:clarity/features/account_management/data/datasources/account_firestore_data_source.dart';
import 'package:clarity/features/account_management/domain/entities/account.dart';
import 'package:clarity/features/account_management/domain/repositories/account_repository.dart';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountFirestoreDataSource firestoreDataSource;

  AccountRepositoryImpl({required this.firestoreDataSource});

  @override
  Future<Either<Failure, void>> createAccount(Account account) async {
    try {
      // Check if user is authenticated
      if (FirebaseAuth.instance.currentUser == null) {
        developer.log(
          'User not authenticated when creating account',
          name: 'AccountRepository',
        );
        return Left(ServerFailure());
      }

      await firestoreDataSource.addAccount(account);
      developer.log(
        'Account created successfully: ${account.website}',
        name: 'AccountRepository',
      );
      return const Right(null);
    } catch (e) {
      developer.log('Error creating account: $e', name: 'AccountRepository');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Account>>> getAllAccounts() async {
    try {
      // Check if user is authenticated
      if (FirebaseAuth.instance.currentUser == null) {
        developer.log(
          'User not authenticated when fetching accounts',
          name: 'AccountRepository',
        );
        return const Right(
          [],
        ); // Return empty list instead of error for better UX
      }

      final accounts = await firestoreDataSource.getAccounts().first;
      developer.log(
        'Fetched ${accounts.length} accounts',
        name: 'AccountRepository',
      );
      return Right(accounts);
    } catch (e) {
      developer.log('Error fetching accounts: $e', name: 'AccountRepository');
      return Left(ServerFailure());
    }
  }

  @override
  Stream<List<Account>> getAllAccountsStream() {
    try {
      // Check if user is authenticated
      if (FirebaseAuth.instance.currentUser == null) {
        developer.log(
          'User not authenticated when starting accounts stream',
          name: 'AccountRepository',
        );
        return Stream.value([]); // Return empty stream instead of error
      }

      return firestoreDataSource.getAccounts();
    } catch (e) {
      developer.log(
        'Error starting accounts stream: $e',
        name: 'AccountRepository',
      );
      return Stream.value([]);
    }
  }

  @override
  Future<Either<Failure, void>> updateAccount(Account account) async {
    try {
      // Check if user is authenticated
      if (FirebaseAuth.instance.currentUser == null) {
        developer.log(
          'User not authenticated when updating account',
          name: 'AccountRepository',
        );
        return Left(ServerFailure());
      }

      await firestoreDataSource.updateAccount(account);
      developer.log(
        'Account updated successfully: ${account.website}',
        name: 'AccountRepository',
      );
      return const Right(null);
    } catch (e) {
      developer.log('Error updating account: $e', name: 'AccountRepository');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String id) async {
    try {
      // Check if user is authenticated
      if (FirebaseAuth.instance.currentUser == null) {
        developer.log(
          'User not authenticated when deleting account',
          name: 'AccountRepository',
        );
        return Left(ServerFailure());
      }

      await firestoreDataSource.deleteAccount(id);
      developer.log(
        'Account deleted successfully: $id',
        name: 'AccountRepository',
      );
      return const Right(null);
    } catch (e) {
      developer.log('Error deleting account: $e', name: 'AccountRepository');
      return Left(ServerFailure());
    }
  }
}
