# Social Login Design

## Context

The Flutter app already has onboarding screens, Kakao and Google packages,
signup screens, and a backend social-login endpoint. The current flow is
incomplete:

- Kakao always opens signup even when the backend returns login tokens.
- Google UI is commented out.
- Provider SDK calls and backend calls are duplicated across two services.
- The app always starts on onboarding and does not restore a valid session.
- Token refresh omits the required `deviceId`.
- Clearing authentication currently clears every SharedPreferences value.

The backend contract is:

- `POST /api/auth/social-login`
- `GOOGLE` sends `idToken`.
- `KAKAO` sends `accessToken`.
- `LOGIN_SUCCESS` returns server tokens and `member.role`.
- `SIGNUP_REQUIRED` returns no server tokens and continues signup.

## Goals

- Complete Google and Kakao social login on Android.
- Preserve the current onboarding and signup design with minimal file churn.
- Route existing users to the owner or worker home.
- Route new social users into the existing signup flow.
- Restore valid sessions after app restart.
- Make the shared Dart authentication layer reusable by the iOS developer.
- Keep OAuth configuration and token values out of logs and source control.

## Non-Goals

- Apple login implementation or UI exposure in this Android milestone.
- A global navigation rewrite or `go_router` migration.
- Backend authentication API changes.
- Re-registering existing Google SHA-1 or Kakao key hashes.

Apple UI remains hidden until the iOS provider is implemented and verified on
macOS.

## Architecture

Authentication is split into focused units:

1. Provider adapters obtain provider credentials.
   - Google returns an ID token.
   - Kakao returns an access token.
   - A future Apple adapter can return an ID token and authorization code.
2. A typed authentication API sends provider credentials and device data to
   the backend.
3. An authentication coordinator owns loading, cancellation, backend status
   branching, session persistence, and navigation results.
4. A session store owns server access token, refresh token, and the device ID
   used to create the refresh-token session.
5. An app-start authentication gate restores a valid session or shows
   onboarding.

Existing callers continue to use `ServerTokenManager`; its internals and
contract are corrected rather than forcing unrelated API files to change.

## Login Flow

### Existing Member

1. The user taps Google or Kakao.
2. The provider adapter obtains the provider token.
3. The coordinator calls `/api/auth/social-login`.
4. The backend returns `LOGIN_SUCCESS`.
5. The app stores server access token, refresh token, and device ID.
6. `member.role` determines the destination:
   - `OWNER` -> `RHomePage`
   - `WORKER` -> `EHomePage`
7. Navigation removes onboarding and signup routes.

### New Member

1. The backend returns `SIGNUP_REQUIRED`.
2. No server token is saved.
3. Provider credentials and device data are copied into `signupProvider`.
4. The existing `CommonSignUpPage` and role-specific signup screens continue.
5. Successful signup stores the server session and opens the matching home.

## Session Restoration

The app does not treat token presence alone as authentication.

1. Missing access token -> onboarding.
2. Present and unexpired access token -> decode the JWT `role` claim and open
   the matching home.
3. Expired access token with refresh token and device ID -> call token refresh.
4. Refresh success -> replace both rotated tokens and restore the home.
5. Refresh failure -> remove authentication keys only and show onboarding.

The refresh request includes both `refreshToken` and `deviceId`, matching the
backend contract. Selected workplace and other unrelated preferences survive
authentication failure.

Server tokens are stored with `flutter_secure_storage`. Device metadata that is
not secret may use preferences, but it remains behind the session-store
interface.

## UI

The existing onboarding page and social-login bottom sheet are retained.
`회원가입 바로가기` and `바로 시작하기` open the same social entry sheet; the
backend status decides whether the result is login or signup.

Reference layout:

- Background: `#FFFFFF`
- Reference width: 393
- Horizontal padding: 20
- Four page dots: active `#0084FF`, inactive `#D9D9D9`
- Title: 24 px, weight 700, `#111111`
- Preview image: maximum 260 x 250, `BoxFit.contain`
- Description: 14 px, weight 600
- Social button height: 38
- Social button radius: 6
- Kakao background: `#FEE500`
- Google background: `#FFFFFF`
- Google border: 1 px `#E5E5E5`
- Apple styling is reserved for the later iOS implementation.

Buttons show a provider-specific loading state and reject duplicate taps while
authentication is running.

## Error Handling

- User cancellation closes the provider flow without an error snackbar.
- Network and backend failures show a Korean backend message when safe, or a
  stable fallback message.
- Raw exceptions, OAuth tokens, and server tokens are never displayed or
  logged.
- Missing OAuth configuration has a distinct developer diagnostic while the
  user receives a safe retry message.
- A failed login does not mutate signup state or an existing valid session.

## OAuth Configuration

- Android application ID: `com.chackchack.service`
- Existing Google Android OAuth registration and SHA-1 remain unchanged.
- Existing Kakao application, package registration, and key hash remain
  unchanged.
- Kakao Native App Key remains the registered public app identifier.
- Google server client ID is supplied as a build configuration value and must
  match one of the backend `GOOGLE_CLIENT_IDS` audiences.
- No OAuth client secret is stored in the Flutter repository.

## Testing

Automated tests cover:

- Authentication response parsing for both statuses.
- Google and Kakao request payload selection.
- Existing-member and signup-required coordinator branches.
- Owner and worker destination selection.
- Access-token expiry and JWT role extraction.
- Refresh requests including the stored device ID.
- Refresh failure clearing only authentication keys.
- Provider cancellation and duplicate-tap behavior.
- Android hiding Apple and rendering Google/Kakao buttons.
- App-start session restoration.

Manual Android emulator verification covers:

- New Google user -> signup.
- Existing Google owner and worker -> matching home.
- New Kakao user -> signup.
- Existing Kakao owner and worker -> matching home.
- App restart with valid access token.
- Expired access token refresh.
- Provider cancellation and offline/server-error behavior.

## Acceptance Criteria

- Google and Kakao login work against `https://chackchack.shop`.
- Existing members never enter signup after `LOGIN_SUCCESS`.
- New members never receive or persist server tokens before signup succeeds.
- App restart restores an authenticated session when tokens are valid or
  refreshable.
- Android does not display Apple login.
- Authentication errors do not expose credentials.
- Relevant Flutter tests pass and static analysis introduces no new errors.
- The iOS developer can add native provider configuration without changing the
  shared backend response, coordinator, or session contracts.
