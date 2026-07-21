# Android Social Login Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete Google and Kakao login, signup branching, secure token persistence, and session restoration on Android without restructuring unrelated Flutter screens.

**Architecture:** Provider adapters obtain Google or Kakao credentials, a typed API exchanges them with the backend, and a coordinator returns a navigation-neutral outcome. `ServerTokenManager` remains the compatibility entry point for existing API callers while delegating to secure storage and a refresh implementation that includes `deviceId`; `AuthGate` resolves the initial owner, worker, or onboarding screen.

**Tech Stack:** Flutter, Dart 3.11.1+, Riverpod, `http`, `dio`, `google_sign_in` 6.3.0, `kakao_flutter_sdk_user` 1.10.0, `flutter_secure_storage` 10.3.1, `flutter_test`

## Global Constraints

- Android application ID remains `com.chackchack.service`.
- Android is the verified milestone; shared Dart contracts must remain reusable on iOS.
- Apple login and Apple UI are excluded from this milestone.
- Existing Google SHA-1 and Kakao key-hash registrations remain unchanged.
- Google server client ID is supplied from the `GOOGLE_SERVER_CLIENT_ID`
  environment variable through `--dart-define`.
- The Google server client ID must be included in backend `GOOGLE_CLIENT_IDS`.
- No OAuth client secret, provider token, server token, or raw exception is committed or logged.
- Background is `#FFFFFF`; reference width is 393; horizontal padding is 20.
- Social buttons are 38 px high with 6 px radius.
- Run `flutter upgrade` before Task 1 if `flutter --version` reports Dart below 3.11.1.
- `flutter_secure_storage` 10.3.1 requires Android min SDK 23.
- Preserve existing workplace and crew working-tree changes; every `git add` command is path-scoped.

---

## File Map

**Create**

- `lib/common/auth/model/social_auth_models.dart`: typed provider credentials, backend response, member, and outcomes.
- `lib/common/auth/api/social_auth_api.dart`: `/api/auth/social-login` HTTP client and stable error parsing.
- `lib/common/auth/session/auth_session_store.dart`: secure storage interface and production implementation.
- `lib/common/auth/social/social_identity_provider.dart`: Google/Kakao SDK adapters and device context.
- `lib/common/auth/social/social_auth_coordinator.dart`: provider selection, API exchange, and session persistence.
- `lib/common/auth/auth_gate.dart`: app-start session destination resolver and initial screen.
- `test/common/auth/social_auth_api_test.dart`
- `test/common/auth/server_token_manager_test.dart`
- `test/common/auth/social_auth_coordinator_test.dart`
- `test/common/auth/auth_gate_test.dart`
- `test/common/onboarding/onboarding_bottom_sheet_test.dart`

**Modify**

- `pubspec.yaml`: add secure storage.
- `android/app/build.gradle.kts`: set min SDK 23.
- `android/app/src/main/AndroidManifest.xml`: disable encrypted-storage backup restoration.
- `lib/common/auth/server_token_manager.dart`: secure session and correct refresh contract.
- `lib/common/onboarding/providers/signup_provider.dart`: prepare signup from a social outcome.
- `lib/common/onboarding/OnboardingPage.dart`: open the shared social sheet from both entry points.
- `lib/common/onboarding/OnboardingBottomSheet.dart`: Google/Kakao UI, loading, outcomes, and navigation.
- `lib/main.dart`: start with `AuthGate`.
- `test/widget_test.dart`: keep app smoke test compatible with `AuthGate`.

**Delete after all callers migrate**

- `lib/api/auth_sociallLogin_api.dart`
- `lib/common/login/KakaoLoginService.dart`
- `lib/service/social_login_service.dart`

---

### Task 1: Typed Social Authentication API

**Files:**
- Create: `lib/common/auth/model/social_auth_models.dart`
- Create: `lib/common/auth/api/social_auth_api.dart`
- Test: `test/common/auth/social_auth_api_test.dart`

**Interfaces:**
- Produces: `SocialAuthProvider`, `DevicePayload`, `SocialCredential`, `AuthResponse`, `AuthMember`, `SocialAuthException`
- Produces: `SocialAuthClient.login(SocialCredential credential) -> Future<AuthResponse>`
- Produces: `SocialAuthApi implements SocialAuthClient`

- [ ] **Step 1: Write failing model and API tests**

