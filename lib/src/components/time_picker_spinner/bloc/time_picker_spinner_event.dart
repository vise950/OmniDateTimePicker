part of 'time_picker_spinner_bloc.dart';

sealed class TimePickerSpinnerEvent extends Equatable {
  const TimePickerSpinnerEvent();

  @override
  List<Object> get props => [];
}

final class Initialize extends TimePickerSpinnerEvent {}

final class UpdateSelectedDateEvent extends TimePickerSpinnerEvent {
  final DateTime selectedDate;

  const UpdateSelectedDateEvent(this.selectedDate);
}
