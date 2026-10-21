import 'package:flutter/material.dart';

/// Dining zone inside restaurant / cafe.
enum TableZone {
  indoor,
  outdoor,
  takeaway;

  String get displayName => switch (this) {
    TableZone.indoor => 'Indoor',
    TableZone.outdoor => 'Outdoor',
    TableZone.takeaway => 'Takeaway',
  };
}

/// Operational state of a table.
enum TableStatus {
  vacant,
  preparing,
  occupied,
  billed;

  String get displayName => switch (this) {
    TableStatus.vacant => 'Vacant',
    TableStatus.preparing => 'Prep',
    TableStatus.occupied => 'Dining',
    TableStatus.billed => 'Billed',
  };

  Color get color => switch (this) {
    TableStatus.vacant => const Color(0xFF10B981), // Emerald
    TableStatus.preparing => const Color(0xFFF59E0B), // Amber
    TableStatus.occupied => const Color(0xFF3B82F6), // Blue
    TableStatus.billed => const Color(0xFFA855F7), // Purple
  };

  Color get backgroundColor => switch (this) {
    TableStatus.vacant => const Color(0x2610B981),
    TableStatus.preparing => const Color(0x26F59E0B),
    TableStatus.occupied => const Color(0x263B82F6),
    TableStatus.billed => const Color(0x26A855F7),
  };

  Color get borderColor => switch (this) {
    TableStatus.vacant => const Color(0x4D10B981),
    TableStatus.preparing => const Color(0x4DF59E0B),
    TableStatus.occupied => const Color(0x4D3B82F6),
    TableStatus.billed => const Color(0x4DA855F7),
  };
}

/// Model representing a dining table or service token.
class TableModel {
  const TableModel({
    required this.id,
    required this.name,
    required this.zone,
    required this.seats,
    required this.status,
    this.total = 0.0,
    this.customerName,
    this.timeElapsed = 'Ready',
    this.itemCount = 0,
  });

  final String id;
  final String name;
  final TableZone zone;
  final int seats;
  final TableStatus status;
  final double total;
  final String? customerName;
  final String timeElapsed;
  final int itemCount;

  String get formattedTotal => '\$${total.toStringAsFixed(2)}';
  String get subtitle => zone == TableZone.takeaway
      ? 'Express Pickup'
      : '${zone.displayName} • ${seats}P';

  TableModel copyWith({
    String? id,
    String? name,
    TableZone? zone,
    int? seats,
    TableStatus? status,
    double? total,
    String? customerName,
    String? timeElapsed,
    int? itemCount,
  }) {
    return TableModel(
      id: id ?? this.id,
      name: name ?? this.name,
      zone: zone ?? this.zone,
      seats: seats ?? this.seats,
      status: status ?? this.status,
      total: total ?? this.total,
      customerName: customerName ?? this.customerName,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}
