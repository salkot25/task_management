import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum RecurrenceType { none, daily, customDays, weekly, monthly, yearly }

extension RecurrenceTypeExtension on RecurrenceType {
  String get displayName {
    switch (this) {
      case RecurrenceType.none:
        return 'Tidak Berulang';
      case RecurrenceType.daily:
        return 'Setiap Hari';
      case RecurrenceType.customDays:
        return 'Setiap Beberapa Hari';
      case RecurrenceType.weekly:
        return 'Setiap Minggu';
      case RecurrenceType.monthly:
        return 'Setiap Bulan';
      case RecurrenceType.yearly:
        return 'Setiap Tahun';
    }
  }

  String get shortName {
    switch (this) {
      case RecurrenceType.none:
        return 'Sekali';
      case RecurrenceType.daily:
        return 'Harian';
      case RecurrenceType.customDays:
        return 'Custom';
      case RecurrenceType.weekly:
        return 'Mingguan';
      case RecurrenceType.monthly:
        return 'Bulanan';
      case RecurrenceType.yearly:
        return 'Tahunan';
    }
  }

  IconData get icon {
    switch (this) {
      case RecurrenceType.none:
        return Icons.event_outlined;
      case RecurrenceType.daily:
        return Icons.today_outlined;
      case RecurrenceType.customDays:
        return Icons.repeat_outlined;
      case RecurrenceType.weekly:
        return Icons.view_week_outlined;
      case RecurrenceType.monthly:
        return Icons.calendar_month_outlined;
      case RecurrenceType.yearly:
        return Icons.date_range_outlined;
    }
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime dueDate;
  final TimeOfDay? dueTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final RecurrenceType recurrenceType;
  final int recurrenceInterval;
  final DateTime? recurrenceEndDate;
  final String? parentTaskId; // For tracking recurring task instances

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.dueDate,
    this.dueTime,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.recurrenceType = RecurrenceType.none,
    this.recurrenceInterval = 1,
    this.recurrenceEndDate,
    this.parentTaskId,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    RecurrenceType? recurrenceType,
    int? recurrenceInterval,
    DateTime? recurrenceEndDate,
    String? parentTaskId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      parentTaskId: parentTaskId ?? this.parentTaskId,
    );
  }

  /// Convert Task object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'dueDate': Timestamp.fromDate(dueDate),
      if (dueTime != null)
        'dueTime': {'hour': dueTime!.hour, 'minute': dueTime!.minute},
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      'recurrenceType': recurrenceType.name,
      'recurrenceInterval': recurrenceInterval,
      if (recurrenceEndDate != null)
        'recurrenceEndDate': Timestamp.fromDate(recurrenceEndDate!),
      if (parentTaskId != null) 'parentTaskId': parentTaskId,
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
        dueTime: _parseTimeOfDay(map['dueTime']),
        createdAt: _parseDateTime(map['createdAt']),
        updatedAt: _parseDateTime(map['updatedAt']),
        completedAt: _parseDateTime(map['completedAt']),
        recurrenceType: _parseRecurrenceType(map['recurrenceType']),
        recurrenceInterval: map['recurrenceInterval'] ?? 1,
        recurrenceEndDate: _parseDateTime(map['recurrenceEndDate']),
        parentTaskId: map['parentTaskId'],
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

  /// Helper method to parse RecurrenceType from String
  static RecurrenceType _parseRecurrenceType(dynamic value) {
    if (value == null) return RecurrenceType.none;

    try {
      if (value is String) {
        return RecurrenceType.values.firstWhere(
          (type) => type.name == value,
          orElse: () => RecurrenceType.none,
        );
      }
    } catch (e) {
      developer.log(
        'Error parsing RecurrenceType: $e, value: $value',
        name: 'Task._parseRecurrenceType',
      );
    }

    return RecurrenceType.none;
  }

  /// Helper method to parse TimeOfDay from Map
  static TimeOfDay? _parseTimeOfDay(dynamic value) {
    if (value == null) return null;

    try {
      if (value is Map<String, dynamic>) {
        final hour = value['hour'] as int?;
        final minute = value['minute'] as int?;
        if (hour != null && minute != null) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    } catch (e) {
      developer.log(
        'Error parsing TimeOfDay: $e, value: $value',
        name: 'Task._parseTimeOfDay',
      );
    }

    return null;
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

  /// Check if this task is a recurring task
  bool get isRecurring => recurrenceType != RecurrenceType.none;

  /// Get display name with custom interval
  String getDisplayNameWithInterval() {
    switch (recurrenceType) {
      case RecurrenceType.none:
        return 'Tidak Berulang';
      case RecurrenceType.daily:
        return recurrenceInterval == 1
            ? 'Setiap Hari'
            : 'Setiap $recurrenceInterval Hari';
      case RecurrenceType.customDays:
        return 'Setiap $recurrenceInterval Hari';
      case RecurrenceType.weekly:
        return recurrenceInterval == 1
            ? 'Setiap Minggu'
            : 'Setiap $recurrenceInterval Minggu';
      case RecurrenceType.monthly:
        return recurrenceInterval == 1
            ? 'Setiap Bulan'
            : 'Setiap $recurrenceInterval Bulan';
      case RecurrenceType.yearly:
        return recurrenceInterval == 1
            ? 'Setiap Tahun'
            : 'Setiap $recurrenceInterval Tahun';
    }
  }

  /// Get short display name with custom interval
  String getShortNameWithInterval() {
    switch (recurrenceType) {
      case RecurrenceType.none:
        return 'Sekali';
      case RecurrenceType.daily:
        return recurrenceInterval == 1 ? 'Harian' : '${recurrenceInterval}h';
      case RecurrenceType.customDays:
        return '${recurrenceInterval}h';
      case RecurrenceType.weekly:
        return recurrenceInterval == 1 ? 'Mingguan' : '${recurrenceInterval}m';
      case RecurrenceType.monthly:
        return recurrenceInterval == 1 ? 'Bulanan' : '${recurrenceInterval}bl';
      case RecurrenceType.yearly:
        return recurrenceInterval == 1 ? 'Tahunan' : '${recurrenceInterval}th';
    }
  }

  /// Get the next due date for a recurring task
  DateTime? getNextDueDate() {
    if (!isRecurring) return null;

    DateTime nextDate = dueDate;

    switch (recurrenceType) {
      case RecurrenceType.daily:
        nextDate = dueDate.add(Duration(days: recurrenceInterval));
        break;
      case RecurrenceType.customDays:
        nextDate = dueDate.add(Duration(days: recurrenceInterval));
        break;
      case RecurrenceType.weekly:
        nextDate = dueDate.add(Duration(days: 7 * recurrenceInterval));
        break;
      case RecurrenceType.monthly:
        nextDate = DateTime(
          dueDate.year,
          dueDate.month + recurrenceInterval,
          dueDate.day,
          dueDate.hour,
          dueDate.minute,
          dueDate.second,
        );
        break;
      case RecurrenceType.yearly:
        nextDate = DateTime(
          dueDate.year + recurrenceInterval,
          dueDate.month,
          dueDate.day,
          dueDate.hour,
          dueDate.minute,
          dueDate.second,
        );
        break;
      case RecurrenceType.none:
        return null;
    }

    // Check if next date exceeds recurrence end date
    if (recurrenceEndDate != null && nextDate.isAfter(recurrenceEndDate!)) {
      return null;
    }

    return nextDate;
  }

  /// Create the next instance of a recurring task
  Task? createNextInstance() {
    final nextDate = getNextDueDate();
    if (nextDate == null) return null;

    return copyWith(
      id: '', // Will be generated when saved
      dueDate: nextDate,
      isCompleted: false,
      completedAt: null,
      parentTaskId: parentTaskId ?? id, // Track the original task
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
