import 'package:flutter/material.dart';

class ShiftInfo {
  String name;
  TimeOfDay startTime;
  TimeOfDay endTime;
  String breakTime; // "없음", "30분", "1시간" 등
  int requiredWorkers;

  ShiftInfo({
    this.name = "",
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    this.breakTime = "없음",
    this.requiredWorkers = 1,
  })  : startTime = startTime ?? const TimeOfDay(hour: 0, minute: 0),
        endTime = endTime ?? const TimeOfDay(hour: 0, minute: 0);

  ShiftInfo copyWith({
    String? name,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? breakTime,
    int? requiredWorkers,
  }) {
    return ShiftInfo(
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      breakTime: breakTime ?? this.breakTime,
      requiredWorkers: requiredWorkers ?? this.requiredWorkers,
    );
  }
}
