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

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    TableZone zone = TableZone.indoor;
    final zoneStr = (json['zone'] as String?)?.toLowerCase();
    if (zoneStr == 'outdoor') zone = TableZone.outdoor;
    if (zoneStr == 'takeaway') zone = TableZone.takeaway;

    TableStatus status = TableStatus.preparing;
    final statusStr = (json['status'] as String?)?.toLowerCase();
    if (statusStr == 'vacant') status = TableStatus.vacant;
    if (statusStr == 'occupied' || statusStr == 'dining') status = TableStatus.occupied;
    if (statusStr == 'billed') status = TableStatus.billed;

    final rawItems = json['items'];
    final itemsList = <String>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is String) {
          itemsList.add(item);
        } else if (item is Map) {
          final qty = item['quantity'] ?? item['qty'] ?? 1;
          final name = item['name'] ?? item['dishName'] ?? '';
          itemsList.add('${qty}x $name');
        }
      }
    }

    return OrderModel(
      id: json['id'] as String? ?? '',
      tableId: json['tableId'] as String? ?? '',
      tableName: json['tableName'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      items: itemsList,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: status,
      timeElapsed: json['timeElapsed'] as String? ?? 'Just now',
      zone: zone,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tableId': tableId,
    'tableName': tableName,
    'customerName': customerName,
    'items': items,
    'total': total,
    'status': status.name,
    'timeElapsed': timeElapsed,
    'zone': zone.name,
  };
}
