import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([this.properties = const <Object>[]]);

  final List<Object?> properties; // Changed to List<Object?>

  @override
  List<Object?> get props => properties; // Changed to List<Object?>
}

class ServerFailure extends Failure {
  final String? message;

  const ServerFailure([this.message]);

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  final String? message; // Added message for CacheFailure consistency

  const CacheFailure([this.message]);

  @override
  List<Object?> get props => [message];
}