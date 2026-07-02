// import 'package:chack_chack/employer/crews/widgets/RInfoSectionCard.dart';
// import 'package:flutter/material.dart';
//
// import 'bottom_sheets/EmploymentStatusBottomSheet.dart';
// import 'bottom_sheets/EmploymentYearMonthBottomSheet.dart';
// import 'bottom_sheets/TagBottomSheet.dart';
// import 'bottom_sheets/WorkDaysBottomSheet.dart';
// import 'bottom_sheets/WorkingTimeBottomSheet.dart';
// import 'model/RCrewModel.dart';
//
//
// class RCrewDetailPage extends StatefulWidget {
//
//   final RCrewModel crew;
//
//   const RCrewDetailPage({
//     super.key,
//     required this.crew,
//   });
//
//   @override
//   State<RCrewDetailPage> createState() => _RCrewDetailPageState();
// }
//
// class _RCrewDetailPageState extends State<RCrewDetailPage> {
//
//   bool isEditMode = false;
//
//   /// API 연동 시 서버에서 받아올 태그 목록
//   /// 전달받은 근무자의 태그를 저장할 리스트
//   List<String> crewTags = [];
//
//   final TextEditingController tagController = TextEditingController();
//
//   // 나중에 API 응답으로 교체
//   // crewTags = response.tags;
//
//
//   late DateTime employmentDate;
//
//   late String employmentStatus;
//
//   late TimeOfDay workingStartTime;
//   late TimeOfDay workingEndTime;
//
//   late List<String> workingDays;
//
//
//   @override
//   void initState() {
//     super.initState();
//
//     // RCrewPage에서 전달받은 태그를 복사
//     crewTags = List<String>.from(widget.crew.tags);
//
//     // TODO: API 연동 시 서버에서 받은 값으로 변경
//     // 더미데이터
//     employmentDate = DateTime(2026, 4, 1);
//
//     // api
//     // employmentDate = DateTime(
//     //   response.year,
//     //   response.month,
//     //   response.day,
//     // );
//
//     //혹은
//     // employmentDate = DateTime.parse(response.joinDate);
//
//     employmentStatus = "재직중";
//
//     // 더미 데이터 (API 연동 시 서버 값으로 변경)
//     workingStartTime = const TimeOfDay(hour: 9, minute: 0);
//     workingEndTime = const TimeOfDay(hour: 14, minute: 0);
//
//     // 더미 데이터 (API 연동 시 서버 값으로 변경)
//     workingDays = ["월요일", "수요일", "금요일"];
//     // 아무것도 선택되지 않은 상태로 시작하고 싶다면
//     // workingDays = [];
//     // api 연동 시
//     // workingDays = response.workingDays;
//   }
//
//
//   Future<void> _showTagBottomSheet() async {
//     await showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(24),
//         ),
//       ),
//       builder: (_) {
//         return TagBottomSheet(
//           initialTags: crewTags,
//           onSave: (tags) {
//             setState(() {
//               crewTags = List<String>.from(tags);
//               widget.crew.tags = List<String>.from(tags);
//             });
//
//             // API 연동 시
//             // await api.updateCrewTags(tags);
//           },
//         );
//       },
//     );
//   }
//
//   _showEmploymentYearMonthBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (_) => EmploymentYearMonthBottomSheet(
//         initialYear: employmentDate.year,
//         initialMonth: employmentDate.month,
//         onSave: (date) {
//           setState(() {
//             employmentDate = date;
//           });
//         },
//       ),
//     );
//   }
//
//   void _showEmploymentStatusBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => EmploymentStatusBottomSheet(
//         initialStatus: employmentStatus,
//         onSave: (status) {
//           setState(() {
//             employmentStatus = status;
//           });
//         },
//       ),
//     );
//   }
//
//   Future<void> _showWorkingTimeBottomSheet() async {
//     final result = await WorkingTimeBottomSheet.show(
//       context,
//       initialOpenTime: workingStartTime,
//       initialCloseTime: workingEndTime,
//     );
//
//     if (result != null) {
//       setState(() {
//         workingStartTime = result.openTime;
//         workingEndTime = result.closeTime;
//       });
//
//       // API 연동 시
//       // await api.updateWorkingTime(result.openTime, result.closeTime);
//     }
//   }
//
//   Future<void> _showWorkDaysBottomSheet() async {
//     final result = await showModalBottomSheet<List<String>>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => WorkDaysBottomSheet(
//         //initialDays: workingDays,
//         onSave: (days) {
//           setState(() {
//             workingDays = days;
//           });
//
//           // API 연동 시
//           // api.updateWorkingDays(days);
//         },
//       ),
//     );
//
//     if (result != null) {
//       setState(() {
//         workingDays = result;
//       });
//
//       // API 연동 시
//       // await api.updateWorkingDays(result);
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 20, vertical: 30,
//             ),
//
//             child: Column(
//               children: [
//                 /// 상단 헤더
//                 SizedBox(
//                   height: 40,
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       // 가운데 제목
//                       const Center(
//                         child: Text(
//                           "상세 정보",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//
//                       // 왼쪽 뒤로가기
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: GestureDetector(
//                           onTap: () {
//                             Navigator.pop(context, widget.crew);
//                           },
//                           child: const Icon(
//                             Icons.arrow_back_ios_new,
//                             size: 22,
//                           ),
//                         ),
//                       ),
//
//                       // 오른쪽 저장/편집
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               isEditMode = !isEditMode;
//                             });
//                           },
//                           child: isEditMode
//                               ? const Text(
//                             "저장",
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Color(0xFF767676),
//                               fontWeight: FontWeight.w600,
//                             ),
//                           )
//                               : const Icon(
//                             Icons.edit_outlined,
//                             size: 24,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 30),
//
//                 /// 프로필 이미지
//                 Container(width: 80, height: 80,
//                   decoration: BoxDecoration(
//                     color: Color(0xFFA5A5AF),
//                     borderRadius: BorderRadius.circular(24),
//                   ),
//                 ),
//
//                 const SizedBox(height: 18),
//
//                 /// 역할
//                 Text(widget.crew.role,
//                   style: TextStyle(
//                     color: Color(0xFF505050),
//                     fontSize: 15,
//                   ),
//                 ),
//
//                 const SizedBox(height: 6),
//
//                 /// 이름 + 상태
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       widget.crew.name,
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//
//                     const SizedBox(width: 8),
//
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Text(
//                         "재직 중",
//                         style: TextStyle(
//                           color: Color(0xFF00315F),
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 30),
//
//                 /// 개인 정보
//                 RInfoSectionCard(
//                   title: '개인 정보',
//                   isEditMode: isEditMode,
//                   arrowIndexes: const [],
//                   items: [
//                     ['이름', widget.crew.name],
//                     ['휴대폰 번호', '010-1234-5678'],
//                   ],
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 /// 소속 정보
//                 RInfoSectionCard(
//                   title: "소속 정보",
//                   isEditMode: isEditMode,
//                   arrowIndexes: const [1, 2],
//                   onArrowTap: (index) {
//                     if (index == 1) {
//                       // 입사일
//                       _showEmploymentYearMonthBottomSheet();
//                     } else if (index == 2) {
//                       // 재직 상태
//                       _showEmploymentStatusBottomSheet();
//                     }
//                   },
//                   items: [
//                     ["직급", "근무자"],
//                     [
//                       "입사일",
//                       "${employmentDate.year}년 "
//                           "${employmentDate.month}월 "
//                           "${employmentDate.day}일",
//                     ],
//                     ["재직 상태", employmentStatus],
//                   ],
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 /// 근무 정보
//                 RInfoSectionCard(
//                   title: '근무 정보',
//                   isEditMode: isEditMode,
//                   arrowIndexes: const [0, 1],
//                   onArrowTap: (index) {
//                     if (index == 0) {
//                       // 근무 시간
//                       _showWorkingTimeBottomSheet();
//                     } else if (index == 1) {
//                       // 근무 요일
//                       _showWorkDaysBottomSheet();
//                     }
//                   },
//                   items: [
//                     [
//                       '근무 시간',
//                       '오전 ${workingStartTime.hour.toString().padLeft(2, '0')}:'
//                           '${workingStartTime.minute.toString().padLeft(2, '0')}'
//                           ' - '
//                           '오후 ${workingEndTime.hour.toString().padLeft(2, '0')}:'
//                           '${workingEndTime.minute.toString().padLeft(2, '0')}',
//                     ],
//                     [
//                       '근무 요일',
//                       workingDays.isEmpty
//                           ? '-'
//                           : workingDays
//                           .map((e) => e.replaceAll('요일', '')) // 월요일 -> 월
//                           .join(', '),
//                     ],
//                   ],
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 /// 소속 정보
//                 RInfoSectionCard(
//                   title: '소속 정보',
//                   isEditMode: isEditMode,
//                   arrowIndexes: const [],
//                   items: [
//                     ['총 근무 일수', '16일'],
//                     ['총 근무 시간', '80시간'],
//                   ],
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 /// 지난 달 급여 정보
//                 GestureDetector(
//                     onTap: () {},
//
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 18, vertical: 20,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               "지난달 급여 정보",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: isEditMode
//                                     ? Colors.black
//                                     : const Color(0xFF767676),
//                               ),
//                             ),
//                           ),
//                           const Icon(
//                             Icons.chevron_right,
//                             color: Colors.black,
//                           ),
//                         ],
//                       ),
//                     )
//                 ),
//
//                 if (!isEditMode) ...[
//                   const SizedBox(height: 24),
//
//                   SizedBox(
//                     width: double.infinity,
//                     height: 54,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         // 삭제 기능 구현
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF0084FF),
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: const Text(
//                         "근무자 삭제",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }