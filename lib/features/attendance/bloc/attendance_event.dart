part of 'attendance_bloc.dart';

@immutable
sealed class AttendanceEvent {}

class FetchAttendanceEvent extends AttendanceEvent {
  final DateTime date;

  FetchAttendanceEvent(this.date);
}

class UpdateAttendanceEvent extends AttendanceEvent {
  final AttendanceModel attendance;

  UpdateAttendanceEvent(this.attendance);
}
