import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Whether `BoxFit.cover`'s required crop for [deviceSize] against
/// [imageSize] stays within [safeContentFraction] — the measured
/// essential-content bounding rect for that orientation.
///
/// Callers use this to decide between `BoxFit.cover` (fills the screen,
/// crops the edges) and `BoxFit.contain` (never crops, letterboxes
/// instead) for a fixed piece of artwork: cover is safe only while the
/// crop it would need stays inside the region the artwork can't afford to
/// lose.
bool isCoverSafe({
  required Size deviceSize,
  required Size imageSize,
  required Rect safeContentFraction,
}) {
  final scale = math.max(
    deviceSize.width / imageSize.width,
    deviceSize.height / imageSize.height,
  );
  final scaledWidth = imageSize.width * scale;
  final scaledHeight = imageSize.height * scale;
  final cropX = scaledWidth > deviceSize.width
      ? (scaledWidth - deviceSize.width) / (2 * scaledWidth)
      : 0.0;
  final cropY = scaledHeight > deviceSize.height
      ? (scaledHeight - deviceSize.height) / (2 * scaledHeight)
      : 0.0;
  return cropX <= safeContentFraction.left &&
      cropX <= (1 - safeContentFraction.right) &&
      cropY <= safeContentFraction.top &&
      cropY <= (1 - safeContentFraction.bottom);
}

/// Maps a fractional [fractionalRect] (measured against [imageSize]) into
/// an on-screen [Rect] for [deviceSize] under `BoxFit.cover`.
Rect coverMappedRect({
  required Size deviceSize,
  required Size imageSize,
  required Rect fractionalRect,
}) => _mappedRect(
  deviceSize: deviceSize,
  imageSize: imageSize,
  fractionalRect: fractionalRect,
  scale: math.max(
    deviceSize.width / imageSize.width,
    deviceSize.height / imageSize.height,
  ),
);

/// As [coverMappedRect], but for the `BoxFit.contain` fallback.
Rect containMappedRect({
  required Size deviceSize,
  required Size imageSize,
  required Rect fractionalRect,
}) => _mappedRect(
  deviceSize: deviceSize,
  imageSize: imageSize,
  fractionalRect: fractionalRect,
  scale: math.min(
    deviceSize.width / imageSize.width,
    deviceSize.height / imageSize.height,
  ),
);

Rect _mappedRect({
  required Size deviceSize,
  required Size imageSize,
  required Rect fractionalRect,
  required double scale,
}) {
  final offsetX = (deviceSize.width - imageSize.width * scale) / 2;
  final offsetY = (deviceSize.height - imageSize.height * scale) / 2;
  return Rect.fromLTRB(
    offsetX + fractionalRect.left * imageSize.width * scale,
    offsetY + fractionalRect.top * imageSize.height * scale,
    offsetX + fractionalRect.right * imageSize.width * scale,
    offsetY + fractionalRect.bottom * imageSize.height * scale,
  );
}
