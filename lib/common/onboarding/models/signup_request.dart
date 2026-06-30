enum SocialProvider {
  GOOGLE,
  KAKAO,
  APPLE,
}

enum WorkPlaceSize {
  ONE_TO_FOUR,
  FIVE_TO_NINE,
  TEN_TO_SEVENTEEN,
  EIGHTEEN_TO_TWENTY_THREE,
  TWENTY_FOUR_OR_MORE,
}


class TermsAgreement {
  final int termsId;
  bool agreed;

  TermsAgreement({
    required this.termsId,
    required this.agreed,
  });

  Map<String, dynamic> toJson() {
    return {
      "termsId": termsId,
      "agreed": agreed,
    };
  }
}

class WorkPlace {
  WorkPlaceSize? size;
  String? name;
  String? roadAddress;
  String? detailAddress;

  WorkPlace({
    this.size,
    this.name,
    this.roadAddress,
    this.detailAddress,
  });

  String? get sizeValue {
    switch (size) {
      case WorkPlaceSize.ONE_TO_FOUR:
        return "ONE_TO_FOUR";
      case WorkPlaceSize.FIVE_TO_NINE:
        return "FIVE_TO_NINE";
      case WorkPlaceSize.TEN_TO_SEVENTEEN:
        return "TEN_TO_SEVENTEEN";
      case WorkPlaceSize.EIGHTEEN_TO_TWENTY_THREE:
        return "EIGHTEEN_TO_TWENTY_THREE";
      case WorkPlaceSize.TWENTY_FOUR_OR_MORE:
        return "TWENTY_FOUR_OR_MORE";
      case null:
        return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "size": sizeValue,
      "name": name,
      "roadAddress": roadAddress,
      "detailAddress": detailAddress,
    };
  }
}

class DeviceModel {
  String? deviceId;
  String? platform;
  String? appVersion;

  DeviceModel({
    this.deviceId,
    this.platform,
    this.appVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      "deviceId": deviceId,
      "platform": platform,
      "appVersion": appVersion,
    };
  }
}

class SignupRequest {
  /// 소셜 로그인
  SocialProvider? provider;

  String? idToken;
  String? accessToken;
  String? authorizationCode;

  /// 공통 회원정보
  String? name;
  String? phoneNumber;

  /// 역할
  bool isEmployer = false;

  /// 약관
  List<TermsAgreement> termsAgreements = [];

  /// 사장님일 경우만 사용
  WorkPlace? workPlace;

  /// 기기 정보
  DeviceModel device = DeviceModel();

  SignupRequest();

  String? get providerValue {
    switch (provider) {
      case SocialProvider.GOOGLE:
        return "GOOGLE";
      case SocialProvider.KAKAO:
        return "KAKAO";
      case SocialProvider.APPLE:
        return "APPLE";
      case null:
        return null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      "provider": providerValue,
      "name": name,
      "phoneNumber": phoneNumber,
      "termsAgreements":
      termsAgreements.map((e) => e.toJson()).toList(),
      "device": device.toJson(),
    };

    if (idToken != null) {
      json["idToken"] = idToken;
    }

    if (accessToken != null) {
      json["accessToken"] = accessToken;
    }

    if (authorizationCode != null) {
      json["authorizationCode"] = authorizationCode;
    }

    if (isEmployer && workPlace != null) {
      json["workPlace"] = workPlace!.toJson();
    }

    return json;
  }
}