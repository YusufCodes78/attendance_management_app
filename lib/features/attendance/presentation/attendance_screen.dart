import 'package:attendance_management_app/features/attendance/data/models/attendance_model.dart';
import 'package:attendance_management_app/features/attendance/presentation/widgets/attendance_tile.dart';
import 'package:attendance_management_app/features/attendance/presentation/widgets/edit_attendance_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/attendance_bloc.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  AttendanceScreenState createState() => AttendanceScreenState();
}

class AttendanceScreenState extends State<AttendanceScreen> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      context.read<AttendanceBloc>().add(FetchAttendanceEvent(selectedDate));
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(FetchAttendanceEvent(selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(15),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Date: ${DateFormat('dd-MM-yyyy').format(selectedDate)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    )),
                onPressed: () => _selectDate(context),
                child: const Text("Select Date", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(child: BlocBuilder<AttendanceBloc, AttendanceState>(builder: (context, state) {
            if (state is AttendanceLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AttendanceLoaded) {
              final attendances = state.attendances;
              return attendances.isEmpty
                  ? const Center(child: Text("No attendance records found"))
                  : ListView.separated(
                      separatorBuilder: (context, index) => const SizedBox(height: 5),
                      itemCount: attendances.length,
                      itemBuilder: (context, index) {
                        final record = attendances[index];
                        return AttendanceTile(
                          employeeName: record.employeeName,
                          checkIn: DateFormat('hh:mm a').format(record.checkIn),
                          checkOut: DateFormat('hh:mm a').format(record.checkOut),
                          overtime: record.overtime,
                          status: record.status,
                          onEdit: () {
                            _showEditAttendanceSheet(context, record);
                          },
                        );
                      },
                    );
            } else if (state is AttendanceError) {
              return Center(child: Text("No records found"));
            }
            return const Center(child: Text("No records found"));
          }))
        ]));
  }

  void _showEditAttendanceSheet(BuildContext context, AttendanceModel record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return EditAttendanceBottomSheet(record: record);
      },
    );
  }
}
