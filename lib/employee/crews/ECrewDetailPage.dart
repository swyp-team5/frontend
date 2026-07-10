import 'package:flutter/material.dart';
import 'model/ECrewModel.dart';

class ECrewDetailPage extends StatelessWidget {
  final ECrewModel crew;

  const ECrewDetailPage({
    super.key,
    required this.crew,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 헤더
                  SizedBox(
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Center(
                          child: Text(
                            "상세 정보",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back_ios_new),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  /// 프로필 이미지
                  /// 프로필 영역
                  Center(
                    child: Column(
                      children: [
                        /// 프로필 이미지
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFA5A5AF),
                            borderRadius: BorderRadius.circular(24),
                            image: (crew.profileImageUrl != null &&
                                crew.profileImageUrl!.isNotEmpty)
                                ? DecorationImage(
                              image: NetworkImage(crew.profileImageUrl!),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: (crew.profileImageUrl == null || crew.profileImageUrl!.isEmpty)
                              ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          )
                              : null,
                        ),

                        const SizedBox(height: 16),

                        /// 이름 + 재직중 뱃지
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              crew.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  _section(
                    title: "개인 정보",
                    children: [
                      _row("이름", crew.name),
                      const Divider(color: Color(0xFFF1F1F5),),
                      _row("휴대폰 번호", crew.phoneNumber),
                    ],
                  ),
                ]
            ),
          ),
        ),
      ),
    );
  }

  static Widget _section({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF505050),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  static Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF767676),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}