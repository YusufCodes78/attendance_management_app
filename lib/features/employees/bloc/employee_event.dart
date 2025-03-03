part of 'employee_bloc.dart';

@immutable
sealed class EmployeeEvent {}

class FetchEmployeesEvent extends EmployeeEvent {}

class AddEmployeeEvent extends EmployeeEvent {
  final String name;
  AddEmployeeEvent(this.name);
}

class RemoveEmployeeEvent extends EmployeeEvent {
  final String id;
  RemoveEmployeeEvent(this.id);
}
