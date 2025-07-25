import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test script untuk memvalidasi Firestore Security Rules
/// Jalankan dengan: flutter test test/firestore_rules_test.dart
class FirestoreRulesTest {
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseAuth get auth => FirebaseAuth.instance;

  /// Test basic authentication dan user isolation
  static Future<void> testUserIsolation() async {
    print('🧪 Testing User Isolation...');

    try {
      // Test 1: Authenticated user accessing own data
      final user1 = await _signInTestUser('test1@example.com');
      await _testUserCanAccessOwnData(user1.uid);
      print('✅ User can access own data');

      // Test 2: Authenticated user trying to access other user's data
      final user2 = await _signInTestUser('test2@example.com');
      await _testUserCannotAccessOtherData(user1.uid, user2.uid);
      print('✅ User cannot access other user\'s data');

      // Test 3: Unauthenticated access
      await auth.signOut();
      await _testUnauthenticatedAccess();
      print('✅ Unauthenticated access denied');
    } catch (e) {
      print('❌ User Isolation Test Failed: $e');
      rethrow;
    }
  }

  /// Test data validation rules
  static Future<void> testDataValidation() async {
    print('🧪 Testing Data Validation...');

    try {
      final user = await _signInTestUser('test@example.com');

      // Test valid data
      await _testValidAccountCreation(user.uid);
      print('✅ Valid account creation works');

      // Test invalid data
      await _testInvalidAccountCreation(user.uid);
      print('✅ Invalid account creation rejected');

      // Test valid transaction
      await _testValidTransactionCreation(user.uid);
      print('✅ Valid transaction creation works');

      // Test invalid transaction
      await _testInvalidTransactionCreation(user.uid);
      print('✅ Invalid transaction creation rejected');
    } catch (e) {
      print('❌ Data Validation Test Failed: $e');
      rethrow;
    }
  }

  /// Test field-specific validation
  static Future<void> testFieldValidation() async {
    print('🧪 Testing Field Validation...');

    try {
      final user = await _signInTestUser('test@example.com');

      // Test string length validation
      await _testStringLengthValidation(user.uid);
      print('✅ String length validation works');

      // Test number range validation
      await _testNumberRangeValidation(user.uid);
      print('✅ Number range validation works');

      // Test enum validation
      await _testEnumValidation(user.uid);
      print('✅ Enum validation works');
    } catch (e) {
      print('❌ Field Validation Test Failed: $e');
      rethrow;
    }
  }

