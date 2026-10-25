import 'package:flutter/material.dart';

/// Categories of staff leave applications in hospitality roster.
enum LeaveType {
  paidLeave,
  casualLeave,
  compensatoryOff,
  sickLeave;

  String get displayName => switch (this) {
    LeaveType.paidLeave => 'Paid Leave',
    LeaveType.casualLeave => 'Casual Leave',
    LeaveType.compensatoryOff => 'Compensatory Off',
    LeaveType.sickLeave => 'Sick Leave',
  };

  String get balanceText => switch (this) {
    LeaveType.paidLeave => '6 Days Remaining',
    LeaveType.casualLeave => '3 Days Remaining',
    LeaveType.compensatoryOff => 'Weekend Overtime',
    LeaveType.sickLeave => '4 Days Remaining',
  };
}

/// Authorization status for leave requests.
enum LeaveStatus {
  approved,
  pending,
  rejected;

  String get displayName => switch (this) {
    LeaveStatus.approved => 'Approved',
    LeaveStatus.pending => 'Pending',
    LeaveStatus.rejected => 'Rejected',
  };

  Color get color => switch (this) {
    LeaveStatus.approved => const Color(0xFF10B981), // Emerald
    LeaveStatus.pending => const Color(0xFFF59E0B), // Amber
    LeaveStatus.rejected => const Color(0xFFEF4444), // Crimson
  };

  Color get backgroundColor => switch (this) {
    LeaveStatus.approved => const Color(0x2610B981),
    LeaveStatus.pending => const Color(0x26F59E0B),
    LeaveStatus.rejected => const Color(0x26EF4444),
  };

  IconData get icon => switch (this) {
    LeaveStatus.approved => Icons.check_circle_rounded,
    LeaveStatus.pending => Icons.pending_rounded,
    LeaveStatus.rejected => Icons.block_rounded,
  };
}

/// Model representing a staff member's leave request and audit history.
class LeaveApplicationModel {
  const LeaveApplicationModel({
    required this.id,
    required this.applicantName,
    required this.applicantRole,
    required this.staffId,
    required this.initials,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.type,
    required this.reason,
    required this.status,
    required this.reviewedBy,
    required this.appliedAt,
  });

  final String id;
  final String applicantName;
  final String applicantRole;
  final String staffId;
  final String initials;
  final DateTime startDate;
  final DateTime endDate;
  final int days;
  final LeaveType type;
  final String reason;
  final LeaveStatus status;
  final String reviewedBy;
  final DateTime appliedAt;

  String get formattedPeriod {
    final startStr = '${_monthName(startDate.month)} ${startDate.day}';
    final endStr = '${_monthName(endDate.month)} ${endDate.day}, ${endDate.year}';
    return '$startStr - $endStr ($days ${days == 1 ? 'Day' : 'Days'})';
  }

  /// Whether this leave type is paid or unpaid.
  bool get isPaid => type == LeaveType.paidLeave || type == LeaveType.compensatoryOff;

  /// Formatted type with paid/unpaid status indicator.
  String get typePaidString => '${type.displayName} (${isPaid ? "Paid" : "Unpaid"})';

  /// Period string in "from date to to date" format.
  String get periodString {
    final startStr = '${startDate.day} ${_monthName(startDate.month)} ${startDate.year}';
    final endStr = '${endDate.day} ${_monthName(endDate.month)} ${endDate.year}';
    return '$startStr to $endStr';
  }

  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  LeaveApplicationModel copyWith({
    String? id,
    String? applicantName,
    String? applicantRole,
    String? staffId,
    String? initials,
    DateTime? startDate,
    DateTime? endDate,
    int? days,
    LeaveType? type,
    String? reason,
    LeaveStatus? status,
    String? reviewedBy,
    DateTime? appliedAt,
  }) {
    return LeaveApplicationModel(
      id: id ?? this.id,
      applicantName: applicantName ?? this.applicantName,
      applicantRole: applicantRole ?? this.applicantRole,
      staffId: staffId ?? this.staffId,
      initials: initials ?? this.initials,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      days: days ?? this.days,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }
}

