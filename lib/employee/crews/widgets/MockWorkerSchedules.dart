// import 'package:chack_chack/employee/crews/model/MyWorkSchedule.dart';
//
// /// TODO: "근무지 근무자 일정 조회" API 연동 후 이 파일 통째로 제거.
// ///
// /// GET /api/me/confirmed-schedules 는 "내 근무"만 내려주기 때문에,
// /// 교대/대타 상대를 고르는 화면(WorkerSelect)에서 필요한 "동료 근무자 일정"은
// /// 별도 API가 필요하다. 백엔드 확인 후 같은 방식(from/to)으로 연동 예정이라
// /// 그 전까지 쓸 목데이터를 여기 모아둔다.
// class MockWorkerSchedules {
//   MockWorkerSchedules._();
//
//   static const List<String> workerNames = ["윤서준", "김유진"];
//
//   static final List<MyWorkSchedule> worker1 = [
//     MyWorkSchedule(
//       name: "윤서준",
//       date: DateTime(2026, 7, 15),
//       role: "미들",
//       startTime: "12:00",
//       endTime: "16:00",
//     ),
//     MyWorkSchedule(
//       name: "윤서준",
//       date: DateTime(2026, 7, 16),
//       role: "오픈",
//       startTime: "09:00",
//       endTime: "12:00",
//     ),
//     MyWorkSchedule(
//       name: "윤서준",
//       date: DateTime(2026, 7, 17),
//       role: "오픈",
//       startTime: "09:00",
//       endTime: "12:00",
//     ),
//   ];
//
//   static final List<MyWorkSchedule> worker2 = [
//     MyWorkSchedule(
//       name: "김유진",
//       date: DateTime(2026, 7, 14),
//       role: "미들",
//       startTime: "12:00",
//       endTime: "16:00",
//     ),
//     MyWorkSchedule(
//       name: "김유진",
//       date: DateTime(2026, 7, 17),
//       role: "오픈",
//       startTime: "09:00",
//       endTime: "12:00",
//     ),
//     MyWorkSchedule(
//       name: "김유진",
//       date: DateTime(2026, 7, 18),
//       role: "마감",
//       startTime: "16:00",
//       endTime: "20:00",
//     ),
//   ];
//
//   static List<MyWorkSchedule> get all => [...worker1, ...worker2];
// }