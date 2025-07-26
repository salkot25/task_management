import 'package:dartz/dartz.dart';
import 'package:clarity/core/error/failures.dart';
import 'package:clarity/core/usecases/usecase.dart';
import 'package:clarity/features/auth/domain/entities/profile.dart';
import 'package:clarity/features/auth/domain/repositories/profile_repository.dart';

class GetProfile implements UseCase<Profile?, String> {
  final ProfileRepository repository;

  GetProfile(this.repository);

  @override
  Future<Either<Failure, Profile?>> call(String uid) async {
    return await repository.getProfile(uid);
  }
}
