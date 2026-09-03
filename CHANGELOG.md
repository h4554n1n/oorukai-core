## Unreleased

- `CrashReportingService`/`NoopCrashReportingService`/
  `FirebaseCrashReportingService`: crash and non-fatal error reporting,
  backed by `firebase_crashlytics` behind an injectable `CrashlyticsGateway`.
- `AnalyticsService`/`NoopAnalyticsService`/`FirebaseAnalyticsService`:
  product analytics, backed by `firebase_analytics` behind an injectable
  `FirebaseAnalyticsGateway`.

## 0.1.0

- `OorukaiSplashScreen`: studio-branded splash screen, migrated from
  Squeeze/Vertex, with the missing device-aspect-ratio safe-zone logic
  Santa Drop's splash screen didn't have.
- `OorukaiSplashArt`: bundled branding artwork and its measured geometry.
- `isCoverSafe`, `coverMappedRect`, `containMappedRect`: splash-art layout
  geometry helpers.
