import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String uid;
  final String name;
  final String? username;
  final String? email;
  final String? whatsapp;
  final String? profilePictureUrl;
  final String? role; // Added role field
  final DateTime? createdAt; // Added createdAt field
  final DateTime? lastSignInAt; // Added lastSignInAt field
  final bool? isEmailVerified; // Added isEmailVerified field

  const Profile({
    required this.uid,
    required this.name,
    this.username,
    this.email,
    this.whatsapp,
    this.profilePictureUrl,
    this.role, // Added role to constructor
    this.createdAt, // Added createdAt to constructor
    this.lastSignInAt, // Added lastSignInAt to constructor
    this.isEmailVerified, // Added isEmailVerified to constructor
  });

  Profile copyWith({
    String? uid,
    String? name,
    String? username,
    String? email,
    String? whatsapp,
    String? profilePictureUrl,
    String? role, // Added role to copyWith
    DateTime? createdAt, // Added createdAt to copyWith
    DateTime? lastSignInAt, // Added lastSignInAt to copyWith
    bool? isEmailVerified, // Added isEmailVerified to copyWith
  }) {
    return Profile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      whatsapp: whatsapp ?? this.whatsapp,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      role: role ?? this.role, // Update role in copyWith
      createdAt: createdAt ?? this.createdAt, // Update createdAt in copyWith
      lastSignInAt: lastSignInAt ?? this.lastSignInAt, // Update lastSignInAt in copyWith
      isEmailVerified: isEmailVerified ?? this.isEmailVerified, // Update isEmailVerified in copyWith
    );
  }

  @override
  List<Object?> get props => [
    uid,
    name,
    username,
    email,
    whatsapp,
    profilePictureUrl,
    role,
    createdAt,
    lastSignInAt,
    isEmailVerified,
  ];
}
