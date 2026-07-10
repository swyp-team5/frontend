import '../model/WorkChangeTargetsResponse.dart';

/// 교대/대타 각각의 신청 상태(날짜, 근무자, 사유 등)를 담는 모델.
/// 교대/대타 탭 각각에서 사용하는 신청 데이터.
///
/// 기존에는 이 필드들이 `_exchangeSelectedDate` / `_substituteSelectedDate`
/// 처럼 탭마다 두 벌씩 존재했지만, 구조가 완전히 동일하므로 하나의 클래스로
/// 묶고 탭마다 인스턴스만 따로 들고 있는 방식으로 바꿨다.
///
/// EApplicationFormPage에서는 이렇게 사용:
/// ```dart
/// final _exchangeData = ApplicationTabData();
/// final _substituteData = ApplicationTabData();
/// ApplicationTabData get _current => isSubstitute ? _substituteData : _exchangeData;
/// ```
class ApplicationTabData {
  DateTime? selectedDate;
  DateTime? selectedWorkerDate;
  WorkChangeWorker? selectedWorker;
  String? selectedReason;
  String? selectedEtc;
  bool workerConfirmed = false;

  /// [requireWorkerDate] : 교대는 상대 근무자의 근무일도 선택해야 제출 가능하지만,
  /// 대타는 내 근무를 그대로 대신하는 것이라 별도 날짜 선택이 필요 없다.
  bool canSubmit({required bool requireWorkerDate}) {
    final hasSchedule = selectedDate != null;

    final hasWorker = workerConfirmed &&
        selectedWorker != null &&
        (!requireWorkerDate || selectedWorkerDate != null);

    final hasReason = selectedReason != null;

    final hasEtc = selectedReason != "기타" ||
        (selectedEtc != null && selectedEtc!.trim().isNotEmpty);

    return hasSchedule && hasWorker && hasReason && hasEtc;
  }
}