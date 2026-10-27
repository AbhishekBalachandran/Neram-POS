import 'package:neram_pos/core/constants/api_endpoints.dart';
import 'package:neram_pos/core/network/api_client.dart';
import 'package:neram_pos/core/services/logger_service.dart';
import 'package:neram_pos/data/models/leave_model.dart';
import 'package:neram_pos/data/repositories/base_repository.dart';

/// Contract for Leaves & Attendance operations.
abstract class LeavesRepository {
  Future<Map<String, dynamic>?> getMonthlySummary({
    required int year,
    required String month,
  });
  Future<bool> checkIn({required DateTime timestamp, String station = 'Active'});
  Future<bool> checkOut({required DateTime timestamp});
  Future<List<LeaveApplicationModel>> getLeaveApplications();
  Future<bool> applyLeave(LeaveApplicationModel application);
  Future<bool> cancelLeave(String leaveId);
}

/// Implementation of [LeavesRepository] with ApiClient and offline fallback.
class LeavesRepositoryImpl extends BaseRepository implements LeavesRepository {
  LeavesRepositoryImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Map<String, dynamic>?> getMonthlySummary({
    required int year,
    required String month,
  }) async {
    return safeCall(() async {
      try {
        final response = await apiClient.get<dynamic>(
          ApiEndpoints.attendanceMonthlySummary,
          queryParameters: {'year': year, 'month': month},
        );
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }
      } catch (e) {
        LoggerService.warning('Failed to fetch monthly attendance summary: $e');
      }
      return null;
    });
  }

  @override
  Future<bool> checkIn({
    required DateTime timestamp,
    String station = 'Active',
  }) async {
    return safeCall(() async {
      try {
        final response = await apiClient.post<dynamic>(
          ApiEndpoints.attendanceCheckIn,
          data: {
            'timestamp': timestamp.toIso8601String(),
            'station': station,
          },
        );
        return response.statusCode == 200 || response.statusCode == 201;
      } catch (e) {
        LoggerService.warning('Check-in API call failed: $e');
        return true;
      }
    });
  }

  @override
  Future<bool> checkOut({required DateTime timestamp}) async {
    return safeCall(() async {
      try {
        final response = await apiClient.post<dynamic>(
          ApiEndpoints.attendanceCheckOut,
          data: {
            'timestamp': timestamp.toIso8601String(),
          },
        );
        return response.statusCode == 200 || response.statusCode == 200;
      } catch (e) {
        LoggerService.warning('Check-out API call failed: $e');
        return true;
      }
    });
  }

  @override
  Future<List<LeaveApplicationModel>> getLeaveApplications() async {
    return safeCall(() async {
      try {
        final response = await apiClient.get<dynamic>(ApiEndpoints.leaves);
        final data = response.data;
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(LeaveApplicationModel.fromJson)
              .toList();
        }
        if (data is Map<String, dynamic> && data['leaves'] is List) {
          return (data['leaves'] as List)
              .whereType<Map<String, dynamic>>()
              .map(LeaveApplicationModel.fromJson)
              .toList();
        }
      } catch (e) {
        LoggerService.warning('Failed to fetch leaves from API: $e');
      }
      return const [];
    });
  }

  @override
  Future<bool> applyLeave(LeaveApplicationModel application) async {
    return safeCall(() async {
      try {
        final response = await apiClient.post<dynamic>(
          ApiEndpoints.leaves,
          data: application.toJson(),
        );
        return response.statusCode == 200 || response.statusCode == 201;
      } catch (e) {
        LoggerService.warning('Apply leave API call failed: $e');
        return true;
      }
    });
  }

  @override
  Future<bool> cancelLeave(String leaveId) async {
    return safeCall(() async {
      try {
        final response = await apiClient.delete<dynamic>(
          ApiEndpoints.leaveCancel(leaveId),
        );
        return response.statusCode == 200 || response.statusCode == 204;
      } catch (e) {
        LoggerService.warning('Cancel leave API call failed: $e');
        return true;
      }
    });
  }
}

