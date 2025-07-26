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
      final now = DateTime.now();
      await firestore.collection('users').doc(profile.uid).set({
        'name': profile.name,
        'email': profile.email ?? '',
        'createdAt': Timestamp.fromDate(profile.createdAt ?? now),
        'updatedAt': Timestamp.fromDate(now),
        // Optional fields
        if (profile.profilePictureUrl != null)
          'photoUrl': profile.profilePictureUrl,
        if (profile.whatsapp != null) 'phoneNumber': profile.whatsapp,
        if (profile.role != null && profile.role!.isNotEmpty)
          'bio': profile.role,
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
      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return Profile(
          uid: uid,
          name: data['name'] ?? '',
          email: data['email'],
          profilePictureUrl: data['photoUrl'],
          whatsapp: data['phoneNumber'],
          role: data['bio'],
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : null,
          lastSignInAt: data['lastSignInAt'] != null
              ? (data['lastSignInAt'] as Timestamp).toDate()
              : null,
          isEmailVerified: data['isEmailVerified'] ?? false,
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
      final now = DateTime.now();
      await firestore.collection('users').doc(profile.uid).update({
        'name': profile.name,
        'email': profile.email ?? '',
        'updatedAt': Timestamp.fromDate(now),
        // Optional fields - only update if they have values
        if (profile.profilePictureUrl != null)
          'photoUrl': profile.profilePictureUrl,
        if (profile.whatsapp != null) 'phoneNumber': profile.whatsapp,
        if (profile.role != null && profile.role!.isNotEmpty)
          'bio': profile.role,
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
