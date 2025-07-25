import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:clarity/core/error/failures.dart';
import 'package:clarity/core/usecases/usecase.dart';
import 'package:clarity/features/account_management/domain/entities/account.dart';
import 'package:clarity/features/account_management/domain/repositories/account_repository.dart';

class UpdateAccount extends UseCase<void, ParamsUpdateAccount> {
  final AccountRepository repository;

  UpdateAccount(this.repository);

  @override
  Future<Either<Failure, void>> call(ParamsUpdateAccount params) async {
    return await repository.updateAccount(params.account);
  }
}

class ParamsUpdateAccount extends Equatable {
  final Account account;

  const ParamsUpdateAccount({required this.account});

  @override
  List<Object?> get props => [account];
}
