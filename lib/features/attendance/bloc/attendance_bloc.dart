import 'package:attendance_management_app/core/services/gsheets_repository.dart';
import 'package:attendance_management_app/features/attendance/data/models/attendance_model.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final GSheetsRepository gsheetsRepository;

  AttendanceBloc({required this.gsheetsRepository}) : super(AttendanceInitial()) {
    on<FetchAttendanceEvent>((event, emit) async {
      debugPrint("[AttendanceBloc] FetchAttendanceEvent triggered for date: ${event.date}");
      emit(AttendanceLoading());
      try {
        List<AttendanceModel> records = await gsheetsRepository.fetchAttendanceRecords(event.date);
        if (records.isEmpty) {
          debugPrint("[AttendanceBloc] No attendance found, fetching employees...");
          final employees = await gsheetsRepository.fetchEmployees();
          records = employees
              .where((emp) => emp.isActive)
              .map((employee) => AttendanceModel(
                    date: event.date,
                    employeeName: employee.name,
                    checkIn: DateTime(event.date.year, event.date.month, event.date.day, 9, 0),
                    checkOut: DateTime(event.date.year, event.date.month, event.date.day, 18, 0),
                    status: "Present",
                    overtime: "0h",
                  ))
              .toList();
          await gsheetsRepository.saveDefaultAttendanceRecords(records);
          debugPrint("[AttendanceBloc] Default records saved to Google Sheets.");
        }
        debugPrint("[AttendanceBloc] Attendance records fetched: ${records.length}");
        emit(AttendanceLoaded(attendances: records));
      } catch (e) {
        debugPrint("[AttendanceBloc] ERROR fetching attendance: $e");
        emit(AttendanceError(message: e.toString()));
      }
    });
    on<UpdateAttendanceEvent>((event, emit) async {
      debugPrint("[AttendanceBloc] UpdateAttendanceEvent triggered for date: ${event.attendance.date}");
      emit(AttendanceLoading());
      try {
        await gsheetsRepository.updateAttendanceRecord(event.attendance);
        debugPrint("[AttendanceBloc] Attendance record updated successfully!");
        add(FetchAttendanceEvent(event.attendance.date));
      } catch (e) {
        debugPrint("[AttendanceBloc] ERROR updating attendance: $e");
        emit(AttendanceError(message: e.toString()));
      }
    });
  }
}
