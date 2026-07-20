import 'dart:convert';
import 'dart:typed_data';

import 'package:chack_chack/common/auth/server_token_manager.dart';
import 'package:chack_chack/common/auth/session/auth_session_store.dart';
import 'package:chack_chack/employee/schedule/api/MyConfirmedSchedulesApi.dart';
import 'package:chack_chack/employee/schedule/api/WeeklyWorkersApi.dart';
import 'package:chack_chack/employee/schedule/api/employee_schedule_error.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('my schedule request uses the authorized Dio', () async {
    final harness = _authorizedHarness((options) {
      expect(options.method, 'GET');
      expect(options.path, '/api/me/confirmed-schedules');
      expect(options.headers['Authorization'], startsWith('Bearer '));
      return _jsonResponse({
        'from': '2026-07-20',
        'to': '2026-07-26',
        'schedules': <Object>[],
      });
    });
    final api = MyConfirmedSchedulesApi(dio: harness.dio);

    final response = await api.getMyConfirmedSchedules(
      from: DateTime(2026, 7, 20),
      to: DateTime(2026, 7, 26),
    );

    expect(response.schedules, isEmpty);
    expect(harness.adapter.callCount, 1);
  });

  test('weekly workers request uses the authorized Dio', () async {
    final harness = _authorizedHarness((options) {
      expect(options.method, 'GET');
      expect(
        options.path,
        '/api/work-places/7/confirmed-schedules/weekly-workers',
      );
      expect(options.headers['Authorization'], startsWith('Bearer '));
      return _jsonResponse({
        'workPlaceId': 7,
        'weekStartDate': '2026-07-20',
        'weekEndDate': '2026-07-26',
        'days': <Object>[],
      });
    });
    final api = WeeklyWorkersApi(dio: harness.dio);

    final response = await api.getWeeklyWorkers(
      workPlaceId: 7,
      weekStartDate: DateTime(2026, 7, 20),
    );

    expect(response.days, isEmpty);
    expect(harness.adapter.callCount, 1);
  });

  test('schedule API hides raw server error messages', () async {
    final adapter = _FakeAdapter(
      (_) => ResponseBody.fromString(
        '{"message":"internal authentication details"}',
        500,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      ),
    );
    final api = MyConfirmedSchedulesApi(
      dio: Dio()..httpClientAdapter = adapter,
    );

    await expectLater(
      api.getMyConfirmedSchedules(
        from: DateTime(2026, 7, 20),
        to: DateTime(2026, 7, 26),
      ),
      throwsA(
        isA<EmployeeScheduleException>()
            .having(
              (error) => error.message,
              'message',
              '내 근무표를 불러오지 못했어요. 잠시 후 다시 시도해주세요.',
            )
            .having(
              (error) => error.toString(),
              'toString',
              isNot(contains('internal authentication details')),
            ),
      ),
    );
  });

  test('unknown schedule errors use a safe fallback message', () {
    expect(
      employeeScheduleErrorMessage(Exception('인증 토큰이 유효하지 않습니다.')),
      '근무표를 불러오지 못했어요. 잠시 후 다시 시도해주세요.',
    );
  });
}

_AuthorizedHarness _authorizedHarness(
  ResponseBody Function(RequestOptions options) handler,
) {
  final adapter = _FakeAdapter(handler);
  final dio = Dio()..httpClientAdapter = adapter;
  final manager = ServerTokenManager(
    store: _MemoryAuthSessionStore(
      AuthSession(
        accessToken: _jwt(DateTime.now().add(const Duration(minutes: 30))),
        refreshToken: 'refresh-token',
        deviceId: 'device-1',
      ),
    ),
  );
  return _AuthorizedHarness(manager.createAuthorizedDio(dio: dio), adapter);
}

ResponseBody _jsonResponse(Map<String, Object> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

class _AuthorizedHarness {
  final Dio dio;
  final _FakeAdapter adapter;

  const _AuthorizedHarness(this.dio, this.adapter);
}

class _FakeAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions options) handler;
  int callCount = 0;

  _FakeAdapter(this.handler);

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount += 1;
    return handler(options);
  }
}

class _MemoryAuthSessionStore implements AuthSessionStore {
  AuthSession? session;

  _MemoryAuthSessionStore(this.session);

  @override
  Future<void> clear() async => session = null;

  @override
  Future<AuthSession?> read() async => session;

  @override
  Future<void> write(AuthSession value) async => session = value;
}

String _jwt(DateTime expiresAt) {
  String encode(Map<String, Object> value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');

  return '${encode({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${encode({'exp': expiresAt.millisecondsSinceEpoch ~/ 1000, 'role': 'WORKER', 'typ': 'ACCESS'})}.signature';
}
