import 'package:attendance_management_app/features/attendance/data/models/attendance_model.dart';
import 'package:attendance_management_app/features/employees/data/models/employee_model.dart';
import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'package:intl/intl.dart';
import '../services/gsheets_service.dart';

class GSheetsRepository {
  final GSheetsService gsheetsService;
  late Worksheet attendanceSheet;
  late Worksheet employeesSheet;

  GSheetsRepository({required this.gsheetsService});

  Future<void> init() async {
    try {
      debugPrint("[GSheetsRepository] Initializing repository...");
      await gsheetsService.init();
      attendanceSheet = await gsheetsService.getWorksheet('Attendance');
      employeesSheet = await gsheetsService.getWorksheet('Employees');
      debugPrint("[GSheetsRepository] Repository initialized successfully!");
    } catch (e) {
      debugPrint("[GSheetsRepository] ERROR initializing repository: $e");
    }
  }

  // Helper function to convert numeric date from Google Sheets to DateTime.
  DateTime convertSerialDateToDateTime(num serialDate) {
    // Google Sheets dates start at December 30, 1899.
    return DateTime(1899, 12, 30).add(Duration(days: serialDate.toInt()));
  }

// Helper function to convert fractional time to a DateTime on a given date.
  DateTime convertFractionToTime(num fraction, DateTime date) {
    int totalMinutes = (fraction * 24 * 60).round();
    int hour = totalMinutes ~/ 60;
    int minute = totalMinutes % 60;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  Future<List<AttendanceModel>> fetchAttendanceRecords(DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date); // Format date correctly
      debugPrint("[GSheetsRepository] Fetching attendance for date: $dateStr");
      final rows = await attendanceSheet.values.allRows();

      if (rows.isEmpty) {
        debugPrint("[GSheetsRepository] No attendance data found for this date.");
        return [];
      }

      List<AttendanceModel> records = [];
      for (var row in rows.skip(1)) {
        String rowDateStr;
        DateTime dt = convertSerialDateToDateTime(int.parse(row[0]));
        rowDateStr = DateFormat('yyyy-MM-dd').format(dt);
        if (rowDateStr == dateStr) {
          DateTime checkIn;
          checkIn = convertFractionToTime(double.parse(row[2]), date);
          DateTime checkOut;
          checkOut = convertFractionToTime(double.parse(row[3]), date);
          final totalMinutes = checkOut.difference(checkIn).inMinutes;
          final overtimeMinutes = totalMinutes > 540 ? totalMinutes - 540 : 0; // 9 hours = 540 mins
          final overtimeHours = overtimeMinutes ~/ 60;
          final overtimeMins = overtimeMinutes % 60;
          final overtimeStr = (overtimeHours > 0 || overtimeMins > 0) ? "${overtimeHours}h ${overtimeMins}m" : "0h";

          records.add(AttendanceModel(
            date: date,
            employeeName: row[1],
            checkIn: checkIn,
            checkOut: checkOut,
            status: row[4],
            overtime: overtimeStr,
          ));
        }
      }
      debugPrint("[GSheetsRepository] Total records fetched: ${records.length}");
      return records;
    } catch (e) {
      debugPrint("[GSheetsRepository] ERROR fetching attendance records: $e");
      return [];
    }
  }

  Future<void> updateAttendanceRecord(AttendanceModel attendance) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(attendance.date);
      debugPrint("[GSheetsRepository] Updating attendance for ${attendance.employeeName} on $dateStr");

      final rows = await attendanceSheet.values.allRows();
      int? rowIndex;
      int currentIndex = 2;

      for (var row in rows.skip(1)) {
        String rowDateStr;
        DateTime dt = convertSerialDateToDateTime(int.parse(row[0]));
        rowDateStr = DateFormat('yyyy-MM-dd').format(dt);
        if (row.isNotEmpty && dateStr == rowDateStr && row[1] == attendance.employeeName) {
          debugPrint("Row found: ${row[0]} | ${row[1]} | ${row[2]} | ${row[3]} | ${row[4]} | ${row[5]}");
          rowIndex = currentIndex;
          break;
        }
        currentIndex++;
      }

      final totalMinutes = attendance.checkOut.difference(attendance.checkIn).inMinutes;
      final overtimeMinutes = totalMinutes > 540 ? totalMinutes - 540 : 0; // 9 hours = 540 mins
      final overtimeHours = overtimeMinutes ~/ 60;
      final overtimeMins = overtimeMinutes % 60;
      final overtimeStr = (overtimeHours > 0 || overtimeMins > 0) ? "${overtimeHours}h ${overtimeMins}m" : "0h";
      debugPrint("attendance while updating: ${attendance.checkIn} | ${attendance.checkOut} | ${attendance.status} | $overtimeStr");

      debugPrint("[GSheetsRepository] Updating row $rowIndex...");
      await attendanceSheet.values.insertRow(
          rowIndex!,
          [
            dateStr,
            attendance.employeeName,
            DateFormat("HH:mm").format(attendance.checkIn),
            DateFormat("HH:mm").format(attendance.checkOut),
            attendance.status,
            overtimeStr
          ],
          fromColumn: 1);
    } catch (e) {
      debugPrint("[GSheetsRepository] ERROR updating attendance: $e");
    }
  }

  Future<void> saveDefaultAttendanceRecords(List<AttendanceModel> records) async {
    try {
      debugPrint("[GSheetsRepository] Saving default attendance records...");
      for (var record in records) {
        await attendanceSheet.values.appendRow([
          DateFormat('yyyy-MM-dd').format(record.date),
          record.employeeName,
          DateFormat("HH:mm").format(record.checkIn),
          DateFormat("HH:mm").format(record.checkOut),
          record.status,
          record.overtime
        ]);
      }
      debugPrint("[GSheetsRepository] Default attendance records saved successfully!");
    } catch (e) {
      debugPrint("[GSheetsRepository] ERROR saving default records: $e");
    }
  }

  Future<List<EmployeeModel>> fetchEmployees() async {
    try {
      debugPrint("[GSheetsRepository] Fetching employees...");
      final rows = await employeesSheet.values.allRows();
      List<EmployeeModel> employees = [];
      if (rows.isEmpty) {
        debugPrint("[GSheetsRepository] No employees found.");
        return [];
      }
      for (var row in rows.skip(1)) {
        employees.add(EmployeeModel(
          id: row[0],
          name: row[1],
          isActive: row[2].toLowerCase() == 'active',
        ));
      }
      debugPrint("[GSheetsRepository] Total employees fetched: ${employees.length}");
      return employees;
    } catch (e) {
      debugPrint("[GSheetsRepository] ERROR fetching employees: $e");
      return [];
    }
  }

  Future<void> addEmployee(String name) async {
    try {
      debugPrint("[GSheetsRepository] Adding employee: $name");
      final newId = 'EMP${DateTime.now().millisecondsSinceEpoch}';
      await employeesSheet.values.appendRow([newId, name, 'Active']);
      debugPrint("[GSheetsRepository] Employee added successfully!");
    } catch (e) {
      debugPrint("[GSheetsRepository] ERROR adding employee: $e");
    }
  }

  Future<void> removeEmployee(String id) async {
    try {
      debugPrint("[GSheetsRepository] Removing (deactivating) employee: $id");
      final rows = await employeesSheet.values.allRows();
      int? rowIndex;
      int currentIndex = 1;
      for (var row in rows) {
        if (row.isNotEmpty && row[0] == id) {
          rowIndex = currentIndex;
          break;
        }
        currentIndex++;
      }
      if (rowIndex != null) {
        debugPrint("[GSheetsRepository] Deleting row: $rowIndex from Employee sheet");
        await employeesSheet.values.insertValue('Inactive', column: 3, row: rowIndex);
        debugPrint("[GSheetsRepository] Employee removed successfully!");
      } else {
        debugPrint("[GSheetsRepository] Employee ID not found!");
      }
    } catch (e) {
      debugPrint("[GSheetsRepository] ERROR removing employee: $e");
    }
  }
}
