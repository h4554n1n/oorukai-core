/// Product analytics, abstracted behind an interface so call sites never
/// depend on a specific vendor SDK directly.
///
/// A real implementation never throws back into game/screen code — every
/// method swallows its own failures (an analytics call going wrong should
/// never be the thing that crashes the game).
abstract interface class AnalyticsService {
  /// Logs an event by name, with optional flat parameters. Vendor SDKs
  /// generally restrict event/parameter names to lowercase letters,
  /// digits, and underscores — callers are responsible for staying within
  /// that, this interface doesn't validate it.
  Future<void> logEvent(String name, {Map<String, Object?>? parameters});

  /// Records the current screen, for screen-view funnels.
  Future<void> setCurrentScreen(String screenName);

  /// A persistent property attached to every subsequent event for this
  /// user. Pass a null [value] to clear it.
  Future<void> setUserProperty(String name, String? value);
}

/// Default no-op implementation — every game starts wired to this until an
/// app-level implementation is injected, and tests use it as a safe
/// no-behavior stand-in.
class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {}

  @override
  Future<void> setCurrentScreen(String screenName) async {}

  @override
  Future<void> setUserProperty(String name, String? value) async {}
}
