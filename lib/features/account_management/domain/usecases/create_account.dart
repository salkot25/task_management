import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:clarity/core/error/failures.dart';
import 'package:clarity/core/usecases/usecase.dart';
import 'package:clarity/features/account_management/domain/entities/account.dart';
import 'package:clarity/features/account_management/domain/repositories/account_repository.dart';

class CreateAccount extends UseCase<void, ParamsCreateAccount> {
  final AccountRepository repository;

  CreateAccount(this.repository);

  @override
  Future<Either<Failure, void>> call(ParamsCreateAccount params) async {
    return await repository.createAccount(params.account);
  }
}

class ParamsCreateAccount extends Equatable {
  final Account account;

  const ParamsCreateAccount({required this.account});

  @override
  List<Object?> get props => [account];
}
