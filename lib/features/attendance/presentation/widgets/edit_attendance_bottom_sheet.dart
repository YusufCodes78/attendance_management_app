import 'package:attendance_management_app/features/attendance/bloc/attendance_bloc.dart';
import 'package:attendance_management_app/features/attendance/data/models/attendance_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class EditAttendanceBottomSheet extends StatefulWidget {
  const EditAttendanceBottomSheet({super.key, required this.record});

  final AttendanceModel record;

  @override
  State<EditAttendanceBottomSheet> createState() => _EditAttendanceBottomSheetState();
}

class _EditAttendanceBottomSheetState extends State<EditAttendanceBottomSheet> {
  late DateTime checkIn;
  late DateTime checkOut;
  late String status;

  @override
  void initState() {
    super.initState();
    checkIn = widget.record.checkIn;
    checkOut = widget.record.checkOut;
    status = widget.record.status;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 15,
            right: 15,
            top: 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Attendance",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Material(
                child: ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  title: const Text("Check-in Time"),
                  subtitle: Text(DateFormat("hh:mm a").format(checkIn)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(widget.record.checkIn),
                    );
                    if (pickedTime != null) {
                      checkIn = DateTime(
                        widget.record.date.year,
                        widget.record.date.month,
                        widget.record.date.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    }
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 10),
              Material(
                child: ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  title: const Text("Check-out Time"),
                  subtitle: Text(DateFormat("hh:mm a").format(checkOut)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(widget.record.checkOut),
                    );
                    if (pickedTime != null) {
                      checkOut = DateTime(
                        widget.record.date.year,
                        widget.record.date.month,
                        widget.record.date.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    }
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: widget.record.status,
                items: ["Present", "Absent"].map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  status = newValue!;
                  setState(() {});
                },
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(20),
                    labelText: "Status",
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.blue.shade700),
                  minimumSize: WidgetStatePropertyAll(Size(double.infinity, 60)),
                ),
                onPressed: () {
                  context.read<AttendanceBloc>().add(
                        UpdateAttendanceEvent(
                          widget.record.copyWith(
                            checkIn: checkIn,
                            checkOut: checkOut,
                            status: status,
                          ),
                        ),
                      );
                  Navigator.pop(context); // Close BottomSheet
                },
                child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
