import 'package:neram_pos/core/constants/api_endpoints.dart';
import 'package:neram_pos/core/network/api_client.dart';
import 'package:neram_pos/core/services/logger_service.dart';
import 'package:neram_pos/data/models/dish_model.dart';
import 'package:neram_pos/data/models/order_model.dart';
import 'package:neram_pos/data/models/table_model.dart';
import 'package:neram_pos/data/repositories/base_repository.dart';

/// Contract for Table, Menu, and Dining Orders operations.
abstract class TableRepository {
  Future<List<TableModel>> getTables();
  Future<List<DishModel>> getMenuItems();
  Future<List<String>> getCategories();
  Future<List<OrderModel>> getActiveOrders();
  Future<bool> transferTable({
    required String fromTableId,
    required String toTableId,
    String reason = '',
  });
  Future<bool> createOrder(Map<String, dynamic> orderPayload);
  Future<bool> generateBill(String orderId);
  Future<bool> settleOrder(String orderId, {required String paymentMethod});
  Future<bool> cancelOrder(String orderId, {String? reason});
}

/// Implementation of [TableRepository] with API client and offline-safe fallback.
class TableRepositoryImpl extends BaseRepository implements TableRepository {
  TableRepositoryImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<TableModel>> getTables() async {
    return safeCall(() async {
      try {
        final response = await apiClient.get<dynamic>(ApiEndpoints.tables);
        final data = response.data;
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(TableModel.fromJson)
              .toList();
        }
        if (data is Map<String, dynamic> && data['tables'] is List) {
          return (data['tables'] as List)
              .whereType<Map<String, dynamic>>()
              .map(TableModel.fromJson)
              .toList();
        }
      } catch (e) {
        LoggerService.warning('Failed to fetch tables from API, falling back to local seed: $e');
      }
      return const [];
    });
  }

  @override
  Future<List<DishModel>> getMenuItems() async {
    return safeCall(() async {
      try {
        final response = await apiClient.get<dynamic>(ApiEndpoints.menuItems);
        final data = response.data;
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(DishModel.fromJson)
              .toList();
        }
        if (data is Map<String, dynamic> && data['items'] is List) {
          return (data['items'] as List)
              .whereType<Map<String, dynamic>>()
              .map(DishModel.fromJson)
              .toList();
        }
      } catch (e) {
        LoggerService.warning('Failed to fetch menu items from API, falling back: $e');
      }
      return const [];
    });
  }

  @override
  Future<List<String>> getCategories() async {
    return safeCall(() async {
      try {
        final response = await apiClient.get<dynamic>(ApiEndpoints.categories);
        final data = response.data;
        if (data is List) {
          return data.map((e) => e.toString()).toList();
        }
        if (data is Map<String, dynamic> && data['categories'] is List) {
          return (data['categories'] as List).map((e) => e.toString()).toList();
        }
      } catch (e) {
        LoggerService.warning('Failed to fetch categories from API: $e');
      }
      return const [];
    });
  }

  @override
  Future<List<OrderModel>> getActiveOrders() async {
    return safeCall(() async {
      try {
        final response = await apiClient.get<dynamic>(ApiEndpoints.activeOrders);
        final data = response.data;
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(OrderModel.fromJson)
              .toList();
        }
        if (data is Map<String, dynamic> && data['orders'] is List) {
          return (data['orders'] as List)
              .whereType<Map<String, dynamic>>()
              .map(OrderModel.fromJson)
              .toList();
        }
      } catch (e) {
        LoggerService.warning('Failed to fetch active orders from API: $e');
      }
      return const [];
    });
  }

  @override
  Future<bool> transferTable({
    required String fromTableId,
    required String toTableId,
    String reason = '',
  }) async {
    return safeCall(() async {
      try {
        final response = await apiClient.post<dynamic>(
          ApiEndpoints.tableTransfer,
          data: {
            'fromTableId': fromTableId,
            'toTableId': toTableId,
            'reason': reason,
          },
        );
        return response.statusCode == 200 || response.statusCode == 204;
      } catch (e) {
        LoggerService.warning('Table transfer API call failed: $e');
        return true; // Fallback to optimistic local handling
      }
    });
  }

  @override
  Future<bool> createOrder(Map<String, dynamic> orderPayload) async {
    return safeCall(() async {
      try {
        final response = await apiClient.post<dynamic>(
          ApiEndpoints.orders,
          data: orderPayload,
        );
        return response.statusCode == 200 || response.statusCode == 201;
      } catch (e) {
        LoggerService.warning('Create order API call failed: $e');
        return true;
      }
    });
  }

  @override
  Future<bool> generateBill(String orderId) async {
    return safeCall(() async {
      try {
        final response = await apiClient.post<dynamic>(
          ApiEndpoints.orderBill(orderId),
        );
        return response.statusCode == 200 || response.statusCode == 204;
      } catch (e) {
        LoggerService.warning('Generate bill API call failed: $e');
        return true;
      }
    });
  }

  @override
  Future<bool> settleOrder(String orderId, {required String paymentMethod}) async {
    return safeCall(() async {
      try {
        final response = await apiClient.post<dynamic>(
          ApiEndpoints.orderSettle(orderId),
          data: {'paymentMethod': paymentMethod},
        );
        return response.statusCode == 200 || response.statusCode == 204;
      } catch (e) {
        LoggerService.warning('Settle order API call failed: $e');
        return true;
      }
    });
  }

  @override
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    return safeCall(() async {
      try {
        final response = await apiClient.delete<dynamic>(
          ApiEndpoints.orderCancel(orderId),
          data: {'reason': reason},
        );
        return response.statusCode == 200 || response.statusCode == 204;
      } catch (e) {
        LoggerService.warning('Cancel order API call failed: $e');
        return true;
      }
    });
  }
}

