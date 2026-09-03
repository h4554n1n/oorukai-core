import 'package:firebase_analytics/firebase_analytics.dart';

import 'analytics_service.dart';

/// The subset of `FirebaseAnalytics.instance` this service calls,
/// abstracted behind an interface so `FirebaseAnalyticsService` is testable
/// without a real platform channel — no `flutter_test`-compatible fake
/// exists for `firebase_analytics` itself.
abstract interface class FirebaseAnalyticsGateway {
  Future<void> logEvent(String name, {Map<String, Object?>? parameters});

  Future<void> setCurrentScreen(String screenName);

  Future<void> setUserProperty(String name, String? value);
}

/// Wraps `FirebaseAnalytics.instance` directly — the injectable seam
/// [FirebaseAnalyticsService] tests substitute a fake for.
class FirebaseAnalyticsGatewayImpl implements FirebaseAnalyticsGateway {
  FirebaseAnalyticsGatewayImpl(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) {
    // FirebaseAnalytics.logEvent's parameters map disallows null values
    // (Map<String, Object>?), while this gateway's interface allows them
    // for caller convenience — drop nulls rather than pushing that
    // restriction up to every call site.
    Map<String, Object>? effectiveParameters;
    if (parameters != null) {
      effectiveParameters = {
        for (final entry in parameters.entries)
          if (entry.value != null) entry.key: entry.value!,
      };
    }
    return _analytics.logEvent(name: name, parameters: effectiveParameters);
  }

  @override
  Future<void> setCurrentScreen(String screenName) {
    return _analytics.logScreenView(screenName: screenName);
  }

  @override
  Future<void> setUserProperty(String name, String? value) {
    return _analytics.setUserProperty(name: name, value: value);
  }
}

/// Real SDK-backed [AnalyticsService]. Every [FirebaseAnalyticsGateway]
/// call is wrapped so an Analytics failure (not yet initialized, plugin
/// unavailable, etc.) is swallowed rather than thrown back into game
/// code — analytics must never itself be the cause of a crash.
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService(this._gateway);

  final FirebaseAnalyticsGateway _gateway;

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
    try {
      await _gateway.logEvent(name, parameters: parameters);
    } catch (_) {
      // Swallow — see class doc.
    }
  }

  @override
  Future<void> setCurrentScreen(String screenName) async {
    try {
      await _gateway.setCurrentScreen(screenName);
    } catch (_) {
      // Swallow — see class doc.
    }
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    try {
      await _gateway.setUserProperty(name, value);
    } catch (_) {
      // Swallow — see class doc.
    }
  }
}
