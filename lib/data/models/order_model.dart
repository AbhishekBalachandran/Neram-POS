import 'package:neram_pos/data/models/table_model.dart';

/// Represents an active kitchen/dining order.
class OrderModel {
  const OrderModel({
    required this.id,
    required this.tableId,
    required this.tableName,
    required this.customerName,
    required this.items,
    required this.total,
    required this.status,
    required this.timeElapsed,
    required this.zone,
  });

  final String id;
  final String tableId;
  final String tableName;
  final String customerName;
  final List<String> items;
  final double total;
  final TableStatus status;
  final String timeElapsed;
  final TableZone zone;

  String get formattedTotal => '₹${total.toStringAsFixed(2)}';

  OrderModel copyWith({
    String? id,
    String? tableId,
    String? tableName,
    String? customerName,
    List<String>? items,
    double? total,
    TableStatus? status,
    String? timeElapsed,
    TableZone? zone,
  }) {
    return OrderModel(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      tableName: tableName ?? this.tableName,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      zone: zone ?? this.zone,
    );
  }
}
