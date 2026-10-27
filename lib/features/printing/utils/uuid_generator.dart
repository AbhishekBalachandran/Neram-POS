import 'dart:math';

/// RFC 4122 version 4 compliant UUID generator using [Random.secure].
/// Produces a lowercase 36-character string in 8-4-4-4-12 format.
abstract final class UuidGenerator {
  static final Random _secureRandom = Random.secure();

  /// Generates a cryptographically secure RFC 4122 version 4 UUID.
  static String v4() {
    final bytes = List<int>.generate(16, (_) => _secureRandom.nextInt(256));

    // Set version to 4 -> 0100xxxx in byte 6
    bytes[6] = (bytes[6] & 0x0f) | 0x40;

    // Set variant to 10xxxxxx in byte 8 (RFC 4122)
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20, 32)}';
  }

  /// Validates whether a given string is a valid RFC 4122 version 4 UUID.
  static bool isValidV4(String uuid) {
    final regex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return regex.hasMatch(uuid);
  }
}

