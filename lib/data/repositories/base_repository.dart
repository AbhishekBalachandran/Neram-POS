import 'package:neram_pos/core/errors/app_exception.dart';
import 'package:neram_pos/core/services/logger_service.dart';

/// Base repository providing safe execution wrapper for data operations.
abstract class BaseRepository {
  /// Wraps an asynchronous operation with standardized error mapping.
  Future<T> safeCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      LoggerService.error('Unexpected repository error: $e', e, stackTrace);
      throw UnexpectedException(
        message: 'An unexpected error occurred while processing data: $e',
      );
    }
  }
}
