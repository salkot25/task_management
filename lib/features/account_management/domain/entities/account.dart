import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final String id;
  final String website;
  final String username;
  final String password;

  const Account({
    required this.id,
    required this.website,
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [id, website, username, password];
}