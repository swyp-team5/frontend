import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../employee/home/notification/RepresentativeNotice.dart';
import '../notification/api/notice_api.dart';

class RNoticeBanner extends StatefulWidget {
  final int workPlaceId;
  final String accessToken;
  final Dio dio;
  final String title;
  final VoidCallback? onTap;

  const RNoticeBanner({
    super.key,
    required this.workPlaceId,
    required this.accessToken,
    required this.dio,
    this.title = "",
    this.onTap,
  });

  @override
  State<RNoticeBanner> createState() => _RNoticeBannerState();
}

class _RNoticeBannerState extends State<RNoticeBanner> {
  late final NoticeApi _noticeApi;
  late Future<RepresentativeNotice?> _noticeFuture;

  @override
  void initState() {
    super.initState();
    _noticeApi = NoticeApi(widget.dio);
    _noticeFuture = _fetchNotice();
  }

  @override
  void didUpdateWidget(covariant RNoticeBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    // workPlaceId가 바뀌면(매장 변경) 다시 불러오기
    if (oldWidget.workPlaceId != widget.workPlaceId) {
      setState(() {
        _noticeFuture = _fetchNotice();
      });
    }
  }

  Future<RepresentativeNotice?> _fetchNotice() {
    return _noticeApi.getRepresentativeNotice(
      workPlaceId: widget.workPlaceId,
      accessToken: widget.accessToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Text(
              "공지 \t 📌",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FutureBuilder<RepresentativeNotice?>(
                future: _noticeFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text(
                      "공지사항을 불러오는 중...",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Text(
                      "공지사항을 불러올 수 없습니다",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14),
                    );
                  }

                  final notice = snapshot.data;

                  if (notice == null) {
                    return const Text(
                      "등록된 공지가 없습니다",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14),
                    );
                  }

                  return Text(
                    notice.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}