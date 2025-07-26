import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart'; // Ensure this is imported
import 'package:clarity/core/error/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  Stream<UserModel?> get authStateChanges;
  Future<UserModel> signInWithGoogle(); // Added for Google Sign-In
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn; // Keep final

  AuthRemoteDataSourceImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _googleSignIn =
           googleSignIn ??
           GoogleSignIn(
             signInOption: SignInOption.standard,
             clientId: '1:1074161513774:web:1b22b81a2cf8f2618736bf',
           ); // Use your web client ID here

  @override
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        return UserModel.fromFirebaseUser(result.user!);
      } else {
        throw ServerException('User is null after sign in.');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'An unknown error occurred.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        return UserModel.fromFirebaseUser(result.user!);
      } else {
        throw ServerException('User is null after sign up.');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'An unknown error occurred.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'An unknown error occurred.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut(); // Also sign out from Google
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'An unknown error occurred.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebase_auth.User? user) {
      return user == null ? null : UserModel.fromFirebaseUser(user);
    });
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn(); // Correct method call

      // Abort if the user cancelled the flow
      if (googleUser == null) {
        throw ServerException(
          'Google Sign In cancelled.',
        ); // Or a custom AuthException
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication; // Correct access

      // Create a new credential
      final firebase_auth.AuthCredential credential = firebase_auth
          .GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, // Correct access
        idToken: googleAuth.idToken, // Correct access
      );

      // Sign in to Firebase with the credential
      final result = await _firebaseAuth.signInWithCredential(credential);

      if (result.user != null) {
        return UserModel.fromFirebaseUser(result.user!);
      } else {
        throw ServerException('User is null after signing in with Google.');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(
        e.message ?? 'An unknown error occurred during Google Sign In.',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

class UserModel {
  final String uid;
  final String? email;

  UserModel({required this.uid, this.email});

  factory UserModel.fromFirebaseUser(firebase_auth.User user) {
    return UserModel(uid: user.uid, email: user.email);
  }
}
