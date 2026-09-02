import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oorukai_core/oorukai_core.dart';

const _minimumDuration = Duration(milliseconds: 2200);

Widget _wrap(Widget child, {required Size size}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Center(
    child: SizedBox(width: size.width, height: size.height, child: child),
  ),
);

void main() {
  group('OorukaiSplashScreen orientation layout', () {
    testWidgets('landscape device size renders the landscape asset', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OorukaiSplashScreen(minimumDuration: _minimumDuration, onFinished: () {}),
          size: const Size(844, 390),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as AssetImage).assetName,
        OorukaiSplashArt.landscapeAssetPath,
      );
    });

    testWidgets('portrait device size renders the portrait asset', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OorukaiSplashScreen(minimumDuration: _minimumDuration, onFinished: () {}),
          size: const Size(390, 844),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as AssetImage).assetName,
        OorukaiSplashArt.portraitAssetPath,
      );
    });
  });

  group('OorukaiSplashScreen bar animation', () {
    testWidgets('fill fraction animates from 0 toward 1 and holds at 1', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OorukaiSplashScreen(minimumDuration: _minimumDuration, onFinished: () {}),
          size: const Size(390, 844),
        ),
      );

      final atStart = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(atStart.widthFactor, 0.0);

      await tester.pump(const Duration(milliseconds: 1100));
      final atHalf = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(atHalf.widthFactor, closeTo(0.5, 0.05));

      await tester.pump(const Duration(milliseconds: 1100));
      final atEnd = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(atEnd.widthFactor, 1.0);

      await tester.pump(const Duration(milliseconds: 500));
      final held = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(held.widthFactor, 1.0); // holds, doesn't loop or reset
    });
  });

  group('OorukaiSplashScreen minimum duration + readiness race', () {
    testWidgets('stays visible for the minimum duration even when readyFuture resolves instantly', (
      tester,
    ) async {
      var finished = false;
      await tester.pumpWidget(
        _wrap(
          OorukaiSplashScreen(
            minimumDuration: _minimumDuration,
            readyFuture: Future.value(),
            onFinished: () => finished = true,
          ),
          size: const Size(390, 844),
        ),
      );
      await tester.pump(); // let the already-resolved future's .then() fire

      await tester.pump(const Duration(milliseconds: 2100));
      expect(finished, isFalse); // minimum not elapsed yet

      await tester.pump(const Duration(milliseconds: 200));
      expect(finished, isTrue); // minimum elapsed + ready
    });

    testWidgets('stays visible past the minimum duration while readyFuture is still pending', (
      tester,
    ) async {
      final completer = Completer<void>();
      var finished = false;
      await tester.pumpWidget(
        _wrap(
          OorukaiSplashScreen(
            minimumDuration: _minimumDuration,
            readyFuture: completer.future,
            onFinished: () => finished = true,
          ),
          size: const Size(390, 844),
        ),
      );

      await tester.pump(const Duration(milliseconds: 2300));
      expect(finished, isFalse); // minimum elapsed, readiness still pending

      completer.complete();
      await tester.pump();
      expect(finished, isTrue);
    });

    testWidgets('with no readyFuture, finishes purely on the minimum duration', (tester) async {
      var finished = false;
      await tester.pumpWidget(
        _wrap(
          OorukaiSplashScreen(
            minimumDuration: _minimumDuration,
            onFinished: () => finished = true,
          ),
          size: const Size(390, 844),
        ),
      );

      await tester.pump(const Duration(milliseconds: 2100));
      expect(finished, isFalse);

      await tester.pump(const Duration(milliseconds: 200));
      expect(finished, isTrue);
    });
  });

  group('OorukaiSplashScreen image-load failure', () {
    testWidgets('skips the minimum duration once the image fails to load', (tester) async {
      var finished = false;
      await tester.pumpWidget(
        _wrap(
          OorukaiSplashScreen(
            minimumDuration: _minimumDuration,
            readyFuture: Future.value(),
            onFinished: () => finished = true,
            landscapeAssetPath: 'assets/branding/does_not_exist.png',
            portraitAssetPath: 'assets/branding/does_not_exist.png',
          ),
          size: const Size(390, 844),
        ),
      );

      await tester.pump(); // resolve the already-completed readyFuture
      await tester.pump(); // let the failed image's errorBuilder fire
      await tester.pump(); // let the deferred post-frame callback run

      expect(finished, isTrue); // well before the minimum duration
    });

    testWidgets(
      'image failure while readiness is still pending finishes as soon as it resolves, '
      'without waiting for the minimum duration',
      (tester) async {
        final completer = Completer<void>();
        var finished = false;
        await tester.pumpWidget(
          _wrap(
            OorukaiSplashScreen(
              minimumDuration: _minimumDuration,
              readyFuture: completer.future,
              onFinished: () => finished = true,
              landscapeAssetPath: 'assets/branding/does_not_exist.png',
              portraitAssetPath: 'assets/branding/does_not_exist.png',
            ),
            size: const Size(390, 844),
          ),
        );

        await tester.pump(); // let the failed image's errorBuilder fire
        await tester.pump(); // let the deferred post-frame callback run
        expect(finished, isFalse); // image failed, but readiness hasn't resolved yet

        completer.complete();
        await tester.pump();
        expect(finished, isTrue); // resolves immediately, well before the minimum duration
      },
    );
  });

  group('OorukaiSplashScreen touch input', () {
    testWidgets('never responds to touch input', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OorukaiSplashScreen(minimumDuration: _minimumDuration, onFinished: () {}),
          size: const Size(390, 844),
        ),
      );

      final ignorePointer = tester.widget<IgnorePointer>(
        find.descendant(
          of: find.byType(OorukaiSplashScreen),
          matching: find.byType(IgnorePointer),
        ),
      );
      expect(ignorePointer.ignoring, isTrue);
    });
  });
}
