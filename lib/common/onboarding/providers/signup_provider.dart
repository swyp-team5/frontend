import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/signup_api.dart';
import '../models/signup_request.dart';

final signupProvider =
StateNotifierProvider<SignupNotifier, SignupRequest>(
      (ref) => SignupNotifier(),
);

class SignupNotifier extends StateNotifier<SignupRequest> {
  SignupNotifier() : super(SignupRequest());

  //----------------------------------------
  // 소셜 로그인
  //----------------------------------------

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
    final index = state.termsAgreements.indexWhere(
          (e) => e.termsId == termsId,
    );

    final newList = List<TermsAgreement>.from(state.termsAgreements);

    if (index == -1) {
      newList.add(
        TermsAgreement(
          termsId: termsId,
          agreed: agreed,
        ),
      );
    } else {
      newList[index] = TermsAgreement(
        termsId: termsId,
        agreed: agreed,
      );
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

      print("========== SIGN UP ==========");
      print("REQUEST : ${state.toJson()}");
      print("STATUS  : ${response.statusCode}");
      print("BODY    : ${response.body}");
      print("=============================");

      return response.statusCode == 200 ||
          response.statusCode == 201;
    } catch (e) {
      print(e);
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