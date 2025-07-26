import 'package:dartz/dartz.dart';
import 'package:clarity/core/error/failures.dart';
import 'package:clarity/core/usecases/usecase.dart';
import 'package:clarity/features/auth/domain/repositories/auth_repository.dart';

class SendPasswordResetEmailUseCase implements UseCase<void, String> {
  final AuthRepository repository;

  SendPasswordResetEmailUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String email) async {
    return await repository.sendPasswordResetEmail(email);
  }
}
