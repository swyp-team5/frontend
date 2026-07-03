// import 'package:flutter/material.dart';
// import 'model/ECrewModel.dart';
//
// class ECrewDetailPage extends StatelessWidget {
//   final ECrewModel crew;
//
//   const ECrewDetailPage({
//     super.key,
//     required this.crew,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isOwner = crew.role == "사장님";
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 24,
//               vertical: 28,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   /// 헤더
//                   SizedBox(
//                     height: 40,
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         const Center(
//                           child: Text(
//                             "상세 정보",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         Align(
//                           alignment: Alignment.centerLeft,
//                           child: InkWell(
//                             onTap: () => Navigator.pop(context),
//                             child: const Icon(Icons.arrow_back_ios_new),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 36),
//
//                   /// 프로필 이미지
//                   /// 프로필 영역
//                   Center(
//                     child: Column(
//                       children: [
//                         /// 프로필 이미지
//                         Container(
//                           width: 80,
//                           height: 80,
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFA5A5AF),
//                             borderRadius: BorderRadius.circular(24),
//                           ),
//                         ),
//
//                         const SizedBox(height: 16),
//
//                         /// 역할
//                         Text(
//                           crew.role,
//                           style: const TextStyle(
//                             color: Color(0xFF505050),
//                             fontSize: 15,
//                           ),
//                         ),
//
//                         const SizedBox(height: 4),
//
//                         /// 이름 + 재직중 뱃지
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               crew.name,
//                               style: const TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//
//                             if (!isOwner) ...[
//                               const SizedBox(width: 8),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 4,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: const Text(
//                                   "재직 중",
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Color(0xFF00315F),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//
//                         /// 태그 (근무자만)
//                         if (!isOwner && crew.tags.isNotEmpty) ...[
//                           const SizedBox(height: 10),
//                           Wrap(
//                             alignment: WrapAlignment.center,
//                             spacing: 8,
//                             runSpacing: 8,
//                             children: crew.tags.map((tag) {
//                               return Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 10,
//                                   vertical: 4,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFFD8EBFF),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Text(
//                                   tag,
//                                   style: const TextStyle(
//                                     color: Color(0xFF0B6FD8),
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 28),
//
//                   /// ---------------- 사장님 ----------------
//                   if (isOwner) ...[
//                     _section(
//                       title: "개인 정보",
//                       children: [
//                         _row("이름", crew.name),
//                         const Divider(color: Color(0xFFF1F1F5),),
//                         _row("휴대폰 번호", "010-1234-5678"),
//                       ],
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     _section(
//                       title: "매장 정보",
//                       children: [
//                         _row("매장 전화번호", "02-1234-5678"),
//                       ],
//                     ),
//                   ]
//
//                   /// ---------------- 근무자 ----------------
//                   else ...[
//                     _section(
//                       title: "개인 정보",
//                       children: [
//                         _row("이름", crew.name),
//                         const Divider(color: Color(0xFFF1F1F5),),
//                         _row("휴대폰 번호", "010-1234-5678"),
//                       ],
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     _section(
//                       title: "소속 정보",
//                       children: [
//                         _row("직급", crew.role),
//                         const Divider(color: Color(0xFFF1F1F5),),
//                         _row("입사일", "2026년 4월 1일"),
//                         const Divider(color: Color(0xFFF1F1F5),),
//                         _row("재직 상태", "재직중"),
//                       ],
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     _section(
//                       title: "근무 정보",
//                       children: [
//                         _row("근무 시간", "오전 09:00 - 오후 14:00"),
//                         const Divider(color: Color(0xFFF1F1F5),),
//                         _row("근무 요일", "월, 수, 금"),
//                       ],
//                     ),
//                   ],
//                 ]
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   static Widget _section({
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 16,
//               color: Color(0xFF505050),
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 20),
//           ...children,
//         ],
//       ),
//     );
//   }
//
//   static Widget _row(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               title,
//               style: const TextStyle(
//                 color: Color(0xFF767676),
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               color: Colors.black,
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }