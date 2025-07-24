import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/account_management/data/datasources/account_local_data_source.dart';
import 'package:myapp/features/account_management/data/models/account_model.dart';
import 'package:myapp/features/account_management/domain/entities/account.dart';
import 'package:myapp/features/account_management/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountLocalDataSource localDataSource;

  AccountRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, void>> createAccount(Account account) async {
    try {
      final accountModel = AccountModel.fromEntity(account);
      await localDataSource.saveAccount(accountModel);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Account>>> getAllAccounts() async {
    try {
      final accountModels = await localDataSource.getAllAccounts();
      return Right(accountModels.map((model) => model.toEntity()).toList());
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateAccount(Account account) async {
    try {
      final accountModel = AccountModel.fromEntity(account);
      await localDataSource.updateAccount(accountModel);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String id) async {
    try {
      await localDataSource.deleteAccount(id);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}