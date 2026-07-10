import 'package:flutter/material.dart';
import '../model/WorkChangeRequestResponse.dart';
import 'ExchangeConfirmBottomSheet.dart';
import 'SubstituteConfirmBottomSheet.dart';
import '../api/WorkChangeRequestApi.dart';
import '../model/MyWorkSchedule.dart';

class ApplicationSubmitSheets {
  static void showSubstituteConfirm({
    required BuildContext context,
    required MyWorkSchedule mySchedule,
    required String workerName,
    required String reason,
    required VoidCallback onConfirm,
    String myName = "나", // TODO: 로그인 사용자 이름으로 교체
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SubstituteConfirmBottomSheet(
        myName: myName,
        workerName: workerName,
        myDate: "${mySchedule.date.month}월 ${mySchedule.date.day}일",
        myTime: "${mySchedule.startTime} - ${mySchedule.endTime}",
        workerDate: "${mySchedule.date.month}월 ${mySchedule.date.day}일",
        workerTime: "${mySchedule.startTime} - ${mySchedule.endTime}",
        reason: reason,
        onConfirm: onConfirm,
      ),
    );
  }

  static void showExchangeConfirm({
    required BuildContext context,
    required int workPlaceId, // ✅ 추가
    required MyWorkSchedule mySchedule,
    required MyWorkSchedule workerSchedule,
    required String reason,
    required ValueChanged<WorkChangeRequestResponse> onConfirm, // ✅ 타입 변경
    String myName = "나", // TODO: 로그인 사용자 이름으로 교체
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ExchangeConfirmBottomSheet(
        workPlaceId: workPlaceId,
        requestAssignmentId: mySchedule.assignmentId, // ⚠️ 아래 참고
        targetAssignmentId: workerSchedule.assignmentId, // ⚠️ 아래 참고
        myName: myName,
        workerName: workerSchedule.name,
        myDate: "${mySchedule.date.month}월 ${mySchedule.date.day}일",
        workerDate:
        "${workerSchedule.date.month}월 ${workerSchedule.date.day}일",
        myTime: "${mySchedule.startTime} - ${mySchedule.endTime}",
        workerTime:
        "${workerSchedule.startTime} - ${workerSchedule.endTime}",
        reason: reason,
        onConfirm: onConfirm,
      ),
    );
  }
}