import 'package:flutter/foundation.dart';
import 'package:neram_pos/features/printing/models/print_status.dart';

/// Represents an individual physical print job routed to a specific printer.
@immutable
class PrintJob {
  const PrintJob({
    required this.jobId,
    required this.printerId,
    required this.type,
    required this.ticketData,
    this.status = PrintStatus.pending,
    this.attempts = 0,
    this.lastError,
    this.createdAt,
    this.updatedAt,
  });

  final String jobId;
  final String printerId;
  final String type; // 'kitchen_kot', 'bar_kot', 'bill', etc.
  final String ticketData; // Encoded ESC/POS binary or formatted text payload
  final PrintStatus status;
  final int attempts;
  final String? lastError;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PrintJob copyWith({
    String? jobId,
    String? printerId,
    String? type,
    String? ticketData,
    PrintStatus? status,
    int? attempts,
    String? lastError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PrintJob(
      jobId: jobId ?? this.jobId,
      printerId: printerId ?? this.printerId,
      type: type ?? this.type,
      ticketData: ticketData ?? this.ticketData,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'jobId': jobId,
    'printerId': printerId,
    'type': type,
    'ticketData': ticketData,
    'status': status.name,
    'attempts': attempts,
    if (lastError != null) 'lastError': lastError,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  factory PrintJob.fromJson(Map<String, dynamic> json) {
    return PrintJob(
      jobId: json['jobId'] as String? ?? '',
      printerId: json['printerId'] as String? ?? '',
      type: json['type'] as String? ?? 'kitchen_kot',
      ticketData: json['ticketData'] as String? ?? '',
      status: PrintStatus.fromString(json['status'] as String? ?? 'pending'),
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      lastError: json['lastError'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}

