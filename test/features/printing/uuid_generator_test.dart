import 'package:flutter_test/flutter_test.dart';
import 'package:neram_pos/features/printing/utils/uuid_generator.dart';

void main() {
  group('UuidGenerator RFC 4122 v4 Unit Tests', () {
    test('generates valid RFC 4122 v4 format (8-4-4-4-12 string)', () {
      final uuid = UuidGenerator.v4();

      expect(uuid.length, equals(36));
      expect(UuidGenerator.isValidV4(uuid), isTrue);

      final parts = uuid.split('-');
      expect(parts.length, equals(5));
      expect(parts[0].length, equals(8));
      expect(parts[1].length, equals(4));
      expect(parts[2].length, equals(4));
      expect(parts[3].length, equals(4));
      expect(parts[4].length, equals(12));
    });

    test('verifies version bit is 4 and variant bits are [8, 9, a, b]', () {
      for (var i = 0; i < 50; i++) {
        final uuid = UuidGenerator.v4();
        final parts = uuid.split('-');

        // Version bit: character at index 0 of parts[2] must be '4'
        expect(parts[2].startsWith('4'), isTrue);

        // Variant bits: character at index 0 of parts[3] must be 8, 9, a, or b
        final variantChar = parts[3][0].toLowerCase();
        expect(['8', '9', 'a', 'b'].contains(variantChar), isTrue);
      }
    });

    test('generates unique UUIDs without collision across 1000 generations', () {
      final generated = <String>{};
      for (var i = 0; i < 1000; i++) {
        final uuid = UuidGenerator.v4();
        expect(generated.contains(uuid), isFalse);
        generated.add(uuid);
      }
      expect(generated.length, equals(1000));
    });

    test('isValidV4 properly rejects invalid UUID strings', () {
      expect(UuidGenerator.isValidV4(''), isFalse);
      expect(UuidGenerator.isValidV4('invalid-uuid'), isFalse);
      // Version 1 instead of 4
      expect(
        UuidGenerator.isValidV4('550e8400-e29b-11d4-a716-446655440000'),
        isFalse,
      );
      // Invalid variant bit ('c')
      expect(
        UuidGenerator.isValidV4('550e8400-e29b-41d4-c716-446655440000'),
        isFalse,
      );
    });
  });
}