```dart
import 'package:chack_chack/common/auth/api/social_auth_api.dart';
import 'package:chack_chack/common/auth/model/social_auth_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('parses LOGIN_SUCCESS and member role', () async {
    final api = SocialAuthApi(
      client: MockClient((request) async {
        expect(request.url.path, '/api/auth/social-login');
        expect(request.body, contains('"provider":"GOOGLE"'));
        expect(request.body, contains('"idToken":"google-id-token"'));
        return http.Response(
          '{"status":"LOGIN_SUCCESS","accessToken":"a","refreshToken":"r",'
          '"member":{"memberId":1,"name":"owner","role":"OWNER","status":"ACTIVE"}}',
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final response = await api.login(
      const SocialCredential.google(
        idToken: 'google-id-token',
        device: DevicePayload(
          deviceId: 'device-1',
          platform: 'ANDROID',
          appVersion: '1.0.0',
        ),
      ),
    );

    expect(response.status, AuthStatus.loginSuccess);
    expect(response.member?.role, AuthMemberRole.owner);
  });

  test('parses SIGNUP_REQUIRED without server tokens', () async {
    final api = SocialAuthApi(
      client: MockClient((_) async => http.Response(
            '{"status":"SIGNUP_REQUIRED"}',
            200,
            headers: {'content-type': 'application/json'},
          )),
    );

    final response = await api.login(
      const SocialCredential.kakao(
        accessToken: 'kakao-access-token',
        device: DevicePayload(
          deviceId: 'device-1',
          platform: 'ANDROID',
          appVersion: '1.0.0',
        ),
      ),
    );

    expect(response.status, AuthStatus.signupRequired);
    expect(response.accessToken, isNull);
  });

  test('uses backend message for a failed request', () async {
    final api = SocialAuthApi(
      client: MockClient((_) async => http.Response(
            '{"code":"4002","message":"Google 인증 정보가 올바르지 않습니다."}',
            401,
          )),
    );

    await expectLater(
      api.login(
        const SocialCredential.google(
          idToken: 'invalid',
          device: DevicePayload(
            deviceId: 'device-1',
            platform: 'ANDROID',
            appVersion: '1.0.0',
          ),
        ),
      ),
      throwsA(
        isA<SocialAuthException>().having(
          (e) => e.message,
          'message',
          'Google 인증 정보가 올바르지 않습니다.',
        ),
      ),
    );
  });
}
```

- [ ] **Step 2: Run tests and verify RED**

Run:

```powershell
flutter test --no-pub test/common/auth/social_auth_api_test.dart
```

Expected: FAIL because the model and API files do not exist.

- [ ] **Step 3: Implement models and request serialization**

Implement these exact public shapes:

```dart
enum SocialAuthProvider { google, kakao }
enum AuthStatus { loginSuccess, signupRequired }
enum AuthMemberRole { owner, worker }

class DevicePayload {
  final String deviceId;
  final String platform;
  final String appVersion;
  const DevicePayload({
    required this.deviceId,
    required this.platform,
    required this.appVersion,
  });
  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'platform': platform,
        'appVersion': appVersion,
      };
}

class SocialCredential {
  final SocialAuthProvider provider;
  final String? idToken;
  final String? accessToken;
  final DevicePayload device;

  const SocialCredential.google({
    required String idToken,
    required this.device,
  })  : provider = SocialAuthProvider.google,
        idToken = idToken,
        accessToken = null;

  const SocialCredential.kakao({
    required String accessToken,
    required this.device,
  })  : provider = SocialAuthProvider.kakao,
        idToken = null,
        accessToken = accessToken;

  Map<String, dynamic> toJson() => {
        'provider': provider.name.toUpperCase(),
        if (idToken != null) 'idToken': idToken,
        if (accessToken != null) 'accessToken': accessToken,
        'device': device.toJson(),
      };
}

class AuthMember {
  final int memberId;
  final String name;
  final AuthMemberRole role;
  final String status;
  const AuthMember({
    required this.memberId,
    required this.name,
    required this.role,
    required this.status,
  });
}

class AuthResponse {
  final AuthStatus status;
  final String? accessToken;
  final String? refreshToken;
  final AuthMember? member;

  const AuthResponse.loginSuccess({
    required String accessToken,
    required String refreshToken,
    required AuthMember member,
  })  : status = AuthStatus.loginSuccess,
        accessToken = accessToken,
        refreshToken = refreshToken,
        member = member;

  const AuthResponse.signupRequired()
      : status = AuthStatus.signupRequired,
        accessToken = null,
        refreshToken = null,
        member = null;
}
```

Add strict `AuthResponse.fromJson` parsing. Require tokens and `member` only for
`LOGIN_SUCCESS`; permit their absence for `SIGNUP_REQUIRED`.

Define:

```dart
abstract class SocialAuthClient {
  Future<AuthResponse> login(SocialCredential credential);
}
```

Implement `SocialAuthApi implements SocialAuthClient` with an injected
`http.Client`, base URL defaulting to `https://chackchack.shop`, UTF-8 JSON
headers, and `SocialAuthException` that uses `message` from non-2xx JSON or
`소셜 로그인에 실패했어요.`.

