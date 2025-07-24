import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String uid;
  final String name;
  final String? username; // Added username field
  final String? email; // Added email field
  final String? whatsapp; // Added whatsapp field
  final String? profilePictureUrl;

  const Profile({
    required this.uid,
    required this.name,
    this.username, // Added username to constructor
    this.email, // Added email to constructor
    this.whatsapp, // Added whatsapp to constructor
    this.profilePictureUrl,
  });

  Profile copyWith({
    String? uid,
    String? name,
    String? username, // Added username to copyWith
    String? email, // Added email to copyWith
    String? whatsapp, // Added whatsapp to copyWith
    String? profilePictureUrl,
  }) {
    return Profile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      username: username ?? this.username, // Update username in copyWith
      email: email ?? this.email, // Update email in copyWith
      whatsapp: whatsapp ?? this.whatsapp, // Update whatsapp in copyWith
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  @override
  List<Object?> get props => [uid, name, username, email, whatsapp, profilePictureUrl];
}
