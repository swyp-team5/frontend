import 'package:flutter/material.dart';
import 'ExchangeConfirmBottomSheet.dart';
import 'SubstituteConfirmBottomSheet.dart';
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
        // 대타는 내 근무를 대신하는 것이므로 날짜/시간 동일
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
    String myName = "나", // TODO: 로그인 사용자 이름으로 교체
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ExchangeConfirmBottomSheet(
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