import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_datetime_picker/src/components/time_picker_spinner/bloc/utils.dart';
import 'package:omni_datetime_picker/src/utils/date_time_extensions.dart';

part 'time_picker_spinner_event.dart';

part 'time_picker_spinner_state.dart';

class TimePickerSpinnerBloc
    extends Bloc<TimePickerSpinnerEvent, TimePickerSpinnerState> {
  final String amText;
  final String pmText;
  final bool isShowSeconds;
  final bool is24HourMode;
  final int minutesInterval;
  final int secondsInterval;
  final bool isForce2Digits;
  final bool untilNow;
  final DateTime firstDateTime;
  final DateTime lastDateTime;
  final DateTime initialDateTime;

  TimePickerSpinnerBloc({
    required this.amText,
    required this.pmText,
    required this.isShowSeconds,
    required this.is24HourMode,
    required this.minutesInterval,
    required this.secondsInterval,
    required this.isForce2Digits,
    required this.untilNow,
    required this.firstDateTime,
    required this.lastDateTime,
    required this.initialDateTime,
  }) : super(TimePickerSpinnerInitial()) {
    on<Initialize>(_initialize);
    on<UpdateSelectedDateEvent>(_onSelectedDateChanged);

    if (state is TimePickerSpinnerInitial) {
      add(Initialize());
    }
  }

  Future<void> _initialize(TimePickerSpinnerEvent event,
      Emitter<TimePickerSpinnerState> emit) async {
    final now = initialDateTime;

    final hours = _generateHours(now);
    final minutes = _generateMinutes(now, now.hour);
    final seconds = _generateSeconds();
    final abbreviations = _generateAbbreviations();

    final initialHourIndex = _getInitialHourIndex(hours: hours, now: now);
    final initialMinuteIndex =
        _getInitialMinuteIndex(minutes: minutes, now: now);
    final initialSecondIndex =
        _getInitialSecondIndex(seconds: seconds, now: now);
    final initialAbbreviationIndex =
        _getInitialAbbreviationIndex(abbreviations: abbreviations, now: now);

    final abbreviationController = FixedExtentScrollController(
      initialItem: initialAbbreviationIndex,
    );

    final hourController = FixedExtentScrollController(
      initialItem: initialHourIndex,
    );

    final minuteController = FixedExtentScrollController(
      initialItem: initialMinuteIndex,
    );

    emit(TimePickerSpinnerLoaded(
      allHours: hours,
      allMinutes: minutes,
      allSeconds: seconds,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      abbreviations: abbreviations,
      initialHourIndex: initialHourIndex,
      initialMinuteIndex: initialMinuteIndex,
      initialSecondIndex: initialSecondIndex,
      initialAbbreviationIndex: initialAbbreviationIndex,
      abbreviationController: abbreviationController,
      hourController: hourController,
      minuteController: minuteController,
    ));
  }

  int _getInitialHourIndex({
    required List<String> hours,
    required DateTime now,
  }) {
    if (!is24HourMode) {
      int hourOfPeriod = TimeOfDay.fromDateTime(now).hourOfPeriod;

      // Ensure 12 AM is displayed as '12' and not '0'
      String hourString = hourOfPeriod == 0 ? '12' : hourOfPeriod.toString();

      return hours.indexWhere((e) => e == hourString);
    }

    return hours.indexWhere((e) => e == now.hour.toString());
  }

  int _getInitialMinuteIndex({
    required List<String> minutes,
    required DateTime now,
  }) {
    final index = findClosestIndex(minutes, now.minute);
    return index;
  }

  int _getInitialSecondIndex({
    required List<String> seconds,
    required DateTime now,
  }) {
    final index = findClosestIndex(seconds, now.second);

    return index;
  }

  int _getInitialAbbreviationIndex({
    required List<String> abbreviations,
    required DateTime now,
  }) {
    if (now.hour >= 12) {
      return 1;
    } else {
      return 0;
    }
  }

  Future<void> _onSelectedDateChanged(UpdateSelectedDateEvent event,
      Emitter<TimePickerSpinnerState> emit) async {
    final currentState = state;
    if (currentState is! TimePickerSpinnerLoaded) return;

    final selectedDate = event.selectedDate;

    final updatedHours = _generateHours(selectedDate);
    final updatedMinutes = _generateMinutes(selectedDate, selectedDate.hour);

    final newHourIndex =
        _getInitialHourIndex(hours: updatedHours, now: selectedDate);
    final newMinuteIndex =
        _getInitialMinuteIndex(minutes: updatedMinutes, now: selectedDate);

    final newHourController =
        FixedExtentScrollController(initialItem: newHourIndex);
    final newMinuteController =
        FixedExtentScrollController(initialItem: newMinuteIndex);

    emit(currentState.copyWith(
      hours: updatedHours,
      minutes: updatedMinutes,
      initialHourIndex: newHourIndex,
      initialMinuteIndex: newMinuteIndex,
      hourController: newHourController,
      minuteController: newMinuteController,
    ));
  }

  List<String> _generateHours(DateTime forDate) {
    final now = DateTime.now();
    final isToday = untilNow && forDate.isSameDate(now);

    final int maxHour = isToday ? now.hour : (is24HourMode ? 23 : 12);

    final List<String> hours = List.generate(
      is24HourMode ? 24 : 12,
      (index) {
        if (!is24HourMode && index == 0) {
          return '12';
        }
        return '$index';
      },
    ).where((h) {
      final parsed = int.tryParse(h) ?? 0;
      return parsed <= maxHour;
    }).toList();

    return hours;
  }

  List<String> _generateMinutes(DateTime forDate, int selectedHour) {
    final now = DateTime.now();
    final isToday = untilNow && forDate.isSameDate(now);

    int maxMinute = 59;

    if (isToday) {
      if (selectedHour == now.hour) {
        maxMinute = now.minute;
      }
    }

    return List.generate(
      (60 / minutesInterval).floor(),
      (index) => '${index * minutesInterval}',
    ).where((minuteStr) {
      final parsed = int.tryParse(minuteStr) ?? 0;
      return parsed <= maxMinute;
    }).toList();
  }

  List<String> _generateSeconds() {
    final List<String> seconds = List.generate(
      (60 / secondsInterval).floor(),
      (index) {
        return '${index * secondsInterval}';
      },
    );
    return seconds;
  }

  List<String> _generateAbbreviations() {
    return [
      amText,
      pmText,
    ];
  }
}
