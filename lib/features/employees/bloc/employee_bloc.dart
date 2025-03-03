import 'package:attendance_management_app/core/services/gsheets_repository.dart';
import 'package:attendance_management_app/features/employees/data/models/employee_model.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'employee_event.dart';
part 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final GSheetsRepository gsheetsRepository;

  EmployeeBloc({required this.gsheetsRepository}) : super(EmployeeInitial()) {
    on<FetchEmployeesEvent>((event, emit) async {
      debugPrint("[EmployeeBloc] FetchEmployeesEvent triggered");
      emit(EmployeeLoading());
      try {
        final employees = await gsheetsRepository.fetchEmployees();
        debugPrint("[EmployeeBloc] Employees fetched: ${employees.length}");
        emit(EmployeeLoaded(employees));
      } catch (e) {
        debugPrint("[EmployeeBloc] ERROR fetching employees: $e");
        emit(EmployeeError(e.toString()));
      }
    });

    on<AddEmployeeEvent>((event, emit) async {
      debugPrint("[EmployeeBloc] AddEmployeeEvent triggered for ${event.name}");
      try {
        await gsheetsRepository.addEmployee(event.name);
        debugPrint("[EmployeeBloc] Employee added successfully!");
        add(FetchEmployeesEvent());
      } catch (e) {
        debugPrint("[EmployeeBloc] ERROR adding employee: $e");
        emit(EmployeeError(e.toString()));
      }
    });

    on<RemoveEmployeeEvent>((event, emit) async {
      emit(EmployeeLoading());
      debugPrint("[EmployeeBloc] RemoveEmployeeEvent triggered for ${event.id}");
      try {
        await gsheetsRepository.removeEmployee(event.id);
        debugPrint("[EmployeeBloc] Employee removed successfully!");
        add(FetchEmployeesEvent());
      } catch (e) {
        debugPrint("[EmployeeBloc] ERROR removing employee: $e");
        emit(EmployeeError(e.toString()));
      }
    });
  }
}
