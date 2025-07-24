import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/account_management/domain/entities/account.dart';
import 'package:myapp/features/account_management/domain/repositories/account_repository.dart';

class GetAllAccounts extends UseCase<List<Account>, NoParams> {
  final AccountRepository repository;

  GetAllAccounts(this.repository);

  @override
  Future<Either<Failure, List<Account>>> call(NoParams params) async {
    return await repository.getAllAccounts();
  }
}
