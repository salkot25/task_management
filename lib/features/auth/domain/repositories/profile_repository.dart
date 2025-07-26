import 'package:dartz/dartz.dart';

import 'package:clarity/core/error/failures.dart';
import 'package:clarity/features/auth/domain/entities/profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, void>> createProfile(Profile profile);
  Future<Either<Failure, Profile?>> getProfile(String uid);
  Future<Either<Failure, void>> updateProfile(Profile profile);
}
