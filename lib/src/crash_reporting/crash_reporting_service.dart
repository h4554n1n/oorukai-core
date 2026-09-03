import 'package:flutter/foundation.dart';

/// Crash and non-fatal error reporting, abstracted behind an interface so
/// call sites never depend on a specific vendor SDK directly.
///
/// A real implementation never throws back into game/screen code — every
/// method swallows its own failures (a reporting call going wrong should
/// never be the thing that crashes the game).
abstract interface class CrashReportingService {
  /// Records a non-fatal error, e.g. from a `catch` block. [fatal] marks it
  /// as having terminated the app, per the vendor SDK's own convention.
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  });

  /// Records a Flutter framework error, typically from
  /// `FlutterError.onError`.
  Future<void> recordFlutterError(FlutterErrorDetails details);

  /// A breadcrumb logged alongside the next reported error, not sent on
  /// its own.
  Future<void> log(String message);

  /// A structured key/value attached to every subsequent report.
  Future<void> setCustomKey(String key, Object value);
}

/// Default no-op implementation — every game starts wired to this until an
/// app-level implementation is injected, and tests use it as a safe
/// no-behavior stand-in.
class NoopCrashReportingService implements CrashReportingService {
  const NoopCrashReportingService();

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {}

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {}

  @override
  Future<void> log(String message) async {}

  @override
  Future<void> setCustomKey(String key, Object value) async {}
}
