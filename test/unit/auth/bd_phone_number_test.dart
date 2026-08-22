import 'package:flutter_test/flutter_test.dart';
import 'package:swarnakar/features/auth/domain/bd_phone_number.dart';

void main() {
  group('normalizeBdPhone', () {
    test('preserves local format', () {
      expect(normalizeBdPhone('01712345678'), '01712345678');
    });
    test('converts +880 format', () {
      expect(normalizeBdPhone('+8801712345678'), '01712345678');
    });
    test('converts 880 format', () {
      expect(normalizeBdPhone('8801712345678'), '01712345678');
    });
    test('removes separators', () {
      expect(normalizeBdPhone('017-1234 5678'), '01712345678');
    });
    test('removes non-digit characters', () {
      expect(normalizeBdPhone('phone: 01812.345.678'), '01812345678');
    });
    test('returns empty for input without digits', () {
      expect(normalizeBdPhone('not-a-phone'), isEmpty);
    });
  });

  group('isValidBdMobile', () {
    for (var digit = 3; digit <= 9; digit++) {
      test('accepts a valid operator prefix $digit', () {
        expect(isValidBdMobile('01$digit' '12345678'), isTrue);
      });
    }

    for (final invalid in [
      '',
      '01012345678',
      '01112345678',
      '01212345678',
      '0171234567',
      '017123456789',
      '+8801712345678',
      '01712 345678',
      'abcdefghijk',
    ]) {
      test('rejects invalid input $invalid', () {
        expect(isValidBdMobile(invalid), isFalse);
      });
    }

    test('accepts international input after normalization', () {
      expect(isValidBdMobile(normalizeBdPhone('+880 1712-345678')), isTrue);
    });
  });
}
