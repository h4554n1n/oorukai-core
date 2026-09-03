import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oorukai_core/oorukai_core.dart';

class _RecordedCall {
  _RecordedCall(this.method, this.args);
  final String method;
  final Map<String, Object?> args;
}

class _FakeCrashlyticsGateway implements CrashlyticsGateway {
  final calls = <_RecordedCall>[];
  Object? throwOn;

  void _maybeThrow(String method) {
    if (throwOn == method) throw StateError('$method failed');
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    required bool fatal,
  }) async {
    _maybeThrow('recordError');
    calls.add(_RecordedCall('recordError', {
      'error': error,
      'stackTrace': stackTrace,
      'reason': reason,
      'fatal': fatal,
    }));
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    _maybeThrow('recordFlutterError');
    calls.add(_RecordedCall('recordFlutterError', {'details': details}));
  }

  @override
  Future<void> log(String message) async {
    _maybeThrow('log');
    calls.add(_RecordedCall('log', {'message': message}));
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    _maybeThrow('setCustomKey');
    calls.add(_RecordedCall('setCustomKey', {'key': key, 'value': value}));
  }
}

void main() {
  group('NoopCrashReportingService', () {
    test('every method completes without touching any gateway', () async {
      const service = NoopCrashReportingService();

      await service.recordError(Exception('boom'), StackTrace.current);
      await service.recordFlutterError(FlutterErrorDetails(exception: Exception('boom')));
      await service.log('breadcrumb');
      await service.setCustomKey('level', 3);
      // Reaching here without throwing is the assertion.
    });
  });

  group('FirebaseCrashReportingService', () {
    late _FakeCrashlyticsGateway gateway;
    late FirebaseCrashReportingService service;

    setUp(() {
      gateway = _FakeCrashlyticsGateway();
      service = FirebaseCrashReportingService(gateway);
    });

    test('recordError forwards to the gateway', () async {
      final error = Exception('boom');
      final stack = StackTrace.current;

      await service.recordError(error, stack, reason: 'unit test', fatal: true);

      expect(gateway.calls, hasLength(1));
      expect(gateway.calls.single.method, 'recordError');
      expect(gateway.calls.single.args['error'], error);
      expect(gateway.calls.single.args['fatal'], true);
    });

    test('recordFlutterError forwards to the gateway', () async {
      final details = FlutterErrorDetails(exception: Exception('boom'));

      await service.recordFlutterError(details);

      expect(gateway.calls.single.method, 'recordFlutterError');
    });

    test('log forwards to the gateway', () async {
      await service.log('user tapped start');

      expect(gateway.calls.single.args['message'], 'user tapped start');
    });

    test('setCustomKey forwards to the gateway', () async {
      await service.setCustomKey('level', 7);

      expect(gateway.calls.single.args, {'key': 'level', 'value': 7});
    });

    test('a gateway failure on recordError is swallowed, never thrown', () async {
      gateway.throwOn = 'recordError';

      await expectLater(
        service.recordError(Exception('boom'), null),
        completes,
      );
    });

    test('a gateway failure on log is swallowed, never thrown', () async {
      gateway.throwOn = 'log';

      await expectLater(service.log('breadcrumb'), completes);
    });
  });
}
