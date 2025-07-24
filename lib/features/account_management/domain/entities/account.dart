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

  // Convert Account object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'website': website,
      'username': username,
      'password': password,
    };
  }

  // Create an Account object from a Firestore Map
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] ?? '',
      website: map['website'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
    );
  }
}
