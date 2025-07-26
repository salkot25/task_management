import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:clarity/core/error/failures.dart';
import 'package:clarity/core/usecases/usecase.dart';
import 'package:clarity/features/auth/domain/entities/user.dart';
import 'package:clarity/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase implements UseCase<User, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    return await repository.signUpWithEmailAndPassword(
      params.email,
      params.password,
    );
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;

  const SignUpParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
