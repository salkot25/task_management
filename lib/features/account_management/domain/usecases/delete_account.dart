import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/account_management/domain/repositories/account_repository.dart';

class DeleteAccount extends UseCase<void, ParamsDeleteAccount> {
  final AccountRepository repository;

  DeleteAccount(this.repository);

  @override
  Future<Either<Failure, void>> call(ParamsDeleteAccount params) async {
    return await repository.deleteAccount(params.id);
  }
}

class ParamsDeleteAccount extends Equatable {
  final String id;

  const ParamsDeleteAccount({required this.id});

  @override
  List<Object?> get props => [id];
}