- [ ] **Step 4: Run the focused tests and verify GREEN**

```powershell
flutter test --no-pub test/common/auth/social_auth_api_test.dart
```

Expected: all tests in the file pass.

- [ ] **Step 5: Commit Task 1**

```powershell
git add -- lib/common/auth/model/social_auth_models.dart lib/common/auth/api/social_auth_api.dart test/common/auth/social_auth_api_test.dart
git commit -m "feat: 소셜 인증 API 모델 추가"
```

---

### Task 2: Secure Session Storage and Correct Refresh

**Files:**
- Create: `lib/common/auth/session/auth_session_store.dart`
- Modify: `lib/common/auth/server_token_manager.dart`
- Modify: `pubspec.yaml`
- Modify: `android/app/build.gradle.kts`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `lib/common/onboarding/OnboardingBottomSheet.dart`
- Modify: `lib/common/onboarding/providers/signup_provider.dart`
- Test: `test/common/auth/server_token_manager_test.dart`

**Interfaces:**
- Produces: `AuthSession`, `AuthSessionStore`, `SecureAuthSessionStore`
- Produces: `TokenRefreshClient.refresh(String refreshToken, String deviceId)`
- Produces: `AuthSessionSaver.saveSession(AuthSession session)`
- Produces: instance `ServerTokenManager.resolveValidAccessToken()`
- Preserves: static `saveTokens`, `getAccessToken`, `getRefreshToken`, `getValidAccessToken`, `clear`
- Adds: required `deviceId` to `saveTokens`
- Adds: `ServerTokenManager.roleFromToken(String token) -> AuthMemberRole?`

- [ ] **Step 1: Align the SDK and add secure storage**

```powershell
flutter --version
flutter pub add flutter_secure_storage:^10.3.1
```

Expected: Dart is at least 3.11.1 and dependency resolution succeeds.

Set:

```kotlin
minSdk = 23
```

Add to the Android `<application>` element:

```xml
android:allowBackup="false"
```

- [ ] **Step 2: Write failing token-manager tests**

Use an in-memory `AuthSessionStore` and fake `TokenRefreshClient`. Cover:

```dart
test('refresh sends refreshToken and deviceId', () async {
  final expiredAccessToken = jwt(
    role: 'OWNER',
    expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
  );
  final validOwnerAccessToken = jwt(
    role: 'OWNER',
    expiresAt: DateTime.now().add(const Duration(minutes: 30)),
  );
  final store = MemoryAuthSessionStore(
    AuthSession(
      accessToken: expiredAccessToken,
      refreshToken: 'refresh-1',
      deviceId: 'device-1',
    ),
  );
  final refreshClient = FakeTokenRefreshClient(
    onRefresh: (refreshToken, deviceId) async {
      expect(refreshToken, 'refresh-1');
      expect(deviceId, 'device-1');
      return RefreshTokens(
        accessToken: validOwnerAccessToken,
        refreshToken: 'refresh-2',
      );
    },
  );

  final manager = ServerTokenManager(
    store: store,
    refreshClient: refreshClient,
  );
  expect(await manager.resolveValidAccessToken(), validOwnerAccessToken);
  expect((await store.read())?.refreshToken, 'refresh-2');
});

test('failed refresh clears auth session only', () async {
  SharedPreferences.setMockInitialValues({'selectedWorkPlaceId': 7});
  final store = MemoryAuthSessionStore(
    AuthSession(
      accessToken: jwt(
        role: 'OWNER',
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      refreshToken: 'invalid-refresh',
      deviceId: 'device-1',
    ),
  );
  final manager = ServerTokenManager(
    store: store,
    refreshClient: FailingTokenRefreshClient(),
  );

  expect(await manager.resolveValidAccessToken(), isNull);
  expect(await store.read(), isNull);
  final preferences = await SharedPreferences.getInstance();
  expect(preferences.getInt('selectedWorkPlaceId'), 7);
});

class MemoryAuthSessionStore implements AuthSessionStore {
  AuthSession? session;
  MemoryAuthSessionStore(this.session);

  @override
  Future<AuthSession?> read() async => session;

  @override
  Future<void> write(AuthSession value) async {
    session = value;
  }

  @override
  Future<void> clear() async {
    session = null;
  }
}

class FakeTokenRefreshClient implements TokenRefreshClient {
  final Future<RefreshTokens> Function(String, String) onRefresh;
  FakeTokenRefreshClient({required this.onRefresh});

  @override
  Future<RefreshTokens> refresh(
    String refreshToken,
    String deviceId,
  ) {
    return onRefresh(refreshToken, deviceId);
  }
}

class FailingTokenRefreshClient implements TokenRefreshClient {
  @override
  Future<RefreshTokens> refresh(
    String refreshToken,
    String deviceId,
  ) async {
    throw Exception('refresh rejected');
  }
}

String jwt({required String role, required DateTime expiresAt}) {
  String encode(Map<String, Object> value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${encode({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${encode({
        'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
        'role': role,
        'typ': 'ACCESS',
      })}.signature';
}
```

