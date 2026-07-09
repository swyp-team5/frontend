import 'package:dio/dio.dart';

import '../../../common/auth/server_token_manager.dart';

class CrewInvitationHistoryResponse {
  final List<CrewInvitationHistoryItem> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  CrewInvitationHistoryResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory CrewInvitationHistoryResponse.fromJson(Map<String, dynamic> json) {
    final List items = json['content'] ?? [];
    return CrewInvitationHistoryResponse(
      content: items
          .map(
            (e) =>
                CrewInvitationHistoryItem.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? 20,
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }

  bool get hasNextPage => page + 1 < totalPages;
}

class CrewInvitationHistoryItem {
  final int invitationId;
  final int workPlaceId;
  final String inviteCode;
  final String inviteUrl;
  final String status;
  final DateTime expiresAt;
  final DateTime? usedAt;
  final int? usedByMemberId;
  final String? usedByMemberName;
  final int failedAttemptCount;
  final DateTime createdAt;

  CrewInvitationHistoryItem({
    required this.invitationId,
    required this.workPlaceId,
    required this.inviteCode,
    required this.inviteUrl,
    required this.status,
    required this.expiresAt,
    required this.usedAt,
    required this.usedByMemberId,
    required this.usedByMemberName,
    required this.failedAttemptCount,
    required this.createdAt,
  });

  factory CrewInvitationHistoryItem.fromJson(Map<String, dynamic> json) {
    return CrewInvitationHistoryItem(
      invitationId: json['invitationId'] as int,
      workPlaceId: json['workPlaceId'] as int,
      inviteCode: json['inviteCode']?.toString() ?? '',
      inviteUrl: json['inviteUrl']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      expiresAt: DateTime.parse(json['expiresAt'].toString()),
      usedAt: json['usedAt'] == null
          ? null
          : DateTime.parse(json['usedAt'].toString()),
      usedByMemberId: json['usedByMemberId'] as int?,
      usedByMemberName: json['usedByMemberName']?.toString(),
      failedAttemptCount: json['failedAttemptCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'].toString()),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'ACTIVE':
        return '사용 가능';
      case 'USED':
        return '사용 완료';
      case 'EXPIRED':
        return '만료';
      case 'LOCKED':
        return '잠김';
      case 'CANCELED':
        return '취소됨';
      default:
        return status;
    }
  }
}

class CrewInvitationApi {
  static const _baseUrl = 'https://chackchack.shop';

  final Dio dio;

  CrewInvitationApi({Dio? dio})
    : dio = dio ?? Dio(BaseOptions(baseUrl: _baseUrl));

  Future<CrewInvitationHistoryResponse> getHistory({
    required int workPlaceId,
    required int page,
    int size = 20,
  }) async {
    try {
      final response = await dio.get(
        '/api/work-places/$workPlaceId/crew-invitations',
        queryParameters: {'page': page, 'size': size},
        options: await _authorizationOptions(),
      );

      return CrewInvitationHistoryResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, '초대 이력을 불러오지 못했어요.'));
    }
  }

  Future<void> deleteWorkerCrew({
    required int workPlaceId,
    required int crewId,
  }) async {
    try {
      await dio.delete(
        '/api/work-places/$workPlaceId/crews/$crewId',
        options: await _authorizationOptions(),
      );
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, '근무자 삭제에 실패했어요.'));
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
