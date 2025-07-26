import 'package:dartz/dartz.dart';
import 'package:clarity/core/error/failures.dart';
import 'package:clarity/core/usecases/usecase.dart';
import 'package:clarity/features/account_management/domain/entities/account.dart';
import 'package:clarity/features/account_management/domain/repositories/account_repository.dart';

class GetAllAccounts extends UseCase<List<Account>, NoParams> {
  final AccountRepository repository;

  GetAllAccounts(this.repository);

  @override
  Future<Either<Failure, List<Account>>> call(NoParams params) async {
    return await repository.getAllAccounts();
  }
}
