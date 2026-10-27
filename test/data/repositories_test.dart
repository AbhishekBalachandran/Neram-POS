import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neram_pos/core/network/api_client.dart';
import 'package:neram_pos/core/security/secure_storage_service.dart';
import 'package:neram_pos/core/security/token_manager.dart';
import 'package:neram_pos/data/models/dish_model.dart';
import 'package:neram_pos/data/models/leave_model.dart';
import 'package:neram_pos/data/models/stock_item_model.dart';
import 'package:neram_pos/data/models/table_model.dart';
import 'package:neram_pos/data/repositories/auth_repository.dart';
import 'package:neram_pos/data/repositories/leaves_repository.dart';
import 'package:neram_pos/data/repositories/stock_repository.dart';
import 'package:neram_pos/data/repositories/table_repository.dart';

class StubApiClient implements ApiClient {
  dynamic returnData;
  int returnStatusCode = 200;
  bool shouldThrow = false;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.connectionError,
      );
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: returnData as T?,
      statusCode: returnStatusCode,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.connectionError,
      );
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: returnData as T?,
      statusCode: returnStatusCode,
    );
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.connectionError,
      );
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: returnData as T?,
      statusCode: returnStatusCode,
    );
  }

  @override
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.connectionError,
      );
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: returnData as T?,
      statusCode: returnStatusCode,
    );
  }

  @override
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: returnData as T?,
      statusCode: returnStatusCode,
    );
  }
}

class FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> _storage = {};

  @override
  Future<void> write(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> read(String key) async => _storage[key];

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }
}

void main() {
  late StubApiClient apiClient;

  setUp(() {
    apiClient = StubApiClient();
  });

  group('TableRepository Tests', () {
    test('getTables parses json list correctly', () async {
      apiClient.returnData = [
        {
          'id': 'T-01',
          'name': 'Table T-01',
          'zone': 'indoor',
          'seats': 4,
          'status': 'vacant',
          'total': 0.0,
        }
      ];

      final repo = TableRepositoryImpl(apiClient: apiClient);
      final tables = await repo.getTables();

      expect(tables.length, 1);
      expect(tables.first.id, 'T-01');
      expect(tables.first.zone, TableZone.indoor);
    });

    test('getTables falls back gracefully to empty list on error', () async {
      apiClient.shouldThrow = true;
      final repo = TableRepositoryImpl(apiClient: apiClient);
      final tables = await repo.getTables();

      expect(tables, isEmpty);
    });

    test('getMenuItems parses menu items', () async {
      apiClient.returnData = [
        {
          'id': 'dish_1',
          'name': 'Crispy Corn',
          'category': 'Starters',
          'subtitle': 'Hot',
          'price': 8.50,
          'foodType': 'veg',
        }
      ];

      final repo = TableRepositoryImpl(apiClient: apiClient);
      final dishes = await repo.getMenuItems();

      expect(dishes.length, 1);
      expect(dishes.first.name, 'Crispy Corn');
      expect(dishes.first.foodType, FoodType.veg);
    });

    test('transferTable, createOrder, generateBill, cancelOrder return success', () async {
      final repo = TableRepositoryImpl(apiClient: apiClient);

      final transferOk = await repo.transferTable(fromTableId: 'T-01', toTableId: 'T-02');
      expect(transferOk, isTrue);

      final orderOk = await repo.createOrder({'tableId': 'T-01'});
      expect(orderOk, isTrue);

      final billOk = await repo.generateBill('ord-1');
      expect(billOk, isTrue);

      final settleOk = await repo.settleOrder('ord-1', paymentMethod: 'Card');
      expect(settleOk, isTrue);

      final cancelOk = await repo.cancelOrder('ord-1');
      expect(cancelOk, isTrue);
    });
  });

  group('StockRepository Tests', () {
    test('getInventoryItems parses stock list correctly', () async {
      apiClient.returnData = [
        {
          'id': 'stk_1',
          'name': 'Black Gloves',
          'category': 'consumables',
          'unit': 'boxes',
          'currentStock': 10.0,
          'minLevel': 2.0,
          'costPerUnit': 120.0,
          'supplier': 'SurgiSafe',
        }
      ];

      final repo = StockRepositoryImpl(apiClient: apiClient);
      final items = await repo.getInventoryItems();

      expect(items.length, 1);
      expect(items.first.name, 'Black Gloves');
      expect(items.first.category, StockCategory.consumables);
    });

    test('restockItem, recordUsage, submitAudit return success', () async {
      final repo = StockRepositoryImpl(apiClient: apiClient);

      final restockOk = await repo.restockItem(
        itemId: 'stk_1',
        addedQuantity: 5.0,
        staffName: 'Abhishek',
      );
      expect(restockOk, isTrue);

      final usageOk = await repo.recordUsage(
        itemId: 'stk_1',
        usedQuantity: 1.0,
        reason: 'Daily service',
        staffName: 'Abhishek',
      );
      expect(usageOk, isTrue);

      final auditOk = await repo.submitAudit(staffName: 'Abhishek');
      expect(auditOk, isTrue);
    });
  });

  group('LeavesRepository Tests', () {
    test('getLeaveApplications parses list correctly', () async {
      apiClient.returnData = [
        {
          'id': 'LV-100',
          'applicantName': 'Abhishek',
          'applicantRole': 'Manager',
          'staffId': 'ST-1',
          'initials': 'AB',
          'startDate': '2024-10-28T00:00:00.000',
          'endDate': '2024-10-29T00:00:00.000',
          'days': 2,
          'type': 'paidLeave',
          'reason': 'Vacation',
          'status': 'pending',
          'reviewedBy': 'Admin',
          'appliedAt': '2024-10-25T00:00:00.000',
        }
      ];

      final repo = LeavesRepositoryImpl(apiClient: apiClient);
      final leaves = await repo.getLeaveApplications();

      expect(leaves.length, 1);
      expect(leaves.first.applicantName, 'Abhishek');
      expect(leaves.first.type, LeaveType.paidLeave);
    });

    test('checkIn, checkOut, applyLeave, cancelLeave return success', () async {
      final repo = LeavesRepositoryImpl(apiClient: apiClient);

      final inOk = await repo.checkIn(timestamp: DateTime.now());
      expect(inOk, isTrue);

      final outOk = await repo.checkOut(timestamp: DateTime.now());
      expect(outOk, isTrue);

      final cancelOk = await repo.cancelLeave('LV-100');
      expect(cancelOk, isTrue);
    });
  });

  group('AuthRepository Change Password & Status Tests', () {
    test('changePassword and updateStatus succeed with demo token', () async {
      final storage = FakeSecureStorageService();
      final tokenManager = TokenManager(storageService: storage);
      await tokenManager.saveTokens(
        accessToken: 'sample_token_abhishek_valid',
        refreshToken: 'refresh_123',
      );

      final repo = AuthRepositoryImpl(apiClient: apiClient, tokenManager: tokenManager);

      final changeOk = await repo.changePassword(
        currentPassword: 'old',
        newPassword: 'new',
      );
      expect(changeOk, isTrue);

      final statusOk = await repo.updateStatus(isActive: true);
      expect(statusOk, isTrue);
    });
  });
}
