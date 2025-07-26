import 'package:dartz/dartz.dart';
import 'package:clarity/core/error/failures.dart';
import 'package:clarity/core/usecases/usecase.dart';
import 'package:clarity/features/auth/domain/entities/profile.dart';
import 'package:clarity/features/auth/domain/repositories/profile_repository.dart';

class CreateProfile implements UseCase<void, Profile> {
  final ProfileRepository repository;

  CreateProfile(this.repository);

  @override
  Future<Either<Failure, void>> call(Profile profile) async {
    return await repository.createProfile(profile);
  }
}
