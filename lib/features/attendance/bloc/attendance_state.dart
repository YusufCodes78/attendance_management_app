part of 'attendance_bloc.dart';

@immutable
sealed class AttendanceState {}

final class AttendanceInitial extends AttendanceState {}

final class AttendanceLoading extends AttendanceState {}

final class AttendanceLoaded extends AttendanceState {
  final List<AttendanceModel> attendances;

  AttendanceLoaded({required this.attendances});
}

final class AttendanceError extends AttendanceState {
  final String message;
  AttendanceError({required this.message});
}
