import 'package:chack_chack/employer/mypage/RMyPage.dart';
import 'package:flutter/material.dart';

import '../../../common/widgets/BottomNavBar.dart';

import '../home/RHomePage.dart';
import 'RCrewDetailPage.dart';
import 'model/RCrewModel.dart';

import 'widgets/RCrewCard.dart';

class RCrewPage extends StatefulWidget {
  const RCrewPage({super.key});

  @override
  State<RCrewPage> createState() => _RCrewPageState();
}

class _RCrewPageState extends State<RCrewPage> {

  final List<CrewModel> crews = [
    CrewModel(
      role: "근무자",
      name: "박지연",
      tags: ["주방", "100만 볼트"],
    ),
    CrewModel(
      role: "근무자",
      name: "파이리",
      tags: ["주방", "불뽑기"],
    ),
    CrewModel(
      role: "근무자",
      name: "꼬부기",
      tags: ["카운터", "물대포"],
    ),
    CrewModel(
      role: "근무자",
      name: "버터플",
      tags: ["카운터", "주방"],
    ),
    CrewModel(
      role: "근무자",
      name: "꼬부기",
      tags: ["야도란", "주방"],
    ),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F5F5),

      /// 공통 BottomNavBar 적용
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RHomePage()));
          } else if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RCrewPage()));
          } else if (index == 4) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const RMyPage()));
          }
        },
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "근무자",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.person_add_alt_1,
                      size: 30,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// 본인이 사장님일 경우
              Text(
                "나",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 14),

              _crewTile(
                role: "사장님",
                name: "손흥민",
                tags: const [],
                showArrow: false,
              ),

              const SizedBox(height: 30),

              /// 근무자 수
              Row(
                children: [
                  const Text(
                    "근무자 ",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${crews.length}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Column(
                children: crews.map((crew) {
                  return RCrewCard(
                    crew: crew,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RCrewDetailPage(),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _crewTile({
  required String role,
  required String name,
  required List<String> tags,
  bool showArrow = true,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      children: [
        /// 프로필
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFD4DCE3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.person,
            color: Color(0xFF7A8795),
            size: 38,
          ),
        ),

        const SizedBox(width: 14),

        /// 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: tags
                      .map(
                        (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8EBFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Color(0xFF0B6FD8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),
              ],
            ],
          ),
        ),

        /// 화살표
        if (showArrow)
          const Icon(
            Icons.chevron_right,
            color: Color(0xFFB8B8BE),
            size: 28,
          ),
      ],
    ),
  );
}