import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/omni_datetime_picker_bloc.dart';
import 'bloc/time_picker_spinner_bloc.dart';

class TimePickerSpinner extends StatelessWidget {
  final String amText;
  final String pmText;
  final bool isShowSeconds;
  final bool is24HourMode;
  final int minutesInterval;
  final int secondsInterval;
  final bool isForce2Digits;
  final bool untilNow;

  final double height;
  final double diameterRatio;
  final double itemExtent;
  final double squeeze;
  final double magnification;
  final bool looping;
  final Widget selectionOverlay;

  const TimePickerSpinner({
    super.key,
    this.height = 200,
    this.diameterRatio = 2,
    this.itemExtent = 40,
    this.squeeze = 1,
    this.magnification = 1.1,
    this.looping = false,
    this.untilNow = false,
    this.selectionOverlay = const CupertinoPickerDefaultSelectionOverlay(),
    required this.amText,
    required this.pmText,
    required this.isShowSeconds,
    required this.is24HourMode,
    required this.minutesInterval,
    required this.secondsInterval,
    required this.isForce2Digits,
  });

  @override
  Widget build(BuildContext context) {
    final datetimeBloc = context.read<OmniDatetimePickerBloc>();

    return BlocConsumer<TimePickerSpinnerBloc, TimePickerSpinnerState>(
      listenWhen: (previous, current) {
        if (previous is TimePickerSpinnerInitial &&
            current is TimePickerSpinnerLoaded) {
          return true;
        }

        return false;
      },
      listener: (context, state) {
        if (state is TimePickerSpinnerLoaded) {
          datetimeBloc.add(UpdateMinute(
              minute: int.parse(state.minutes[state.initialMinuteIndex])));

          datetimeBloc.add(UpdateSecond(
              second: int.parse(state.seconds[state.initialSecondIndex])));
        }
      },
      builder: (context, state) {
        if (state is TimePickerSpinnerLoaded) {
          return SizedBox(
            height: height,
            child: Row(
              textDirection: TextDirection.ltr,
              children: [
                /// Hours
                Expanded(
                  child: CupertinoPicker(
                    scrollController: state.hourController,
                    diameterRatio: diameterRatio,
                    itemExtent: itemExtent,
                    squeeze: squeeze,
                    magnification: magnification,
                    looping: looping,
                    selectionOverlay: selectionOverlay,
                    onSelectedItemChanged: (index) {
                      final datetimeBloc =
                          context.read<OmniDatetimePickerBloc>();
                      final spinnerBloc = context.read<TimePickerSpinnerBloc>();

                      int selectedHour;
                      if (!is24HourMode) {
                        final hourOffset =
                            state.abbreviationController.selectedItem == 1
                                ? 12
                                : 0;
                        selectedHour = index + hourOffset;
                      } else {
                        selectedHour = int.parse(state.hours[index]);
                      }

                      // Aggiorna ora nel bloc principale
                      datetimeBloc.add(UpdateHour(hour: selectedHour));

                      // Ricostruisci la data completa con ora aggiornata ma minuti e secondi attuali
                      final oldDateTime = datetimeBloc.state.dateTime;
                      final updatedDateTime = DateTime(
                        oldDateTime.year,
                        oldDateTime.month,
                        oldDateTime.day,
                        selectedHour,
                        oldDateTime.minute,
                        oldDateTime.second,
                      );

                      // Invio l'evento con la data aggiornata al bloc spinner
                      spinnerBloc.add(UpdateSelectedDateEvent(updatedDateTime));
                    },
                    children: List.generate(
                      growable: false,
                      state.hours.length,
                      (index) {
                        String hour = state.hours[index];

                        if (isForce2Digits) {
                          hour = hour.padLeft(2, '0');
                        }

                        return Center(child: Text(hour));
                      },
                    ),
                  ),
                ),

                /// Minutes
                Expanded(
                  child: CupertinoPicker(
                    scrollController: state.minuteController,
                    diameterRatio: diameterRatio,
                    itemExtent: itemExtent,
                    squeeze: squeeze,
                    magnification: magnification,
                    looping: looping,
                    selectionOverlay: selectionOverlay,
                    onSelectedItemChanged: (index) {
                      datetimeBloc.add(UpdateMinute(
                          minute: int.parse(state.minutes[index])));
                    },
                    children: List.generate(
                      state.minutes.length,
                      (index) {
                        String minute = state.minutes[index];

                        if (isForce2Digits) {
                          minute = minute.padLeft(2, '0');
                        }
                        return Center(child: Text(minute));
                      },
                    ),
                  ),
                ),

                /// Seconds
                if (isShowSeconds)
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: state.initialSecondIndex,
                      ),
                      diameterRatio: diameterRatio,
                      itemExtent: itemExtent,
                      squeeze: squeeze,
                      magnification: magnification,
                      looping: looping,
                      selectionOverlay: selectionOverlay,
                      onSelectedItemChanged: (index) {
                        datetimeBloc.add(UpdateSecond(
                            second: int.parse(state.seconds[index])));
                      },
                      children: List.generate(
                        state.seconds.length,
                        (index) {
                          String second = state.seconds[index];

                          if (isForce2Digits) {
                            second = second.padLeft(2, '0');
                          }

                          return Center(child: Text(second));
                        },
                      ),
                    ),
                  ),

                /// AM/PM
                if (!is24HourMode)
                  Expanded(
                    child: CupertinoPicker.builder(
                      scrollController: state.abbreviationController,
                      diameterRatio: diameterRatio,
                      itemExtent: itemExtent,
                      squeeze: squeeze,
                      magnification: magnification,
                      selectionOverlay: selectionOverlay,
                      onSelectedItemChanged: (index) {
                        if (index == 0) {
                          datetimeBloc
                              .add(const UpdateAbbreviation(isPm: false));
                        } else {
                          datetimeBloc
                              .add(const UpdateAbbreviation(isPm: true));
                        }
                      },
                      childCount: state.abbreviations.length,
                      itemBuilder: (context, index) {
                        return Center(child: Text(state.abbreviations[index]));
                      },
                    ),
                  ),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
