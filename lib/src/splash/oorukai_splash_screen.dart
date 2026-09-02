import 'package:flutter/material.dart';

import 'oorukai_splash_art.dart';
import 'splash_geometry.dart';

/// The studio's branded splash screen, shown for a few seconds on cold
/// start before the game's own menu/home screen.
///
/// Uses the studio's pre-composed artwork (mascot, wordmark, tagline,
/// static loading-bar outline) rather than recreating it from Flutter
/// widgets, so it stays pixel-identical to the brand asset regardless of
/// font availability. Picks the landscape or portrait composition to match
/// the device's aspect ratio, and never re-picks mid-splash if the device
/// rotates. A real animated progress bar is overlaid exactly on top of the
/// artwork's own static bar outline — position and size mapped from the
/// bar's measured location in the source image, so only one bar is ever
/// visible on screen.
///
/// [onFinished] fires once, after both [minimumDuration] has elapsed and
/// [readyFuture] (if given) has completed — whichever finishes last — so
/// the brand moment is never cut short but also never blocks on it once
/// the caller's own loading work is done. If the artwork fails to load,
/// [minimumDuration] is skipped (there's nothing left to show), but
/// [readyFuture] is still always awaited.
class OorukaiSplashScreen extends StatefulWidget {
  const OorukaiSplashScreen({
    super.key,
    required this.onFinished,
    this.minimumDuration = const Duration(milliseconds: 2200),
    this.readyFuture,
    this.landscapeAssetPath = OorukaiSplashArt.landscapeAssetPath,
    this.portraitAssetPath = OorukaiSplashArt.portraitAssetPath,
    this.assetPackage = OorukaiSplashArt.assetPackage,
    this.landscapeImageSize = OorukaiSplashArt.landscapeImageSize,
    this.portraitImageSize = OorukaiSplashArt.portraitImageSize,
    this.landscapeSafeContent = OorukaiSplashArt.landscapeSafeContent,
    this.portraitSafeContent = OorukaiSplashArt.portraitSafeContent,
    this.landscapeBarFraction = OorukaiSplashArt.landscapeBarFraction,
    this.portraitBarFraction = OorukaiSplashArt.portraitBarFraction,
    this.trackColor = const Color(0xFFF4F5F9),
    this.fillColor = const Color(0xFFB89C54),
    this.letterboxColor = const Color(0xFF2B5C4C),
  });

  /// Called exactly once, when the splash should be dismissed.
  final VoidCallback onFinished;

  /// The minimum time the brand moment stays on screen, skipped only if
  /// the artwork fails to load.
  final Duration minimumDuration;

  /// Optional app-supplied signal that its own startup work is done.
  /// When null, [onFinished] depends only on [minimumDuration].
  final Future<void>? readyFuture;

  final String landscapeAssetPath;
  final String portraitAssetPath;

  /// The package [landscapeAssetPath]/[portraitAssetPath] are bundled in,
  /// passed straight through to `Image.asset`'s `package` argument. Pass
  /// null when overriding the asset paths with ones from the app's own
  /// bundle rather than this package's.
  final String? assetPackage;

  final Size landscapeImageSize;
  final Size portraitImageSize;
  final Rect landscapeSafeContent;
  final Rect portraitSafeContent;
  final Rect landscapeBarFraction;
  final Rect portraitBarFraction;

  /// Colour of the progress bar's empty track.
  final Color trackColor;

  /// Colour of the progress bar's filled portion.
  final Color fillColor;

  /// Background shown behind the artwork when it's letterboxed
  /// (`BoxFit.contain`) rather than covering the full screen.
  final Color letterboxColor;

  @override
  State<OorukaiSplashScreen> createState() => _OorukaiSplashScreenState();
}

class _OorukaiSplashScreenState extends State<OorukaiSplashScreen>
    with SingleTickerProviderStateMixin {
  bool? _isLandscape;
  late final AnimationController _barController;
  bool _minimumElapsed = false;
  bool _imageFailed = false;
  bool _externallyReady = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _externallyReady = widget.readyFuture == null;
    _barController =
        AnimationController(vsync: this, duration: widget.minimumDuration)
          ..addStatusListener(_onBarStatusChanged)
          ..forward();
    widget.readyFuture?.then((_) {
      if (!mounted) return;
      _externallyReady = true;
      _maybeFinish();
    });
  }

  void _onBarStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _minimumElapsed = true;
    _maybeFinish();
  }

  void _onImageError() {
    if (_imageFailed || !mounted) return;
    setState(() => _imageFailed = true);
    _maybeFinish();
  }

  void _maybeFinish() {
    if (_finished) return;
    if (!_externallyReady) return;
    if (!_minimumElapsed && !_imageFailed) return;
    _finished = true;
    widget.onFinished();
  }

  /// Current fill fraction of the progress bar, exposed for tests only.
  @visibleForTesting
  double get debugBarValue => _barController.value;

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final deviceSize = constraints.biggest;
          _isLandscape ??= deviceSize.width > deviceSize.height;
          final isLandscape = _isLandscape!;
          final imageSize = isLandscape
              ? widget.landscapeImageSize
              : widget.portraitImageSize;
          final safeContent = isLandscape
              ? widget.landscapeSafeContent
              : widget.portraitSafeContent;
          final barFraction = isLandscape
              ? widget.landscapeBarFraction
              : widget.portraitBarFraction;
          final assetPath = isLandscape
              ? widget.landscapeAssetPath
              : widget.portraitAssetPath;
          final useCover =
              !_imageFailed &&
              isCoverSafe(
                deviceSize: deviceSize,
                imageSize: imageSize,
                safeContentFraction: safeContent,
              );
          final barRect = useCover
              ? coverMappedRect(
                  deviceSize: deviceSize,
                  imageSize: imageSize,
                  fractionalRect: barFraction,
                )
              : containMappedRect(
                  deviceSize: deviceSize,
                  imageSize: imageSize,
                  fractionalRect: barFraction,
                );

          return ColoredBox(
            color: useCover ? const Color(0xFF000000) : widget.letterboxColor,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (!_imageFailed)
                  Image.asset(
                    assetPath,
                    package: widget.assetPackage,
                    fit: useCover ? BoxFit.cover : BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _onImageError(),
                      );
                      return const SizedBox.shrink();
                    },
                  ),
                Positioned(
                  left: barRect.left,
                  top: barRect.top,
                  width: barRect.width,
                  height: barRect.height,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.trackColor,
                      borderRadius: BorderRadius.circular(barRect.height / 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(barRect.height / 2),
                      child: AnimatedBuilder(
                        animation: _barController,
                        builder: (context, child) => FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _barController.value.clamp(0.0, 1.0),
                          child: child,
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: widget.fillColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
