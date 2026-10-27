import 'package:flutter/foundation.dart';

/// Configuration for a physical network thermal printer on the local LAN.
@immutable
class PrinterConfig {
  const PrinterConfig({
    required this.id,
    required this.name,
    required this.ip,
    this.port = 9100,
    required this.role,
    this.categories = const [],
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String ip;
  final int port;
  final String role; // 'kitchen', 'bar', 'billing'
  final List<String> categories;
  final bool isDefault;

  /// Whether this printer is responsible for printing items belonging to [category].
  bool canPrintCategory(String category) {
    if (categories.isEmpty) return isDefault;
    return categories.any(
      (c) => c.toLowerCase().trim() == category.toLowerCase().trim(),
    );
  }

  PrinterConfig copyWith({
    String? id,
    String? name,
    String? ip,
    int? port,
    String? role,
    List<String>? categories,
    bool? isDefault,
  }) {
    return PrinterConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      ip: ip ?? this.ip,
      port: port ?? this.port,
      role: role ?? this.role,
      categories: categories ?? this.categories,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'ip': ip,
    'port': port,
    'role': role,
    'categories': categories,
    'isDefault': isDefault,
  };

  factory PrinterConfig.fromJson(Map<String, dynamic> json) {
    return PrinterConfig(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      ip: json['ip'] as String? ?? '127.0.0.1',
      port: (json['port'] as num?)?.toInt() ?? 9100,
      role: json['role'] as String? ?? 'kitchen',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((c) => c.toString())
              .toList() ??
          const [],
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

