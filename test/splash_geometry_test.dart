import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oorukai_core/oorukai_core.dart';

void main() {
  group('isCoverSafe', () {
    // iPad-landscape-shaped: safe, cover applies (12.50% x-crop < 22.97% budget).
    test('landscape device against landscape image is safe', () {
      final safe = isCoverSafe(
        deviceSize: const Size(2160, 1620),
        imageSize: const Size(1920, 1080),
        safeContentFraction: const Rect.fromLTRB(0.2297, 0.1389, 0.7693, 0.9657),
      );
      expect(safe, isTrue);
    });

    // iPad-portrait-shaped: unsafe, contain-fallback (12.50% y-crop > 2.45% budget).
    test('portrait device against portrait image is unsafe', () {
      final safe = isCoverSafe(
        deviceSize: const Size(1620, 2160),
        imageSize: const Size(1080, 1920),
        safeContentFraction: const Rect.fromLTRB(0.2074, 0.1203, 0.8380, 0.9755),
      );
      expect(safe, isFalse);
    });

    // iPhone-14-shaped portrait: safe (8.93% x-crop < 16.20% budget).
    test('phone-portrait device against portrait image is safe', () {
      final safe = isCoverSafe(
        deviceSize: const Size(390, 844),
        imageSize: const Size(1080, 1920),
        safeContentFraction: const Rect.fromLTRB(0.2074, 0.1203, 0.8380, 0.9755),
      );
      expect(safe, isTrue);
    });

    // iPhone-14-shaped landscape: unsafe (8.93% y-crop > 3.43% budget).
    test('phone-landscape device against landscape image is unsafe', () {
      final safe = isCoverSafe(
        deviceSize: const Size(844, 390),
        imageSize: const Size(1920, 1080),
        safeContentFraction: const Rect.fromLTRB(0.2297, 0.1389, 0.7693, 0.9657),
      );
      expect(safe, isFalse);
    });
  });

  group('coverMappedRect / containMappedRect', () {
    test('coverMappedRect keeps a centred fractional rect within the device bounds', () {
      final rect = coverMappedRect(
        deviceSize: const Size(390, 844),
        imageSize: const Size(1080, 1920),
        fractionalRect: const Rect.fromLTRB(0.3259, 0.8620, 0.6741, 0.8672),
      );
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(390));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(844));
    });

    test('containMappedRect letterboxes a centred fractional rect within the device bounds', () {
      final rect = containMappedRect(
        deviceSize: const Size(1620, 2160),
        imageSize: const Size(1080, 1920),
        fractionalRect: const Rect.fromLTRB(0.3259, 0.8620, 0.6741, 0.8672),
      );
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(1620));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(2160));
    });
  });
}
