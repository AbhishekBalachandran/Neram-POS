import 'package:flutter/foundation.dart';

/// Categories for inventory management matching the Google Stitch design specification.
enum StockCategory {
  foodRaw,
  consumables,
  smallEquipment,
  fixedAssets;

  String get displayName {
    switch (this) {
      case StockCategory.foodRaw:
        return 'Stock';
      case StockCategory.consumables:
        return 'Consumables';
      case StockCategory.smallEquipment:
        return 'Small Equipment';
      case StockCategory.fixedAssets:
        return 'Fixed Assets';
    }
  }

  String get code {
    switch (this) {
      case StockCategory.foodRaw:
        return 'food';
      case StockCategory.consumables:
        return 'consumables';
      case StockCategory.smallEquipment:
        return 'small_equip';
      case StockCategory.fixedAssets:
        return 'fixed';
    }
  }
}

/// Status representation for inventory levels.
enum StockStatus {
  optimal,
  low,
  critical,
  outOfStock;

  String get displayName {
    switch (this) {
      case StockStatus.optimal:
        return 'Optimal';
      case StockStatus.low:
        return 'Low Stock';
      case StockStatus.critical:
        return 'Critical Low';
      case StockStatus.outOfStock:
        return 'Out of Stock';
    }
  }
}

/// Represents an individual stock transaction/log entry.
@immutable
class StockLogEntry {
  const StockLogEntry({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.quantityChange,
    required this.balanceAfter,
    required this.staffName,
    this.notes,
  });

  final String id;
  final DateTime timestamp;
  final String action; // 'Restock', 'Usage', 'Audit Adjustment', etc.
  final double quantityChange;
  final double balanceAfter;
  final String staffName;
  final String? notes;
}

/// Rich domain model representing a stock item in NERAM POS.
@immutable
class StockItemModel {
  const StockItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.currentStock,
    required this.minLevel,
    required this.costPerUnit,
    required this.supplier,
    this.packetsCount,
    this.amountPerPacket,
    this.costPerPacket,
    this.minPackets,
    this.logs = const [],
    this.lastAudited,
  });

  final String id;
  final String name;
  final StockCategory category;
  final String unit;
  final double currentStock;
  final double minLevel;
  final double costPerUnit;
  final String supplier;
  final int? packetsCount;
  final double? amountPerPacket;
  final double? costPerPacket;
  final int? minPackets;
  final List<StockLogEntry> logs;
  final DateTime? lastAudited;

  /// Remaining stock ratio against minimum threshold (0.0 to 1.0+).
  double get stockRatio => minLevel > 0 ? (currentStock / minLevel) : 1.0;

  /// Calculated stock percentage capped for display.
  double get percentageRemaining =>
      ((minLevel > 0 ? (currentStock / minLevel) * 100 : 100).clamp(
        0.0,
        999.0,
      )).toDouble();

  /// Total valuation of current on-hand stock.
  double get totalValue => currentStock * costPerUnit;

  /// Computed stock health status.
  StockStatus get status {
    if (currentStock <= 0) return StockStatus.outOfStock;
    if (currentStock <= minLevel * 0.35) return StockStatus.critical;
    if (currentStock <= minLevel) return StockStatus.low;
    return StockStatus.optimal;
  }

  bool get isLowStock =>
      status == StockStatus.low || status == StockStatus.critical;

  /// Display helper for packets count
  int get displayPacketsCount {
    if (packetsCount != null) return packetsCount!;
    if (amountPerPacket != null && amountPerPacket! > 0) {
      return (currentStock / amountPerPacket!).ceil();
    }
    return currentStock > 0 ? currentStock.ceil() : 0;
  }

  /// Display helper for formatted total amount with unit
  String get displayTotalAmount {
    final formattedVal = currentStock % 1 == 0
        ? currentStock.toInt().toString()
        : currentStock.toStringAsFixed(1);
    return '$formattedVal $unit';
  }

  /// Display helper for amount per packet
  String get displayAmountPerPacket {
    if (amountPerPacket != null) {
      final formatted = amountPerPacket! % 1 == 0
          ? amountPerPacket!.toInt().toString()
          : amountPerPacket!.toStringAsFixed(1);
      return '$formatted $unit each';
    }
    return '$unit each';
  }

  /// Display helper for cost per packet
  double get displayCostPerPacket {
    if (costPerPacket != null) return costPerPacket!;
    if (amountPerPacket != null) return costPerUnit * amountPerPacket!;
    return costPerUnit;
  }

  /// Display helper for min packets level
  int get displayMinPackets {
    if (minPackets != null) return minPackets!;
    if (amountPerPacket != null && amountPerPacket! > 0) {
      return (minLevel / amountPerPacket!).ceil();
    }
    return minLevel > 0 ? minLevel.ceil() : 0;
  }

  StockItemModel copyWith({
    String? id,
    String? name,
    StockCategory? category,
    String? unit,
    double? currentStock,
    double? minLevel,
    double? costPerUnit,
    String? supplier,
    int? packetsCount,
    double? amountPerPacket,
    double? costPerPacket,
    int? minPackets,
    List<StockLogEntry>? logs,
    DateTime? lastAudited,
  }) {
    return StockItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      minLevel: minLevel ?? this.minLevel,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      supplier: supplier ?? this.supplier,
      packetsCount: packetsCount ?? this.packetsCount,
      amountPerPacket: amountPerPacket ?? this.amountPerPacket,
      costPerPacket: costPerPacket ?? this.costPerPacket,
      minPackets: minPackets ?? this.minPackets,
      logs: logs ?? this.logs,
      lastAudited: lastAudited ?? this.lastAudited,
    );
  }
}
