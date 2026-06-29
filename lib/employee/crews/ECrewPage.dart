import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/widgets/BottomNavBar.dart';
import '../home/EHomePage.dart';
import '../mypage/EMyPage.dart';
import '../mypage/EProfileEditPage.dart';
import 'EApplicationFormPage.dart';
import 'ECrewDetailPage.dart';
import 'model/ECrewModel.dart';
import 'widgets/ECrewCard.dart';

class ECrewPage extends StatefulWidget {
  const ECrewPage({super.key});

  @override
  State<ECrewPage> createState() => _ECrewPageState();
}

class _ECrewPageState extends State<ECrewPage> {
  String myName = "손흥민";

  @override
  void initState() {
    super.initState();
    _loadMyName();
  }

  Future<void> _loadMyName() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      myName =
          prefs.getString(EProfileEditPage.EkeyName) ?? "손흥민";
    });
  }

  final List<ECrewModel> crews = [
    ECrewModel(
      role: "사장님",
      name: "라이츄",
      tags: [],
    ),
    ECrewModel(
      role: "근무자",
      name: "파이리",
      tags: ["주방", "불뽑기"],
    ),
    ECrewModel(
      role: "근무자",
      name: "꼬부기",
      tags: ["카운터", "물대포"],
    ),
    ECrewModel(
      role: "근무자",
      name: "피존투",
      tags: ["카운터", "피존추"],
    ),
    ECrewModel(
      role: "근무자",
      name: "버터플",
      tags: ["카운터", "주방"],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final myInfo = ECrewModel(
      role: "근무자",
      name: myName,
      isMe: true,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EHomePage(),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ECrewPage(),
              ),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EMyPage(),
              ),
            );
          }
        },
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 제목
              const Text(
                "근무자",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 22),

              /// 교대 근무 신청 카드
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFEEEBFF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFF7D67FD),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "교대 근무 신청하기",
                          style: TextStyle(
                            color: Color(0xFF7D67FD),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade500,
                          size: 22,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        splashRadius: 18,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EApplicationFormPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// 나
              Text(
                "나",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 14),

              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EProfileEditPage(),
                    ),
                  );

                  // 프로필 수정 후 이름 다시 불러오기
                  _loadMyName();
                },
                child: ECrewCard(
                  crew: myInfo,
                  showArrow: false,
                ),
              ),

              const SizedBox(height: 20),

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

              /// 근무자 목록
              Column(
                children: crews.map((crew) {
                  return ECrewCard(
                    crew: crew,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ECrewDetailPage(
                            crew: crew,
                          ),
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