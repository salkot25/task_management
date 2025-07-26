import 'package:equatable/equatable.dart';

/// Enum untuk jenis operasi sync
enum SyncOperationType { create, update, delete }

/// Enum untuk status sync
enum SyncStatus { pending, syncing, completed, failed }

/// Enum untuk entitas yang dapat disync
enum SyncEntityType { profile, task, transaction, account }

/// Model untuk item yang perlu disync
class SyncItem extends Equatable {
  final String id;
  final SyncEntityType entityType;
  final SyncOperationType operationType;
  final Map<String, dynamic> data;
  final SyncStatus status;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final int retryCount;
  final String? errorMessage;

  const SyncItem({
    required this.id,
    required this.entityType,
    required this.operationType,
    required this.data,
    this.status = SyncStatus.pending,
    required this.createdAt,
    this.lastAttemptAt,
    this.retryCount = 0,
    this.errorMessage,
  });

  /// Membuat copy dengan perubahan
  SyncItem copyWith({
    String? id,
    SyncEntityType? entityType,
    SyncOperationType? operationType,
    Map<String, dynamic>? data,
    SyncStatus? status,
    DateTime? createdAt,
    DateTime? lastAttemptAt,
    int? retryCount,
    String? errorMessage,
  }) {
    return SyncItem(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      operationType: operationType ?? this.operationType,
      data: data ?? this.data,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Convert to JSON untuk penyimpanan lokal
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType.name,
      'operationType': operationType.name,
      'data': data,
      'status': status.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastAttemptAt': lastAttemptAt?.millisecondsSinceEpoch,
      'retryCount': retryCount,
      'errorMessage': errorMessage,
    };
  }

  /// Create from JSON
  factory SyncItem.fromJson(Map<String, dynamic> json) {
    return SyncItem(
      id: json['id'],
      entityType: SyncEntityType.values.firstWhere(
        (e) => e.name == json['entityType'],
      ),
      operationType: SyncOperationType.values.firstWhere(
        (e) => e.name == json['operationType'],
      ),
      data: Map<String, dynamic>.from(json['data']),
      status: SyncStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      lastAttemptAt: json['lastAttemptAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastAttemptAt'])
          : null,
      retryCount: json['retryCount'] ?? 0,
      errorMessage: json['errorMessage'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    entityType,
    operationType,
    data,
    status,
    createdAt,
    lastAttemptAt,
    retryCount,
    errorMessage,
  ];
}
