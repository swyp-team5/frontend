import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../../common/auth/server_token_manager.dart';
import '../../crews/model/WorkChangeRequestResponse.dart';

/// GET /api/work-places/{workPlaceId}/work-change-requests?scope=SENT&page=0&size=20
/// 페이지 응답 래퍼
class WorkChangeRequestPage {
  final List<WorkChangeRequestResponse> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  WorkChangeRequestPage({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory WorkChangeRequestPage.fromJson(Map<String, dynamic> json) {
    return WorkChangeRequestPage(
      content: (json['content'] as List<dynamic>)
          .map((e) =>
          WorkChangeRequestResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      size: json['size'] as int,
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

class WorkChangeRequestListApi {
  static const String _baseUrl = "https://chackchack.shop";

  final Dio _dio = Dio(
    BaseOptions(baseUrl: _baseUrl),
  );

  /// scope: "SENT"(내가 보낸 요청) | "RECEIVED"(내가 받은 요청) 등
  Future<WorkChangeRequestPage> fetchRequests({
    required int workPlaceId,
    String scope = "SENT",
    int page = 0,
    int size = 20,
  }) async {
    final token = await ServerTokenManager.getValidAccessToken();

    if (token == null) {
      throw Exception("로그인 정보가 만료되었습니다. 다시 로그인해주세요.");
    }

    try {
      final response = await _dio.get(
        "/api/work-places/$workPlaceId/work-change-requests",
        queryParameters: {
          "scope": scope,
          "page": page,
          "size": size,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      debugPrint(
        "[WorkChangeRequestListApi] GET ${response.requestOptions.uri} "
            "-> ${response.data}",
      );

      return WorkChangeRequestPage.fromJson(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map && data["message"] != null)
          ? data["message"].toString()
          : "대타/교대 신청 목록 조회에 실패했습니다.";
      throw Exception(message);
    }
  }

  /// 전용 상세 조회 API가 없다는 가정 하에, 목록에서 id로 필터링해서 찾는 헬퍼.
  /// (상세 API가 따로 있다면 이 메서드는 삭제하고 그걸 바로 쓰는 게 낫습니다)
  Future<WorkChangeRequestResponse?> fetchRequestById({
    required int workPlaceId,
    required int workChangeRequestId,
    String scope = "SENT",
  }) async {
    final result = await fetchRequests(
      workPlaceId: workPlaceId,
      scope: scope,
      page: 0,
      size: 100,
    );

    for (final item in result.content) {
      if (item.workChangeRequestId == workChangeRequestId) {
        return item;
      }
    }
    return null;
  }
}