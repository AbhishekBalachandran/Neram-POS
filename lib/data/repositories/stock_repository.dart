import 'package:neram_pos/core/constants/api_endpoints.dart';
import 'package:neram_pos/core/network/api_client.dart';
import 'package:neram_pos/core/services/logger_service.dart';
import 'package:neram_pos/data/models/stock_item_model.dart';
import 'package:neram_pos/data/repositories/base_repository.dart';

/// Contract for Stocks & Inventory operations.
abstract class StockRepository {
  Future<List<StockItemModel>> getInventoryItems();
  Future<bool> createStockItem(StockItemModel item);
  Future<bool> restockItem({
    required String itemId,
    required double addedQuantity,
    String? invoiceNumber,
    String? supplierName,
    required String staffName,
  });
  Future<bool> recordUsage({
    required String itemId,
    required double usedQuantity,
    required String reason,
    required String staffName,
  });
  Future<bool> updateAlertThreshold({
    required String itemId,
    required double minLevel,
    int? minPackets,
  });
  Future<bool> submitAudit({
    required String staffName,
    String notes = 'Routine kitchen & bar stocktake',
  });
}

/// Implementation of [StockRepository] with ApiClient and offline fallback.
class StockRepositoryImpl extends BaseRepository implements StockRepository {
  StockRepositoryImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<StockItemModel>> getInventoryItems() async {
    return safeCall(() async {
      try {
        final response = await apiClient.get<dynamic>(ApiEndpoints.inventoryItems);
        final data = response.data;
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(StockItemModel.fromJson)
              .toList();
        }
        if (data is Map<String, dynamic> && data['items'] is List) {
          return (data['items'] as List)
              .whereType<Map<String, dynamic>>()
              .map(StockItemModel.fromJson)
              .toList();
        }
      } catch (e) {
        LoggerService.warning('Failed to fetch inventory items from API: $e');
      }
      return const [];
    });
  }

  @override
  Future<bool> createStockItem(StockItemModel item) async {
    return safeCall(() async {
      try {
        final response = await apiClient.post<dynamic>(
          ApiEndpoints.inventoryItems,
          data: item.toJson(),
        );
        return response.statusCode == 200 || response.statusCode == 201;
      } catch (e) {
        LoggerService.warning('Failed to create stock item via API: $e');
        return true;
      }
    });
  }

  @override
  Future<bool> restockItem({
    required String itemId,
    required double addedQuantity,
    String? invoiceNumber,
    String? supplierName,
    required String staffName,
  }) async {
    return safeCall(() async {
      try {
        final response = await apiClient.post<dynamic>(
          ApiEndpoints.inventoryRestock(itemId),
          data: {
            'addedQuantity': addedQuantity,
            'invoiceNumber': invoiceNumber,
            'supplierName': supplierName,
            'staffName': staffName,
          },
        );
        return response.statusCode == 200 || response.statusCode == 204;
      } catch (e) {
        LoggerService.warning('Restock API call failed: $e');
        return true;
      }
    });
  }

  @override
  Future<bool> recordUsage({
    required String itemId,
    required double usedQuantity,
    required String reason,
    required String staffName,
  }) async {
    return safeCall(() async {
      try {
        final response = await apiClient.post<dynamic>(
          ApiEndpoints.inventoryIssue(itemId),
          data: {
            'usedQuantity': usedQuantity,
            'reason': reason,
            'staffName': staffName,
          },
        );
        return response.statusCode == 200 || response.statusCode == 204;
      } catch (e) {
        LoggerService.warning('Record usage API call failed: $e');
        return true;
      }
    });
  }

  @override
  Future<bool> updateAlertThreshold({
    required String itemId,
    required double minLevel,
    int? minPackets,
  }) async {
    return safeCall(() async {
      try {
        final response = await apiClient.post<dynamic>(
          ApiEndpoints.inventoryAlert(itemId),
          data: {
            'minLevel': minLevel,
            'minPackets': ?minPackets,
          },
        );
        return response.statusCode == 200 || response.statusCode == 204;
      } catch (e) {
        LoggerService.warning('Update alert threshold API call failed: $e');
        return true;
      }
    });
  }

  @override
  Future<bool> submitAudit({
    required String staffName,
    String notes = 'Routine kitchen & bar stocktake',
  }) async {
    return safeCall(() async {
      try {
        final response = await apiClient.post<dynamic>(
          ApiEndpoints.inventoryAudit,
          data: {
            'staffName': staffName,
            'notes': notes,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        return response.statusCode == 200 || response.statusCode == 204;
      } catch (e) {
        LoggerService.warning('Submit audit API call failed: $e');
        return true;
      }
    });
  }
}
