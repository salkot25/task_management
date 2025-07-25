import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/auth/domain/entities/profile.dart';

abstract class ProfileFirestoreDataSource {
  Future<void> createProfile(Profile profile);
  Future<Profile?> getProfile(String uid);
  Future<void> updateProfile(Profile profile);
}

class ProfileFirestoreDataSourceImpl implements ProfileFirestoreDataSource {
  final FirebaseFirestore firestore;

  ProfileFirestoreDataSourceImpl({required this.firestore});

  @override
  Future<void> createProfile(Profile profile) async {
    try {
      await firestore.collection('profiles').doc(profile.uid).set({
        'uid': profile.uid,
        'name': profile.name,
        'username': profile.username, // Added username
        'email': profile.email, // Added email
        'whatsapp': profile.whatsapp, // Added whatsapp
        'profilePictureUrl': profile.profilePictureUrl,
        'role': profile.role, // Added role
        'createdAt':
            profile.createdAt?.millisecondsSinceEpoch, // Added createdAt
        'lastSignInAt':
            profile.lastSignInAt?.millisecondsSinceEpoch, // Added lastSignInAt
        'isEmailVerified': profile.isEmailVerified, // Added isEmailVerified
      });
    } on PlatformException catch (e) {
      throw FirestoreException(e.message ?? 'Failed to create profile');
    } catch (e) {
      throw OtherException(
        e.toString(),
      ); // Use OtherException for unexpected errors
    }
  }

  @override
  Future<Profile?> getProfile(String uid) async {
    try {
      final doc = await firestore.collection('profiles').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return Profile(
          uid: data['uid'],
          name: data['name'],
          username: data['username'], // Added username
          email: data['email'], // Added email
          whatsapp: data['whatsapp'], // Added whatsapp
          profilePictureUrl: data['profilePictureUrl'],
          role: data['role'], // Added role
          createdAt: data['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
              : null, // Added createdAt
          lastSignInAt: data['lastSignInAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['lastSignInAt'])
              : null, // Added lastSignInAt
          isEmailVerified: data['isEmailVerified'], // Added isEmailVerified
        );
      }
      return null;
    } on PlatformException catch (e) {
      throw FirestoreException(e.message ?? 'Failed to get profile');
    } catch (e) {
      throw OtherException(
        e.toString(),
      ); // Use OtherException for unexpected errors
    }
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    try {
      await firestore.collection('profiles').doc(profile.uid).update({
        'name': profile.name,
        'username': profile.username, // Added username
        'email': profile.email, // Added email
        'whatsapp': profile.whatsapp, // Added whatsapp
        'profilePictureUrl': profile.profilePictureUrl,
        'role': profile.role, // Added role
        'lastSignInAt': DateTime.now()
            .millisecondsSinceEpoch, // Update lastSignInAt on profile update
        'isEmailVerified': profile.isEmailVerified, // Added isEmailVerified
      });
    } on PlatformException catch (e) {
      throw FirestoreException(e.message ?? 'Failed to update profile');
    } catch (e) {
      throw OtherException(
        e.toString(),
      ); // Use OtherException for unexpected errors
    }
  }
}