Import `dart:convert` and `shared_preferences`. No signature verification is
needed for client-side expiry/routing tests.

- [ ] **Step 3: Run tests and verify RED**

```powershell
flutter test --no-pub test/common/auth/server_token_manager_test.dart
```

Expected: FAIL because session abstractions and corrected refresh do not exist.

- [ ] **Step 4: Implement secure session storage**

Use these contracts:

```dart
class AuthSession {
  final String accessToken;
  final String refreshToken;
  final String deviceId;
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.deviceId,
  });
}

abstract class AuthSessionStore {
  Future<AuthSession?> read();
  Future<void> write(AuthSession session);
  Future<void> clear();
}

abstract class AuthSessionSaver {
  Future<void> saveSession(AuthSession session);
}

class RefreshTokens {
  final String accessToken;
  final String refreshToken;
  const RefreshTokens({
    required this.accessToken,
    required this.refreshToken,
  });
}

abstract class TokenRefreshClient {
  Future<RefreshTokens> refresh(String refreshToken, String deviceId);
}
```

`SecureAuthSessionStore` stores exactly these keys with
`FlutterSecureStorage(aOptions: AndroidOptions())`:

```text
server_access_token
server_refresh_token
server_device_id
```

Never call `deleteAll`; delete only the three authentication keys.

Implement `DioTokenRefreshClient` with an injected `Dio`. It posts
`refreshToken` plus `deviceId` to `/api/auth/token/refresh`.

Refactor `ServerTokenManager implements AuthSessionSaver` to accept
`AuthSessionStore` and `TokenRefreshClient`, rotate both tokens, and preserve
static wrappers for existing callers. `clear()` clears only the authentication
store.

Update the two existing `saveTokens` callers in `OnboardingBottomSheet.dart`
and `signup_provider.dart` in this task so the required `deviceId` argument does
not leave the app in a non-compiling state.

- [ ] **Step 5: Run focused and existing storage tests**

```powershell
flutter test --no-pub test/common/auth/server_token_manager_test.dart test/common/selected_work_place_storage_test.dart test/widget_test.dart
```

Expected: all tests pass and selected workplace storage remains independent.

- [ ] **Step 6: Commit Task 2**

```powershell
git add -- pubspec.yaml pubspec.lock android/app/build.gradle.kts android/app/src/main/AndroidManifest.xml lib/common/auth/session/auth_session_store.dart lib/common/auth/server_token_manager.dart lib/common/onboarding/OnboardingBottomSheet.dart lib/common/onboarding/providers/signup_provider.dart test/common/auth/server_token_manager_test.dart
git commit -m "feat: 인증 세션을 안전하게 저장"
```

---

### Task 3: Provider Adapters and Authentication Coordinator

**Files:**
- Create: `lib/common/auth/social/social_identity_provider.dart`
- Create: `lib/common/auth/social/social_auth_coordinator.dart`
- Test: `test/common/auth/social_auth_coordinator_test.dart`

**Interfaces:**
- Consumes: `SocialCredential`, `SocialAuthClient`, `AuthSessionSaver`
- Produces: `SocialIdentityProvider.authenticate()`
- Produces: `SocialAuthFlow.authenticate(SocialAuthProvider provider)`
- Produces: `SocialAuthCoordinator.authenticate(SocialAuthProvider provider)`
- Produces: `SocialAuthOutcome.loginSuccess`, `.signupRequired`, `.cancelled`

- [ ] **Step 1: Write failing coordinator tests with fakes**

