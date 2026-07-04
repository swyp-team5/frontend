import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'RStoreClosePage.dart';

class RRecentSchedulePage extends StatefulWidget {
  const RRecentSchedulePage({super.key});

  @override
  State<RRecentSchedulePage> createState() => _RRecentSchedulePageState();
}

class _RRecentSchedulePageState extends State<RRecentSchedulePage> {
  Map<String, dynamic>? recentSchedule;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentSchedule();
  }

  Future<void> _loadRecentSchedule() async {
    final prefs = await SharedPreferences.getInstance();

    final json = prefs.getString("recent_schedule");

    if (json != null) {
      recentSchedule = jsonDecode(json);
    }

    setState(() {
      isLoading = false;
    });
  }

  /// n번째 주 계산
  String getMonthWeekText() {
    final now = DateTime.now();

    // 이번 달 1일
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    // 1일부터 현재 날짜까지 며칠 지났는지
    final day = now.day;

    // 몇 번째 주인지 계산 (1~7 = 첫째 주, 8~14 = 둘째 주 ...)
    final week = ((day - 1) ~/ 7) + 1;

    const weekNames = ['', '첫째', '둘째', '셋째', '넷째', '다섯째', '여섯째',];

    return '${now.month}월 ${weekNames[week]} 주';
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF767676),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShift(Map<String, dynamic> shift) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F3FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              shift["name"],
              style: const TextStyle(
                color: Color(0xFF0084FF),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.only(left: 12),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Color(0xFFE5E5E5),
                  width: 3,
                ),
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  "타임 운영 시간",
                  "${shift["startTime"]} - ${shift["endTime"]}",
                ),
                _buildInfoRow(
                  "필요 근무자 수",
                  "${shift["requiredWorkers"]}명",
                ),
                _buildInfoRow(
                  "휴게 시간",
                  shift["breakTime"],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 28,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "최근 설정",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            if (recentSchedule == null)
              const Expanded(
                child: Center(
                  child: Text(
                    "최근에 저장된\n기록이 없어요",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF999999),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Text(
                                  getMonthWeekText(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                _buildInfoRow(
                                  "가게 운영 시간",
                                  "${recentSchedule!["openTime"]} - ${recentSchedule!["closeTime"]}",
                                ),

                                _buildInfoRow(
                                  "인원 당 근무 횟수",
                                  "최소 ${recentSchedule!["minWork"]}, 최대 ${recentSchedule!["maxWork"]}",
                                ),

                                const SizedBox(height: 18),
                                const Divider(color: Color(0xFFE5E5EC)),
                                const SizedBox(height: 12),

                                ...((recentSchedule!["registeredSchedules"]
                                as List<dynamic>)
                                    .map((schedule) {
                                  final days =
                                  (schedule["days"] as List).join(", ");

                                  final shifts =
                                  schedule["shifts"] as List<dynamic>;

                                  return Padding(
                                    padding:
                                    const EdgeInsets.only(bottom: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          days,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),

                                        ...shifts.map(
                                              (e) => _buildShift(
                                            Map<String, dynamic>.from(e),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                })),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (_) =>
                            //     const RStoreClosePage(),
                            //   ),
                            // );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFF0084FF),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "불러오기",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}