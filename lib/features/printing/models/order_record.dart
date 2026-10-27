import 'package:flutter/foundation.dart';
import 'package:neram_pos/features/printing/models/print_job.dart';

/// Atomically saved local order record combining order payload, print jobs,
/// revision counter, and sync state.
@immutable
class OrderRecord {
  OrderRecord({
    required this.orderId,
    required this.localNo,
    required this.payload,
    required this.jobs,
    this.synced = false,
    this.rev = 1,
    this.serverOrderId,
    this.lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now().toUtc(),
        updatedAt = updatedAt ?? DateTime.now().toUtc();

  final String orderId;
  final String localNo;
  final Map<String, dynamic> payload;
  final List<PrintJob> jobs;
  final bool synced;
  final int rev;
  final String? serverOrderId;
  final String? lastSyncError;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Creates a copy with incremented revision number [rev + 1] on every modification.
  OrderRecord copyWith({
    String? orderId,
    String? localNo,
    Map<String, dynamic>? payload,
    List<PrintJob>? jobs,
    bool? synced,
    int? rev,
    String? serverOrderId,
    String? lastSyncError,
    DateTime? updatedAt,
    bool autoIncrementRev = true,
  }) {
    return OrderRecord(
      orderId: orderId ?? this.orderId,
      localNo: localNo ?? this.localNo,
      payload: payload ?? this.payload,
      jobs: jobs ?? this.jobs,
      synced: synced ?? this.synced,
      rev: rev ?? (autoIncrementRev ? this.rev + 1 : this.rev),
      serverOrderId: serverOrderId ?? this.serverOrderId,
      lastSyncError: lastSyncError ?? this.lastSyncError,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'localNo': localNo,
    'payload': payload,
    'jobs': jobs.map((j) => j.toJson()).toList(),
    'synced': synced,
    'rev': rev,
    if (serverOrderId != null) 'serverOrderId': serverOrderId,
    if (lastSyncError != null) 'lastSyncError': lastSyncError,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory OrderRecord.fromJson(Map<String, dynamic> json) {
    return OrderRecord(
      orderId: json['orderId'] as String? ?? '',
      localNo: json['localNo'] as String? ?? '',
      payload: (json['payload'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      jobs: (json['jobs'] as List<dynamic>?)
              ?.map((j) => PrintJob.fromJson(j as Map<String, dynamic>))
              .toList() ??
          const [],
      synced: json['synced'] as bool? ?? false,
      rev: (json['rev'] as num?)?.toInt() ?? 1,
      serverOrderId: json['serverOrderId'] as String?,
      lastSyncError: json['lastSyncError'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}