  /// Helper: Sign in test user
  static Future<User> _signInTestUser(String email) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: 'testpassword123',
      );
      return credential.user!;
    } catch (e) {
      // If user doesn't exist, create it
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: 'testpassword123',
      );
      return credential.user!;
    }
  }

  /// Test user can access own data
  static Future<void> _testUserCanAccessOwnData(String userId) async {
    // Create user profile
    await firestore.collection('users').doc(userId).set({
      'name': 'Test User',
      'email': 'test@example.com',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Read user profile
    final doc = await firestore.collection('users').doc(userId).get();
    if (!doc.exists) {
      throw Exception('User should be able to read own profile');
    }
  }

  /// Test user cannot access other user's data
  static Future<void> _testUserCannotAccessOtherData(
    String currentUserId,
    String otherUserId,
  ) async {
    try {
      // Try to read other user's profile
      await firestore.collection('users').doc(otherUserId).get();
      throw Exception('User should not be able to read other user\'s profile');
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') {
        throw Exception('Expected permission-denied, got: ${e.code}');
      }
    }

    try {
      // Try to access other user's accounts
      await firestore
          .collection('users')
          .doc(otherUserId)
          .collection('accounts')
          .get();
      throw Exception('User should not be able to read other user\'s accounts');
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') {
        throw Exception('Expected permission-denied, got: ${e.code}');
      }
    }
  }

  /// Test unauthenticated access
  static Future<void> _testUnauthenticatedAccess() async {
    try {
      await firestore.collection('users').doc('any-user').get();
      throw Exception('Unauthenticated users should not access data');
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') {
        throw Exception('Expected permission-denied, got: ${e.code}');
      }
    }
  }

  /// Test valid account creation
  static Future<void> _testValidAccountCreation(String userId) async {
    await firestore.collection('users').doc(userId).collection('accounts').add({
      'name': 'Test Bank Account',
      'type': 'bank',
      'balance': 100000.0,
      'currency': 'IDR',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Test invalid account creation
  static Future<void> _testInvalidAccountCreation(String userId) async {
    // Test invalid type
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .add({
            'name': 'Test Account',
            'type': 'invalid_type', // Invalid type
            'balance': 100000.0,
            'currency': 'IDR',
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      throw Exception('Invalid account type should be rejected');
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') {
        throw Exception('Expected permission-denied, got: ${e.code}');
      }
    }

    // Test missing required field
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .add({
            'type': 'bank',
            'balance': 100000.0,
            'currency': 'IDR',
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            // Missing 'name' field
          });
      throw Exception('Missing required field should be rejected');
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') {
        throw Exception('Expected permission-denied, got: ${e.code}');
      }
    }
  }

  /// Test valid transaction creation
  static Future<void> _testValidTransactionCreation(String userId) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .add({
          'amount': 50000.0,
          'type': 'expense',
          'description': 'Test transaction',
          'category': 'food',
          'date': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  /// Test invalid transaction creation
  static Future<void> _testInvalidTransactionCreation(String userId) async {
    // Test negative amount
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .add({
            'amount': -100.0, // Invalid negative amount
            'type': 'expense',
            'description': 'Test transaction',
            'date': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      throw Exception('Negative amount should be rejected');
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') {
        throw Exception('Expected permission-denied, got: ${e.code}');
      }
    }
  }

  /// Test string length validation
  static Future<void> _testStringLengthValidation(String userId) async {
    // Test too long name
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .add({
            'name': 'A' * 101, // Too long (max 100 chars)
            'type': 'bank',
            'balance': 100000.0,
            'currency': 'IDR',
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      throw Exception('Too long name should be rejected');
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') {
        throw Exception('Expected permission-denied, got: ${e.code}');
      }
    }
  }

  /// Test number range validation
  static Future<void> _testNumberRangeValidation(String userId) async {
    // Test too large amount
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .add({
            'amount': 1000000000.0, // Too large (max 999,999,999)
            'type': 'expense',
            'description': 'Test transaction',
            'date': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      throw Exception('Too large amount should be rejected');
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') {
        throw Exception('Expected permission-denied, got: ${e.code}');
      }
    }
  }

  /// Test enum validation
  static Future<void> _testEnumValidation(String userId) async {
    // Test invalid priority
    try {
      await firestore.collection('users').doc(userId).collection('tasks').add({
        'title': 'Test Task',
        'description': 'Test description',
        'priority': 'invalid_priority', // Invalid priority
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      throw Exception('Invalid priority should be rejected');
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') {
        throw Exception('Expected permission-denied, got: ${e.code}');
      }
    }
  }

  /// Run all tests
  static Future<void> runAllTests() async {
    print('🚀 Starting Firestore Rules Tests...\n');

    try {
      await testUserIsolation();
      print('');

      await testDataValidation();
      print('');

      await testFieldValidation();
      print('');

      print('🎉 All Firestore Rules Tests Passed!');
    } catch (e) {
      print('💥 Test Suite Failed: $e');
      rethrow;
    }
  }
}

/// Test runner function
void main() {
  group('Firestore Security Rules Tests', () {
    test('User Isolation', () async {
      await FirestoreRulesTest.testUserIsolation();
    });

    test('Data Validation', () async {
      await FirestoreRulesTest.testDataValidation();
    });

    test('Field Validation', () async {
      await FirestoreRulesTest.testFieldValidation();
    });

    test('Complete Test Suite', () async {
      await FirestoreRulesTest.runAllTests();
    });
  });
}