```dart
test('LOGIN_SUCCESS persists server session', () async {
  final sessionSaver = FakeSessionSaver();
  final coordinator = SocialAuthCoordinator(
    providers: {
      SocialAuthProvider.google: FakeProvider(googleCredential),
    },
    api: FakeAuthClient(ownerLoginResponse),
    sessionSaver: sessionSaver,
  );

  final outcome =
      await coordinator.authenticate(SocialAuthProvider.google);

  expect(outcome.type, SocialAuthOutcomeType.loginSuccess);
  expect(outcome.member?.role, AuthMemberRole.owner);
  expect(sessionSaver.savedDeviceId, 'device-1');
});

test('SIGNUP_REQUIRED returns provider credential without saving tokens',
    () async {
  final sessionSaver = FakeSessionSaver();
  final coordinator = SocialAuthCoordinator(
    providers: {
      SocialAuthProvider.kakao: FakeProvider(kakaoCredential),
    },
    api: FakeAuthClient(signupRequiredResponse),
    sessionSaver: sessionSaver,
  );

  final outcome =
      await coordinator.authenticate(SocialAuthProvider.kakao);

  expect(outcome.type, SocialAuthOutcomeType.signupRequired);
  expect(outcome.credential, kakaoCredential);
  expect(sessionSaver.saveCount, 0);
});

test('provider cancellation does not call backend', () async {
  final provider = FakeProvider(null);
  final api = FakeAuthClient(ownerLoginResponse);
  final coordinator = SocialAuthCoordinator(
    providers: {SocialAuthProvider.google: provider},
    api: api,
    sessionSaver: FakeSessionSaver(),
  );

  final outcome =
      await coordinator.authenticate(SocialAuthProvider.google);

  expect(outcome.type, SocialAuthOutcomeType.cancelled);
  expect(api.callCount, 0);
});

const googleCredential = SocialCredential.google(
  idToken: 'google-id-token',
  device: DevicePayload(
    deviceId: 'device-1',
    platform: 'ANDROID',
    appVersion: '1.0.0',
  ),
);

const kakaoCredential = SocialCredential.kakao(
  accessToken: 'kakao-access-token',
  device: DevicePayload(
    deviceId: 'device-1',
    platform: 'ANDROID',
    appVersion: '1.0.0',
  ),
);

const ownerLoginResponse = AuthResponse.loginSuccess(
  accessToken: 'server-access',
  refreshToken: 'server-refresh',
  member: AuthMember(
    memberId: 1,
    name: 'owner',
    role: AuthMemberRole.owner,
    status: 'ACTIVE',
  ),
);

const signupRequiredResponse = AuthResponse.signupRequired();

class FakeProvider implements SocialIdentityProvider {
  final SocialCredential? result;
  FakeProvider(this.result);

  @override
  Future<SocialCredential?> authenticate() async => result;
}

class FakeAuthClient implements SocialAuthClient {
  final AuthResponse response;
  int callCount = 0;
  FakeAuthClient(this.response);

  @override
  Future<AuthResponse> login(SocialCredential credential) async {
    callCount += 1;
    return response;
  }
}

class FakeSessionSaver implements AuthSessionSaver {
  int saveCount = 0;
  String? savedDeviceId;

  @override
  Future<void> saveSession(AuthSession session) async {
    saveCount += 1;
    savedDeviceId = session.deviceId;
  }
}
```

Create fresh `FakeAuthClient` and `FakeSessionSaver` instances in each test.

- [ ] **Step 2: Run tests and verify RED**

```powershell
flutter test --no-pub test/common/auth/social_auth_coordinator_test.dart
```

Expected: FAIL because providers, outcomes, and coordinator do not exist.

- [ ] **Step 3: Implement device context and provider adapters**

`DeviceContextProvider.load()` uses `device_info_plus` and
`package_info_plus`, returning `ANDROID` or `IOS`.

Google configuration:

```dart
const googleServerClientId =
    String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

GoogleSignIn(
  scopes: const ['email'],
  serverClientId:
      googleServerClientId.isEmpty ? null : googleServerClientId,
);
```

If `GOOGLE_SERVER_CLIENT_ID` is empty, throw a configuration exception before
opening the SDK. A null `signIn()` result is cancellation.

Kakao tries `loginWithKakaoTalk()` when installed, then falls back to
`loginWithKakaoAccount()`. Return cancellation only when either:

```dart
error is KakaoClientException &&
    error.reason == ClientErrorCause.cancelled
```

or:

```dart
error is KakaoAuthException &&
    error.error == AuthErrorCause.accessDenied
```

Rethrow every other SDK failure as a sanitized provider exception.

- [ ] **Step 4: Implement coordinator outcomes**

Define:

```dart
enum SocialAuthOutcomeType {
  loginSuccess,
  signupRequired,
  cancelled,
}

class SocialAuthOutcome {
  final SocialAuthOutcomeType type;
  final AuthMember? member;
  final SocialCredential? credential;

  const SocialAuthOutcome.loginSuccess(AuthMember member)
      : type = SocialAuthOutcomeType.loginSuccess,
        member = member,
        credential = null;

  const SocialAuthOutcome.signupRequired(SocialCredential credential)
      : type = SocialAuthOutcomeType.signupRequired,
        member = null,
        credential = credential;

  const SocialAuthOutcome.cancelled()
      : type = SocialAuthOutcomeType.cancelled,
        member = null,
        credential = null;
}

abstract class SocialAuthFlow {
  Future<SocialAuthOutcome> authenticate(SocialAuthProvider provider);
}
```

