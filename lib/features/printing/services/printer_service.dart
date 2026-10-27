import 'dart:async';
import 'dart:io';
import 'package:neram_pos/core/services/logger_service.dart';

/// Base exception for printer communication failures.
sealed class PrinterException implements Exception {
  const PrinterException(this.message, [this.details]);
  final String message;
  final dynamic details;

  @override
  String toString() => '$message${details != null ? ' ($details)' : ''}';
}

class PrinterTimeoutException extends PrinterException {
  const PrinterTimeoutException(super.message, [super.details]);
}

class PrinterConnectionRefusedException extends PrinterException {
  const PrinterConnectionRefusedException(super.message, [super.details]);
}

class PrinterUnreachableException extends PrinterException {
  const PrinterUnreachableException(super.message, [super.details]);
}

class PrinterUnknownException extends PrinterException {
  const PrinterUnknownException(super.message, [super.details]);
}

/// Abstract transport contract for thermal receipt and ticket printers.
/// Allows swapping direct raw TCP socket with Bluetooth, USB, or mock implementations.
abstract class PrinterService {
  /// Sends raw bytes (typically ESC/POS commands) to a network printer.
  /// Throws a typed [PrinterException] on failure.
  Future<void> printRaw(
    String ip,
    int port,
    List<int> bytes, {
    Duration connectTimeout = const Duration(seconds: 3),
    Duration overallTimeout = const Duration(seconds: 5),
  });
}

/// Direct raw TCP socket implementation of [PrinterService] connecting to `ip:port`
/// (default port 9100).
///
/// NOTE ON TCP DELIVERY ACKNOWLEDGEMENT:
/// TCP guarantees packet transmission and receives TCP ACKs at the OS network layer,
/// but physical thermal printer firmware gives NO hardware delivery or paper print ACK.
/// A successful socket flush means data was "sent" into the printer's receive buffer,
/// NOT that it has physically printed. If the app or device crashes while printing,
/// the job state is recovered as [PrintStatus.unknown] and never auto-reprinted.
class SocketPrinterService implements PrinterService {
  const SocketPrinterService();

  @override
  Future<void> printRaw(
    String ip,
    int port,
    List<int> bytes, {
    Duration connectTimeout = const Duration(seconds: 3),
    Duration overallTimeout = const Duration(seconds: 5),
  }) async {
    final stopwatch = Stopwatch()..start();
    Socket? socket;

    try {
      // Connect with 3s timeout
      socket = await Socket.connect(
        ip,
        port,
        timeout: connectTimeout,
      ).timeout(
        connectTimeout,
        onTimeout: () {
          throw PrinterTimeoutException(
            'Connection timed out after ${connectTimeout.inSeconds}s to $ip:$port',
          );
        },
      );

      // Write payload and flush with overall timeout
      socket.add(bytes);
      await socket.flush().timeout(
        overallTimeout,
        onTimeout: () {
          throw PrinterTimeoutException(
            'Flushing print data timed out after ${overallTimeout.inSeconds}s to $ip:$port',
          );
        },
      );

      stopwatch.stop();
      LoggerService.debug(
        'Successfully dispatched ${bytes.length} bytes to printer $ip:$port '
        'in ${stopwatch.elapsedMilliseconds}ms',
      );
    } on SocketException catch (e) {
      stopwatch.stop();
      final msg = e.message.toLowerCase();
      final osCode = e.osError?.errorCode ?? 0;

      if (msg.contains('refused') || osCode == 61 || osCode == 111) {
        throw PrinterConnectionRefusedException(
          'Printer port $port on $ip refused connection.',
          e,
        );
      } else if (msg.contains('unreachable') ||
          msg.contains('no route') ||
          msg.contains('network') ||
          osCode == 65 ||
          osCode == 101) {
        throw PrinterUnreachableException(
          'Printer at $ip is unreachable on current network.',
          e,
        );
      } else if (msg.contains('timed out')) {
        throw PrinterTimeoutException('Network timeout reaching $ip:$port', e);
      }

      throw PrinterUnknownException('Socket error printing to $ip:$port: ${e.message}', e);
    } on TimeoutException catch (e) {
      stopwatch.stop();
      throw PrinterTimeoutException('Operation timed out on $ip:$port', e);
    } on PrinterException {
      rethrow;
    } catch (e) {
      stopwatch.stop();
      throw PrinterUnknownException('Unexpected error printing to $ip:$port: $e', e);
    } finally {
      // Always close and destroy socket
      if (socket != null) {
        try {
          await socket.close();
        } catch (_) {}
        try {
          socket.destroy();
        } catch (_) {}
      }
    }
  }
}

