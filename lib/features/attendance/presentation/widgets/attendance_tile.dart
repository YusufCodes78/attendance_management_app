import 'package:flutter/material.dart';

class AttendanceTile extends StatelessWidget {
  const AttendanceTile(
      {super.key,
      required this.employeeName,
      required this.checkIn,
      required this.checkOut,
      required this.overtime,
      required this.status,
      required this.onEdit});
  final String employeeName;
  final String checkIn;
  final String checkOut;
  final String overtime;
  final String status;
  final Function() onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(employeeName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: status == "Present" ? Colors.green : Colors.red.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.calendar_month, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Text("$checkIn - $checkOut", style: TextStyle(color: Colors.grey[700]))
                  ]),
                  const SizedBox(height: 4),
                  Text("Overtime: $overtime", style: TextStyle(color: Colors.grey[600]))
                ],
              ),
            ),
            IconButton(
                iconSize: 20,
                style: IconButton.styleFrom(backgroundColor: Colors.blue.shade700),
                color: Colors.white,
                icon: Icon(Icons.edit),
                onPressed: () => onEdit()),
          ],
        ),
      ),
    );
  }
}