`SocialAuthCoordinator implements SocialAuthFlow` and must:

1. Ask the selected adapter for a credential containing device data.
2. Return `cancelled` when the adapter returns null.
3. Call the typed backend API.
4. Save access token, refresh token, and credential device ID only for
   `LOGIN_SUCCESS`.
5. Return the original credential only for `SIGNUP_REQUIRED`.

- [ ] **Step 5: Run focused tests**

```powershell
flutter test --no-pub test/common/auth/social_auth_coordinator_test.dart test/common/auth/social_auth_api_test.dart
```

Expected: all tests pass.

- [ ] **Step 6: Commit Task 3**

```powershell
git add -- lib/common/auth/social/social_identity_provider.dart lib/common/auth/social/social_auth_coordinator.dart test/common/auth/social_auth_coordinator_test.dart
git commit -m "feat: 구글 카카오 인증 흐름 통합"
```

---

### Task 4: Signup Handoff

**Files:**
- Modify: `lib/common/onboarding/providers/signup_provider.dart`
- Test: `test/common/onboarding/signup_provider_test.dart`

**Interfaces:**
- Consumes: `SocialCredential`
- Produces: `SignupNotifier.prepareSocialSignup(SocialCredential credential)`
- Preserves: existing `SignupNotifier.signUp()`

- [ ] **Step 1: Write failing signup handoff tests**

```dart
const googleCredential = SocialCredential.google(
  idToken: 'google-id-token',
  device: DevicePayload(
    deviceId: 'device-1',
    platform: 'ANDROID',
    appVersion: '1.0.0',
  ),
);

const kakaoCredential = SocialCredential.kakao(
  accessToken: 'kakao-access-token',
  device: DevicePayload(
    deviceId: 'device-1',
    platform: 'ANDROID',
    appVersion: '1.0.0',
  ),
);

test('prepares Google signup without server tokens', () {
  final notifier = SignupNotifier();
  notifier.prepareSocialSignup(googleCredential);

  expect(notifier.state.provider, SocialProvider.GOOGLE);
  expect(notifier.state.idToken, 'google-id-token');
  expect(notifier.state.accessToken, isNull);
  expect(notifier.state.device.deviceId, 'device-1');
});

test('prepares Kakao signup and clears stale Google state', () {
  final notifier = SignupNotifier();
  notifier.prepareSocialSignup(googleCredential);
  notifier.prepareSocialSignup(kakaoCredential);

  expect(notifier.state.provider, SocialProvider.KAKAO);
  expect(notifier.state.idToken, isNull);
  expect(notifier.state.accessToken, 'kakao-access-token');
});
```

- [ ] **Step 2: Run test and verify RED**

```powershell
flutter test --no-pub test/common/onboarding/signup_provider_test.dart
```

Expected: FAIL because `prepareSocialSignup` does not exist.

- [ ] **Step 3: Implement a single atomic signup preparation method**

Create a fresh `SignupRequest`, map provider credentials, copy device values,
and publish a new state object. Do not mutate and republish the old object.

Update successful signup token persistence:

```dart
await ServerTokenManager.saveTokens(
  accessToken: accessToken,
  refreshToken: refreshToken,
  deviceId: state.device.deviceId!,
);
```

Retain existing owner/worker signup endpoints and screens.

- [ ] **Step 4: Run signup tests**

```powershell
flutter test --no-pub test/common/onboarding/signup_provider_test.dart
```

Expected: all tests pass.

- [ ] **Step 5: Commit Task 4**

```powershell
git add -- lib/common/onboarding/providers/signup_provider.dart test/common/onboarding/signup_provider_test.dart
git commit -m "feat: 신규 소셜 사용자를 회원가입에 연결"
```

---

### Task 5: App-Start Authentication Gate

**Files:**
- Create: `lib/common/auth/auth_gate.dart`
- Modify: `lib/main.dart`
- Test: `test/common/auth/auth_gate_test.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes: `ServerTokenManager.getValidAccessToken()`
- Produces: `AuthDestinationResolver.resolve() -> Future<AuthDestination>`
- Produces: `AuthGate`

- [ ] **Step 1: Write failing resolver tests**

```dart
final validOwnerAccessToken = jwt(
  role: 'OWNER',
  expiresAt: DateTime.now().add(const Duration(minutes: 30)),
);
final validWorkerAccessToken = jwt(
  role: 'WORKER',
  expiresAt: DateTime.now().add(const Duration(minutes: 30)),
);

test('missing token resolves onboarding', () async {
  final resolver = AuthDestinationResolver(
    tokenLoader: () async => null,
  );
  expect(await resolver.resolve(), AuthDestination.onboarding);
});

