import 'package:flutter/material.dart';

import 'package:chack_chack/employee/crews/model/MyWorkSchedule.dart';
import 'package:chack_chack/employee/crews/widgets/ExchangeConfirmBottomSheet.dart';
import 'package:chack_chack/employee/crews/widgets/SubstituteConfirmBottomSheet.dart';

/// 교대/대타 제출 시 뜨는 확인 바텀시트 호출을 모아둔 헬퍼.
/// EApplicationFormPage의 onSubmit 콜백이 지나치게 비대해지는 것을 막기 위해 분리했다.
class ApplicationSubmitSheets {
  ApplicationSubmitSheets._();

  static void showSubstituteConfirm({
    required BuildContext context,
    required MyWorkSchedule mySchedule,
    required String workerName,
    required String reason,
    required VoidCallback onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SubstituteConfirmBottomSheet(
        myName: "최세중(나)",
        workerName: workerName,
        myDate: "${mySchedule.date.month}월 ${mySchedule.date.day}일",
        myTime: "${mySchedule.startTime} - ${mySchedule.endTime}",
        // 대타는 내 근무를 대신하는 것이므로 날짜/시간도 내 근무와 동일하다.
        workerDate: "${mySchedule.date.month}월 ${mySchedule.date.day}일",
        workerTime: "${mySchedule.startTime} - ${mySchedule.endTime}",
        reason: reason,
        onConfirm: onConfirm,
      ),
    );
  }

  static void showExchangeConfirm({
    required BuildContext context,
    required MyWorkSchedule mySchedule,
    required MyWorkSchedule workerSchedule,
    required String reason,
    required VoidCallback onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ExchangeConfirmBottomSheet(
        myName: "최세중(나)",
        workerName: workerSchedule.name,
        myDate: "${mySchedule.date.month}월 ${mySchedule.date.day}일",
        workerDate: "${workerSchedule.date.month}월 ${workerSchedule.date.day}일",
        myTime: "${mySchedule.startTime} - ${mySchedule.endTime}",
        workerTime: "${workerSchedule.startTime} - ${workerSchedule.endTime}",
        reason: reason,
        onConfirm: onConfirm,
      ),
    );
  }
}