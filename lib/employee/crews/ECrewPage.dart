import 'package:chack_chack/employee/crews/widgets/ECrewCard.dart';
import 'package:flutter/material.dart';

import '../../../common/widgets/BottomNavBar.dart';

import 'model/ECrewModel.dart';

class EmployeeCrewPage extends StatelessWidget {

  const EmployeeCrewPage({super.key});

  @override
  Widget build(BuildContext context) {

    final myInfo = EmployeeCrewModel(
      role: '근무자',
      name: '모수연 (나)',
    );

    final crews = [

      EmployeeCrewModel(
        role: '사장님',
        name: '김나나',
      ),

      EmployeeCrewModel(
        role: '근무자',
        name: '메로나',
      ),

      EmployeeCrewModel(
        role: '근무자',
        name: '윤서준',
      ),

      EmployeeCrewModel(
        role: '근무자',
        name: '김예송',
      ),

      EmployeeCrewModel(
        role: '근무자',
        name: '김상우',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {},
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              const Text(
                '동료',

                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 28),

              /// 교대 근무 신청
              GestureDetector(
                onTap: () {},

                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 26,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius:
                    BorderRadius.circular(24),
                  ),

                  child: Row(
                    children: [

                      const Expanded(
                        child: Text(
                          '교대 근무 신청하기',

                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey.shade600,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              /// 내 정보
              EmployeeCrewCard(
                crew: myInfo,
              ),

              const SizedBox(height: 30),

              Text(
                '내 동료',

                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,

                  itemCount: crews.length,

                  itemBuilder:
                      (context, index) {

                    return EmployeeCrewCard(
                      crew: crews[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}