test('valid OWNER token resolves owner home', () async {
  final resolver = AuthDestinationResolver(
    tokenLoader: () async => validOwnerAccessToken,
  );
  expect(await resolver.resolve(), AuthDestination.ownerHome);
});

test('valid WORKER token resolves worker home', () async {
  final resolver = AuthDestinationResolver(
    tokenLoader: () async => validWorkerAccessToken,
  );
  expect(await resolver.resolve(), AuthDestination.workerHome);
});

String jwt({required String role, required DateTime expiresAt}) {
  String encode(Map<String, Object> value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${encode({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${encode({
        'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
        'role': role,
        'typ': 'ACCESS',
      })}.signature';
}
```

Import `dart:convert` for the JWT fixture helper.

- [ ] **Step 2: Run test and verify RED**

```powershell
flutter test --no-pub test/common/auth/auth_gate_test.dart
```

Expected: FAIL because the gate and destination resolver do not exist.

- [ ] **Step 3: Implement resolver and gate**

`AuthGate` renders a white loading scaffold while resolving, then exactly one
of:

```dart
AuthDestination.onboarding => const OnboardingPage()
AuthDestination.ownerHome => const RHomePage()
AuthDestination.workerHome => const EHomePage()
```

Unknown or missing role resolves onboarding. Change `MyApp.home` to
`const AuthGate()`. Give `MyApp` an optional injected `home` widget so the smoke
test can use `const MyApp(home: SizedBox())` without opening secure storage.

- [ ] **Step 4: Run auth-gate and smoke tests**

```powershell
flutter test --no-pub test/common/auth/auth_gate_test.dart test/widget_test.dart
```

Expected: all tests pass without real secure-storage method-channel calls by
injecting a resolver in widget tests.

- [ ] **Step 5: Commit Task 5**

```powershell
git add -- lib/common/auth/auth_gate.dart lib/main.dart test/common/auth/auth_gate_test.dart test/widget_test.dart
git commit -m "feat: 앱 시작 시 로그인 상태 복원"
```

---

### Task 6: Onboarding Social Login UI and Navigation

**Files:**
- Modify: `lib/common/onboarding/OnboardingPage.dart`
- Modify: `lib/common/onboarding/OnboardingBottomSheet.dart`
- Test: `test/common/onboarding/onboarding_bottom_sheet_test.dart`
- Delete: `lib/api/auth_sociallLogin_api.dart`
- Delete: `lib/common/login/KakaoLoginService.dart`
- Delete: `lib/service/social_login_service.dart`

**Interfaces:**
- Consumes: `SocialAuthCoordinator.authenticate`
- Consumes: `SignupNotifier.prepareSocialSignup`
- Produces: Google/Kakao UI and role-aware navigation

- [ ] **Step 1: Write failing widget tests**

```dart
testWidgets('shows Google and Kakao but not Apple on Android', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: OnboardingBottomSheet(
            coordinator: FakeCoordinator.cancelled(),
          ),
        ),
      ),
    ),
  );

  expect(find.text('카카오로 시작하기'), findsOneWidget);
  expect(find.text('Google로 시작하기'), findsOneWidget);
  expect(find.text('Apple로 시작하기'), findsNothing);
});

testWidgets('prevents duplicate taps while Google login is loading',
    (tester) async {
  final coordinator = CompleterCoordinator();
  await pumpSheet(tester, coordinator);

  await tester.tap(find.text('Google로 시작하기'));
  await tester.tap(find.text('Google로 시작하기'));

  expect(coordinator.callCount, 1);
});

class FakeCoordinator implements SocialAuthFlow {
  final SocialAuthOutcome outcome;
  int callCount = 0;
  FakeCoordinator(this.outcome);

  factory FakeCoordinator.cancelled() =>
      FakeCoordinator(const SocialAuthOutcome.cancelled());

  @override
  Future<SocialAuthOutcome> authenticate(
    SocialAuthProvider provider,
  ) async {
    callCount += 1;
    return outcome;
  }
}

class CompleterCoordinator implements SocialAuthFlow {
  final completer = Completer<SocialAuthOutcome>();
  int callCount = 0;

  @override
  Future<SocialAuthOutcome> authenticate(
    SocialAuthProvider provider,
  ) {
    callCount += 1;
    return completer.future;
  }
}
```

Import `dart:async` for `CompleterCoordinator`.

Add outcome tests using a navigator observer:

- owner login replaces the stack with `RHomePage`.
- worker login replaces the stack with `EHomePage`.
- signup required calls `prepareSocialSignup` and opens `CommonSignUpPage`.
- cancellation keeps the sheet open without a snackbar.
- backend failure shows a sanitized Korean snackbar.

- [ ] **Step 2: Run widget tests and verify RED**

```powershell
flutter test --no-pub test/common/onboarding/onboarding_bottom_sheet_test.dart
```

Expected: FAIL because Google UI and injectable coordinator behavior are absent.

- [ ] **Step 3: Implement the approved UI**

Use stable dimensions:

```dart
const socialButtonHeight = 38.0;
const socialButtonRadius = 6.0;
const horizontalPadding = 20.0;
```

Use `#FEE500` for Kakao, `#FFFFFF` plus a 1 px `#E5E5E5` border for Google,
and existing logo assets. Track one nullable loading provider; all provider
buttons are disabled while non-null.

