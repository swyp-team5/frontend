import 'package:dio/dio.dart';

import '../../../common/auth/server_token_manager.dart';

class WorkPlaceCreateRequest {
  final String size;
  final String name;
  final String roadAddress;
  final String? detailAddress;
  final String? phoneNumber;

  WorkPlaceCreateRequest({
    required this.size,
    required this.name,
    required this.roadAddress,
    this.detailAddress,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'name': name,
      'roadAddress': roadAddress,
      'detailAddress': detailAddress,
      'phoneNumber': WorkPlaceApi.normalizePhoneNumber(phoneNumber),
    };
  }
}

class WorkPlaceSummary {
  final int workPlaceId;
  final String name;
  final String size;
  final String roadAddress;
  final String? detailAddress;
  final String? phoneNumber;
  final int ownerMemberId;
  final int crewId;
  final String crewRole;
  final String joinStatus;
  final String crewStatus;
  final String workPlaceStatus;

  WorkPlaceSummary({
    required this.workPlaceId,
    required this.name,
    required this.size,
    required this.roadAddress,
    required this.detailAddress,
    required this.phoneNumber,
    required this.ownerMemberId,
    required this.crewId,
    required this.crewRole,
    required this.joinStatus,
    required this.crewStatus,
    required this.workPlaceStatus,
  });

  factory WorkPlaceSummary.fromJson(Map<String, dynamic> json) {
    return WorkPlaceSummary(
      workPlaceId: json['workPlaceId'] as int,
      name: json['name']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      roadAddress: json['roadAddress']?.toString() ?? '',
      detailAddress: json['detailAddress']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      ownerMemberId: json['ownerMemberId'] as int,
      crewId: json['crewId'] as int,
      crewRole: json['crewRole']?.toString() ?? '',
      joinStatus: json['joinStatus']?.toString() ?? '',
      crewStatus: json['crewStatus']?.toString() ?? '',
      workPlaceStatus: json['workPlaceStatus']?.toString() ?? '',
    );
  }

  String get displayPhoneNumber {
    if (phoneNumber == null || phoneNumber!.isEmpty) {
      return '등록된 번호 없음';
    }
    return phoneNumber!;
  }

  String get displayAddress {
    if (detailAddress == null || detailAddress!.isEmpty) {
      return roadAddress;
    }
    return '$roadAddress $detailAddress';
  }
}

class WorkPlaceApi {
  static const _baseUrl = 'https://chackchack.shop';

  final Dio dio;

  WorkPlaceApi({Dio? dio}) : dio = dio ?? Dio(BaseOptions(baseUrl: _baseUrl));

  static String? normalizePhoneNumber(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return null;
    }
    return digits;
  }

  Future<List<WorkPlaceSummary>> getMyWorkPlaces() async {
    try {
      final response = await dio.get(
        '/api/work-places/me',
        options: await _authorizationOptions(),
      );

      final List list = response.data['workPlaces'] ?? [];
      return list
          .map((e) => WorkPlaceSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, '매장 정보를 불러오지 못했어요.'));
    }
  }

  Future<WorkPlaceSummary> createWorkPlace(
    WorkPlaceCreateRequest request,
  ) async {
    try {
      final response = await dio.post(
        '/api/work-places',
        data: request.toJson(),
        options: await _authorizationOptions(),
      );

      return WorkPlaceSummary.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, '매장 추가에 실패했어요.'));
    }
  }

  Future<WorkPlaceSummary> updatePhoneNumber({
    required int workPlaceId,
    required String? phoneNumber,
  }) async {
    try {
      final response = await dio.patch(
        '/api/work-places/$workPlaceId/phone-number',
        data: {'phoneNumber': normalizePhoneNumber(phoneNumber)},
        options: await _authorizationOptions(),
      );

      return WorkPlaceSummary.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, '전화번호 변경에 실패했어요.'));
    }
  }

  Future<Options> _authorizationOptions() async {
    final token = await ServerTokenManager.getValidAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  String _errorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return fallback;
  }
}
