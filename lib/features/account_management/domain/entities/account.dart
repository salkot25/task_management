import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final String id;
  final String website;
  final String username;
  final String password;
  final String? category;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Account({
    required this.id,
    required this.website,
    required this.username,
    required this.password,
    this.category,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    website,
    username,
    password,
    category,
    userId,
    createdAt,
    updatedAt,
  ];

  // Convert Account object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'website': website,
      'username': username,
      'password': password,
      if (category != null) 'category': category,
      if (userId != null) 'userId': userId,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  // Create an Account object from a Firestore Map
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] ?? '',
      website: map['website'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      category: map['category'],
      userId: map['userId'],
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  // Create a copy with updated fields
  Account copyWith({
    String? id,
    String? website,
    String? username,
    String? password,
    String? category,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      website: website ?? this.website,
      username: username ?? this.username,
      password: password ?? this.password,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
