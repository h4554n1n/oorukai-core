import 'package:flutter/widgets.dart';

/// Measurements of the studio's `oorukai_intro_landscape`/`_portrait`
/// artwork bundled with this package under `assets/branding/` — the source
/// pixel dimensions, the fraction of the frame that must stay on-screen
/// (mascot, wordmark, tagline), and the fraction occupied by the artwork's
/// own baked-in (static) loading-bar outline.
///
/// These are properties of the artwork itself, not of any one game, so
/// they're measured once here rather than re-measured per app.
abstract final class OorukaiSplashArt {
  /// The package these default asset paths are bundled in — pass as
  /// `Image.asset`'s `package` argument (or [OorukaiSplashScreen.assetPackage])
  /// alongside them, per the standard Flutter package-asset convention.
  static const assetPackage = 'oorukai_core';

  static const landscapeAssetPath = 'assets/branding/oorukai_intro_landscape.png';
  static const portraitAssetPath = 'assets/branding/oorukai_intro_portrait.png';

  static const landscapeImageSize = Size(1920, 1080);
  static const portraitImageSize = Size(1080, 1920);

  static const landscapeSafeContent = Rect.fromLTRB(
    0.2297,
    0.1389,
    0.7693,
    0.9657,
  );
  static const portraitSafeContent = Rect.fromLTRB(
    0.2074,
    0.1203,
    0.8380,
    0.9755,
  );

  static const landscapeBarFraction = Rect.fromLTRB(
    0.3922,
    0.8250,
    0.6078,
    0.8343,
  );
  static const portraitBarFraction = Rect.fromLTRB(
    0.3259,
    0.8620,
    0.6741,
    0.8672,
  );
}
