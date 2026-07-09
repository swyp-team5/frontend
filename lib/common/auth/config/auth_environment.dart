class AuthEnvironment {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://chackchack.shop',
  );

  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  static const kakaoNativeAppKey = String.fromEnvironment(
    'KAKAO_NATIVE_APP_KEY',
  );

  static void validateForRuntime() {
    if (googleServerClientId.isEmpty) {
      throw StateError(
        'GOOGLE_SERVER_CLIENT_ID가 비어 있습니다. '
        'flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=... 로 실행하세요.',
      );
    }

    if (kakaoNativeAppKey.isEmpty) {
      throw StateError(
        'KAKAO_NATIVE_APP_KEY가 비어 있습니다. '
        'flutter run --dart-define=KAKAO_NATIVE_APP_KEY=... 로 실행하세요.',
      );
    }
  }
}