Both onboarding entry points call one `_showSocialLoginSheet` helper.

For outcomes:

```dart
loginSuccess => Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => roleHome),
  (_) => false,
)
signupRequired => prepare state, then push CommonSignUpPage
cancelled => no navigation and no snackbar
```

Never interpolate raw exception text into UI.

- [ ] **Step 4: Remove migrated duplicate login files**

Run:

```powershell
rg -n "AuthSocialLoginApi|KakaoLoginService|SocialLoginService" lib
```

Expected before deletion: only the old files and migrated imports remain.
Update imports, delete the three old files, and rerun the command.

Expected after deletion: no matches.

- [ ] **Step 5: Run UI and full tests**

```powershell
flutter test --no-pub test/common/onboarding/onboarding_bottom_sheet_test.dart
flutter test --no-pub
```

Expected: all tests pass.

- [ ] **Step 6: Commit Task 6**

```powershell
git add -- lib/common/onboarding/OnboardingPage.dart lib/common/onboarding/OnboardingBottomSheet.dart lib/api/auth_sociallLogin_api.dart lib/common/login/KakaoLoginService.dart lib/service/social_login_service.dart test/common/onboarding/onboarding_bottom_sheet_test.dart
git commit -m "feat: 온보딩에 소셜 로그인 연결"
```

---

### Task 7: Android Configuration and End-to-End Verification

**Files:**
- Modify only if required by verified configuration:
  `android/app/src/main/AndroidManifest.xml`
- Verify: Google Cloud, Kakao Developers, backend runtime environment

**Interfaces:**
- Consumes: `GOOGLE_SERVER_CLIENT_ID`
- Verifies: production endpoint `https://chackchack.shop/api/auth/social-login`

- [ ] **Step 1: Confirm configuration without exposing secrets**

The user confirms:

- Google Android OAuth client uses `com.chackchack.service` and the current
  debug/release SHA-1 values.
- Google Web client ID is included in backend `GOOGLE_CLIENT_IDS`.
- Kakao Android platform uses `com.chackchack.service` and current key hashes.
- Kakao Native App Key matches the existing manifest URL scheme.

Do not request or record a Google client secret.

- [ ] **Step 2: Run static verification**

```powershell
flutter analyze --no-pub
```

Expected: no new `error -` entries. Record existing repository warning/info
count separately.

- [ ] **Step 3: Run the complete automated suite**

```powershell
flutter test --no-pub
```

Expected: all tests pass.

- [ ] **Step 4: Launch the Android emulator**

```powershell
if ([string]::IsNullOrWhiteSpace($env:GOOGLE_SERVER_CLIENT_ID)) {
  throw 'GOOGLE_SERVER_CLIENT_ID must be set to the registered Web OAuth client ID.'
}
flutter run --no-pub --dart-define="GOOGLE_SERVER_CLIENT_ID=$env:GOOGLE_SERVER_CLIENT_ID"
```

The value is the public Web OAuth client ID, not a client secret.

- [ ] **Step 5: Execute the manual matrix**

Verify and record:

```text
Google new user -> CommonSignUpPage
Google existing OWNER -> RHomePage
Google existing WORKER -> EHomePage
Kakao new user -> CommonSignUpPage
Kakao existing OWNER -> RHomePage
Kakao existing WORKER -> EHomePage
Provider cancel -> stays on social sheet, no failure snackbar
Offline -> Korean retry message, no raw exception
App restart with valid token -> matching home
Expired access token -> refresh succeeds with same deviceId
Invalid refresh token -> onboarding; selectedWorkPlaceId remains intact
Android UI -> no Apple button
```

- [ ] **Step 6: Review final diff and generated files**

```powershell
git status --short
git diff --check
git diff --stat
```

Keep plugin registrant and lockfile changes only when required by
`flutter_secure_storage`. Remove transient `android/.kotlin/` cache after
verifying its resolved path is inside `C:\swyp\frontend`.

- [ ] **Step 7: Commit verified configuration changes**

```powershell
git add -- android pubspec.yaml pubspec.lock
git commit -m "chore: 안드로이드 소셜 로그인 설정"
```

Skip this commit when Task 2 already contains every required configuration
change and no files remain for Task 7.
