import 'package:flutter_test/flutter_test.dart';
import 'package:oorukai_core/oorukai_core.dart';

class _RecordedCall {
  _RecordedCall(this.method, this.args);
  final String method;
  final Map<String, Object?> args;
}

class _FakeAnalyticsGateway implements FirebaseAnalyticsGateway {
  final calls = <_RecordedCall>[];
  String? throwOn;

  void _maybeThrow(String method) {
    if (throwOn == method) throw StateError('$method failed');
  }

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
    _maybeThrow('logEvent');
    calls.add(_RecordedCall('logEvent', {'name': name, 'parameters': parameters}));
  }

  @override
  Future<void> setCurrentScreen(String screenName) async {
    _maybeThrow('setCurrentScreen');
    calls.add(_RecordedCall('setCurrentScreen', {'screenName': screenName}));
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    _maybeThrow('setUserProperty');
    calls.add(_RecordedCall('setUserProperty', {'name': name, 'value': value}));
  }
}

void main() {
  group('NoopAnalyticsService', () {
    test('every method completes without touching any gateway', () async {
      const service = NoopAnalyticsService();

      await service.logEvent('app_open');
      await service.setCurrentScreen('home');
      await service.setUserProperty('cohort', 'a');
      // Reaching here without throwing is the assertion.
    });
  });

  group('FirebaseAnalyticsService', () {
    late _FakeAnalyticsGateway gateway;
    late FirebaseAnalyticsService service;

    setUp(() {
      gateway = _FakeAnalyticsGateway();
      service = FirebaseAnalyticsService(gateway);
    });

    test('logEvent forwards name and parameters to the gateway', () async {
      await service.logEvent('checkin_resolved', parameters: {'exercise': 'squat'});

      expect(gateway.calls.single.method, 'logEvent');
      expect(gateway.calls.single.args['name'], 'checkin_resolved');
      expect(gateway.calls.single.args['parameters'], {'exercise': 'squat'});
    });

    test('setCurrentScreen forwards to the gateway', () async {
      await service.setCurrentScreen('home');

      expect(gateway.calls.single.args['screenName'], 'home');
    });

    test('setUserProperty forwards to the gateway', () async {
      await service.setUserProperty('cohort', 'a');

      expect(gateway.calls.single.args, {'name': 'cohort', 'value': 'a'});
    });

    test('a gateway failure on logEvent is swallowed, never thrown', () async {
      gateway.throwOn = 'logEvent';

      await expectLater(service.logEvent('app_open'), completes);
      expect(gateway.calls, isEmpty);
    });

    test('a gateway failure on setUserProperty is swallowed, never thrown', () async {
      gateway.throwOn = 'setUserProperty';

      await expectLater(service.setUserProperty('cohort', 'a'), completes);
    });
  });
}
