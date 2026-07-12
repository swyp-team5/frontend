import 'dart:async';
import 'dart:typed_data';

import 'package:chack_chack/employer/mypage/api/profile_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deleteProfileImage sends bearer DELETE request', () async {
    final adapter = _FakeAdapter((options) {
      expect(options.method, 'DELETE');
      expect(options.path, '/api/members/me/profile-image');
      expect(options.headers['Authorization'], 'Bearer access-token');
      return ResponseBody.fromString('', 204);
    });
    final api = ProfileApi(Dio()..httpClientAdapter = adapter);

    await api.deleteProfileImage(token: 'access-token');

    expect(adapter.callCount, 1);
  });
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
