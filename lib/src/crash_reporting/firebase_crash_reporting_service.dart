import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'crash_reporting_service.dart';

/// The subset of `FirebaseCrashlytics.instance` this service calls,
/// abstracted behind an interface so `FirebaseCrashReportingService` is
/// testable without a real platform channel — no `flutter_test`-compatible
/// fake exists for `firebase_crashlytics` itself.
abstract interface class CrashlyticsGateway {
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    required bool fatal,
  });

  Future<void> recordFlutterError(FlutterErrorDetails details);

  Future<void> log(String message);

  Future<void> setCustomKey(String key, Object value);
}

/// Wraps `FirebaseCrashlytics.instance` directly — the injectable seam
/// [FirebaseCrashReportingService] tests substitute a fake for.
class FirebaseCrashlyticsGateway implements CrashlyticsGateway {
  FirebaseCrashlyticsGateway(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    required bool fatal,
  }) {
    return _crashlytics.recordError(error, stackTrace, reason: reason, fatal: fatal);
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) {
    return _crashlytics.recordFlutterError(details);
  }

  @override
  Future<void> log(String message) => _crashlytics.log(message);

  @override
  Future<void> setCustomKey(String key, Object value) {
    return _crashlytics.setCustomKey(key, value);
  }
}

/// Real SDK-backed [CrashReportingService]. Every [CrashlyticsGateway] call
/// is wrapped so a Crashlytics failure (not yet initialized, plugin
/// unavailable, etc.) is swallowed rather than thrown back into game code —
/// crash reporting must never itself be the cause of a crash.
class FirebaseCrashReportingService implements CrashReportingService {
  FirebaseCrashReportingService(this._gateway);

  final CrashlyticsGateway _gateway;

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await _gateway.recordError(error, stackTrace, reason: reason, fatal: fatal);
    } catch (_) {
      // Swallow — see class doc.
    }
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    try {
      await _gateway.recordFlutterError(details);
    } catch (_) {
      // Swallow — see class doc.
    }
  }

  @override
  Future<void> log(String message) async {
    try {
      await _gateway.log(message);
    } catch (_) {
      // Swallow — see class doc.
    }
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    try {
      await _gateway.setCustomKey(key, value);
    } catch (_) {
      // Swallow — see class doc.
    }
  }
}
