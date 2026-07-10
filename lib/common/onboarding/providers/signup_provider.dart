import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/signup_api.dart';
import '../../auth/model/social_auth_models.dart' as auth;
import '../../auth/server_token_manager.dart';
import '../models/signup_request.dart';
import '../../fcm/FcmSetupService.dart'; // FCM

final signupProvider = StateNotifierProvider<SignupNotifier, SignupRequest>(
  (ref) => SignupNotifier(),
);

class SignupNotifier extends StateNotifier<SignupRequest> {
  SignupNotifier() : super(SignupRequest());

  //----------------------------------------
  // 소셜 로그인
  //----------------------------------------

  void prepareSocialSignup(auth.SocialCredential credential) {
    state = SignupRequest()
      ..provider = switch (credential.provider) {
        auth.SocialAuthProvider.google => SocialProvider.GOOGLE,
        auth.SocialAuthProvider.kakao => SocialProvider.KAKAO,
        auth.SocialAuthProvider.apple => SocialProvider.APPLE,
      }
      ..idToken = credential.idToken
      ..accessToken = credential.accessToken
      ..authorizationCode = credential.authorizationCode
      ..device = DeviceModel(
        deviceId: credential.device.deviceId,
        platform: credential.device.platform,
        appVersion: credential.device.appVersion,
      );
  }

  void setProvider(SocialProvider provider) {
    state.provider = provider;
    state = state;
  }

  void setIdToken(String? token) {
    state.idToken = token;
    state = state;
  }

  void setAccessToken(String? token) {
    state.accessToken = token;
    state = state;
  }

  void setRefreshToken(String? token) {
    state.refreshToken = token;
    state = state;
  }

  void setAuthorizationCode(String? code) {
    state.authorizationCode = code;
    state = state;
  }

  //----------------------------------------
  // 사용자 정보
  //----------------------------------------

  void setName(String name) {
    state.name = name;
    state = state;
  }

  void setPhoneNumber(String phoneNumber) {
    state.phoneNumber = phoneNumber;
    state = state;
  }

  //----------------------------------------
  // 역할
  //----------------------------------------

  void setRole(bool isEmployer) {
    state.isEmployer = isEmployer;

    if (isEmployer && state.workPlace == null) {
      state.workPlace = WorkPlace();
    }

    if (!isEmployer) {
      state.workPlace = null;
    }

    state = state;
  }

  //----------------------------------------
  // 약관
  //----------------------------------------

  void setTerms(List<TermsAgreement> terms) {
    state.termsAgreements = List.from(terms);
    state = state;
  }

  void updateTerm(int termsId, bool agreed) {
    final index = state.termsAgreements.indexWhere((e) => e.termsId == termsId);

    final newList = List<TermsAgreement>.from(state.termsAgreements);

    if (index == -1) {
      newList.add(TermsAgreement(termsId: termsId, agreed: agreed));
    } else {
      newList[index] = TermsAgreement(termsId: termsId, agreed: agreed);
    }

    state.termsAgreements = newList;
    state = state;
  }

  /// 편하게 쓰기 위한 메서드
  void setTermsAgreement(int termsId, bool agreed) {
    updateTerm(termsId, agreed);
  }

  //----------------------------------------
  // 사장님 정보
  //----------------------------------------

  void setWorkPlaceSize(WorkPlaceSize size) {
    state.workPlace ??= WorkPlace();
    state.workPlace!.size = size;
    state = state;
  }

  void setWorkPlaceName(String name) {
    state.workPlace ??= WorkPlace();
    state.workPlace!.name = name;
    state = state;
  }

  void setRoadAddress(String address) {
    state.workPlace ??= WorkPlace();
    state.workPlace!.roadAddress = address;
    state = state;
  }

  void setDetailAddress(String address) {
    state.workPlace ??= WorkPlace();
    state.workPlace!.detailAddress = address;
    state = state;
  }

  //----------------------------------------
  // 디바이스 정보
  //----------------------------------------

  void setDevice({
    required String deviceId,
    required String platform,
    required String appVersion,
  }) {
    state.device
      ..deviceId = deviceId
      ..platform = platform
      ..appVersion = appVersion;

    state = state;
  }

  //----------------------------------------
  // 회원가입
  //----------------------------------------

  Future<bool> signUp() async {
    try {
      final response = state.isEmployer
          ? await SignupApi.ownerSignup(state)
          : await SignupApi.workerSignup(state);

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = result["data"];
        // 서버 응답 구조에 따라 토큰 추출 (data 객체 유무 확인)
        final String? accessToken = data != null
            ? data["accessToken"]
            : result["accessToken"];
        final String? refreshToken = data != null
            ? data["refreshToken"]
            : result["refreshToken"];

        if (accessToken != null && refreshToken != null) {
          // 서버 JWT를 로컬 저장소에 영구 저장
          await ServerTokenManager.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            deviceId: state.device.deviceId!,
          );

          // FCM 토큰 등록 (실패해도 가입 완료 흐름은 계속 진행)
          FcmSetupService.registerCurrentDevice(
            deviceId: state.device.deviceId ?? "",
            platform: state.device.platform ?? "",
            appVersion: state.device.appVersion ?? "",
          );

          return true;
        }
        return false;
      } else {
        print("회원가입 실패: ${result["message"]}");
        return false;
      }
    } catch (e) {
      print("회원가입 오류: $e");
      return false;
    }
  }

  //----------------------------------------
  // 초기화
  //----------------------------------------

  void clear() {
    state = SignupRequest();
  }
}
