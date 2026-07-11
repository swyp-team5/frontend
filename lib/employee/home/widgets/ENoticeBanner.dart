import 'package:chack_chack/employer/home/notification/RNotificationModel.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../employer/home/notification/api/notice_api.dart';
import '../notification/ENotificationModel.dart';
import '../notification/ENotificationPage.dart';
import '../notification/RepresentativeNotice.dart';

class ENoticeBanner extends StatefulWidget {
  final int workPlaceId;
  final String accessToken;
  final Dio dio;

  const ENoticeBanner({
    super.key,
    required this.workPlaceId,
    required this.accessToken,
    required this.dio,
  });

  @override
  State<ENoticeBanner> createState() => _ENoticeBannerState();
}

class _ENoticeBannerState extends State<ENoticeBanner> {
  late final NoticeApi _noticeApi;
  late Future<RepresentativeNotice?> _noticeFuture;

  @override
  void initState() {
    super.initState();
    _noticeApi = NoticeApi(widget.dio);
    _noticeFuture = _fetchNotice();
  }

  Future<RepresentativeNotice?> _fetchNotice() {
    return _noticeApi.getRepresentativeNotice(
      workPlaceId: widget.workPlaceId,
      accessToken: widget.accessToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "공지",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
              Image.asset(
                "assets/images/pin.png",
                width: 20,
                height: 20,
              ),
            ],
          ),
          const SizedBox(width: 10),

          Expanded(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ENotificationPage(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              child: FutureBuilder<RepresentativeNotice?>(
                future: _noticeFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text(
                      "공지사항을 불러오는 중...",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Text(
                      "공지사항을 불러올 수 없습니다",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    );
                  }

                  final notice = snapshot.data;

                  if (notice == null) {
                    return const Text(
                      "등록된 공지가 없습니다",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    );
                  }

                  return Text(
                    notice.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}