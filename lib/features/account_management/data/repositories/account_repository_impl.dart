import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/account_management/data/datasources/account_firestore_data_source.dart';
import 'package:myapp/features/account_management/domain/entities/account.dart';
import 'package:myapp/features/account_management/domain/repositories/account_repository.dart';
import 'dart:developer' as developer; // Import developer for logging

class AccountRepositoryImpl implements AccountRepository {
  final AccountFirestoreDataSource firestoreDataSource;

  AccountRepositoryImpl({required this.firestoreDataSource});

  @override
  Future<Either<Failure, void>> createAccount(Account account) async {
    try {
      await firestoreDataSource.addAccount(account);
      return const Right(null);
    } catch (e) {
       developer.log('Error creating account: $e', name: 'AccountRepository'); // Replaced print with logging
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Account>>> getAllAccounts() async {
    try {
      final accounts = await firestoreDataSource.getAccounts().first;
      return Right(accounts);
    } catch (e) {
       developer.log('Error fetching accounts: $e', name: 'AccountRepository'); // Replaced print with logging
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateAccount(Account account) async {
    try {
      await firestoreDataSource.updateAccount(account);
      return const Right(null);
    } catch (e) {
       developer.log('Error updating account: $e', name: 'AccountRepository'); // Replaced print with logging
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String id) async {
    try {
      await firestoreDataSource.deleteAccount(id);
      return const Right(null);
    } catch (e) {
       developer.log('Error deleting account: $e', name: 'AccountRepository'); // Replaced print with logging
      return Left(ServerFailure());
    }
  }
}
