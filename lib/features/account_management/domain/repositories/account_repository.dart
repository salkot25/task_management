import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/account_management/domain/entities/account.dart';

abstract class AccountRepository {
  Future<Either<Failure, void>> createAccount(Account account);
  Future<Either<Failure, List<Account>>> getAllAccounts();
  Future<Either<Failure, void>> updateAccount(Account account);
  Future<Either<Failure, void>> deleteAccount(String id);
}
