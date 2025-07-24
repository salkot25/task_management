import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';

import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/auth/data/datasources/profile_firestore_data_source.dart';
import 'package:myapp/features/auth/domain/entities/profile.dart';
import 'package:myapp/features/auth/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileFirestoreDataSource firestoreDataSource;

  ProfileRepositoryImpl({required this.firestoreDataSource});

  @override
  Future<Either<Failure, void>> createProfile(Profile profile) async {
    try {
      await firestoreDataSource.createProfile(profile);
      return const Right(null);
    } on FirestoreException catch (e) {
      return Left(ServerFailure(e.message));
    } on OtherException catch (e) {
      return Left(ServerFailure(e.message));
    } on PlatformException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown platform error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Profile?>> getProfile(String uid) async {
    try {
      final profile = await firestoreDataSource.getProfile(uid);
      return Right(profile);
    } on FirestoreException catch (e) {
      return Left(ServerFailure(e.message));
    } on OtherException catch (e) {
      return Left(ServerFailure(e.message));
    } on PlatformException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown platform error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(Profile profile) async {
    try {
      await firestoreDataSource.updateProfile(profile);
      return const Right(null);
    } on FirestoreException catch (e) {
      return Left(ServerFailure(e.message));
    } on OtherException catch (e) {
      return Left(ServerFailure(e.message));
    } on PlatformException catch (e) {
      return Left(ServerFailure(e.message ?? 'Unknown platform error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
