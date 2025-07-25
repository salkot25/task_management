import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.dueDate,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Convert Task object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'dueDate': Timestamp.fromDate(dueDate),
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
    };
  }

  /// Create a Task object from a Firestore Map
  factory Task.fromMap(Map<String, dynamic> map) {
    try {
      return Task(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        isCompleted: map['isCompleted'] ?? false,
        dueDate: _parseRequiredDateTime(map['dueDate']),
        createdAt: _parseDateTime(map['createdAt']),
        updatedAt: _parseDateTime(map['updatedAt']),
        completedAt: _parseDateTime(map['completedAt']),
      );
    } catch (e) {
      developer.log(
        'Error parsing Task from map: $e',
        name: 'Task.fromMap',
        error: e,
      );
      rethrow;
    }
  }

  /// Helper method to parse DateTime from various formats (nullable)
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    try {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      } else if (value is DateTime) {
        return value;
      }
    } catch (e) {
      developer.log(
        'Error parsing DateTime: $e, value: $value',
        name: 'Task._parseDateTime',
      );
    }

    return null;
  }

  /// Helper method to parse required DateTime (falls back to current time)
  static DateTime _parseRequiredDateTime(dynamic value) {
    final parsed = _parseDateTime(value);
    return parsed ?? DateTime.now();
  }
}
