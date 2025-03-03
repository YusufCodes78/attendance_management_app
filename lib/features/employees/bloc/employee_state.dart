part of 'employee_bloc.dart';

@immutable
sealed class EmployeeState {}

final class EmployeeInitial extends EmployeeState {}
final class EmployeeLoading extends EmployeeState {}
final class EmployeeLoaded extends EmployeeState {
  final List<EmployeeModel> employees;
  EmployeeLoaded(this.employees);
}
final class EmployeeError extends EmployeeState {
  final String message;
  EmployeeError(this.message);
}
